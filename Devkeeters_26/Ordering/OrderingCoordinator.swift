//
//  OrderingCoordinator.swift
//  Devkeeters_26
//
//  The one shared "place an order" function. Called identically from
//  PlaceZomatoOrderIntent.perform() (Siri) and OrderViewModel.submit()
//  (touch fallback) — neither duplicates this logic. Owns the automatic
//  placed -> preparing -> on the way -> delivered -> end progression.
//

import Foundation
import Observation

/// Thin seam over OrderingBrain so the coordinator is testable without
/// FoundationModels/Apple Intelligence being available.
protocol IntentRouting {
    func route(text: String) async throws -> RoutedIntent
}
extension OrderingBrain: IntentRouting {}

/// Thin seam over LiveOrderActivity so the coordinator is testable without
/// ActivityKit / a real Live Activity.
protocol LiveActivityDriving {
    func start(for summary: OrderSummary) throws
    func update(statusText: String, etaMinutes: Int?, progress: Double) async
    func end() async
}
struct LiveActivityAdapter: LiveActivityDriving {
    func start(for summary: OrderSummary) throws { try LiveOrderActivity.start(for: summary) }
    func update(statusText: String, etaMinutes: Int?, progress: Double) async {
        await LiveOrderActivity.update(statusText: statusText, etaMinutes: etaMinutes, progress: progress)
    }
    func end() async { await LiveOrderActivity.end() }
}

/// Injectable delay so the auto-progress timer is real in production and
/// instant in tests.
protocol OrderProgressClock {
    func sleep(seconds: Double) async
}
struct SystemOrderProgressClock: OrderProgressClock {
    func sleep(seconds: Double) async { try? await Task.sleep(for: .seconds(seconds)) }
}

enum OrderingCoordinatorError: Error, LocalizedError {
    case unsupportedDomain(ServiceDomain)
    case brainFailure(String)
    case liveActivityFailure(String)

    var localizedMessage: String {
        switch self {
        case .unsupportedDomain(let domain):
            "Cortex routed this to \(domain.rawValue.capitalized), but only Zomato food ordering is wired up right now. Try describing a food order instead."
        case .brainFailure(let message):
            "Cortex couldn't understand that order: \(message)"
        case .liveActivityFailure(let message):
            "Order placed, but the Live Activity couldn't start: \(message)"
        }
    }

    var errorDescription: String? {
        localizedMessage
    }
}

@MainActor
@Observable
final class OrderingCoordinator {
    static let shared = OrderingCoordinator()

    enum State: Equatable {
        case idle
        case placing
        case active(statusText: String, progress: Double, etaMinutes: Int?)
        case failed(String)
    }

    private static let steps: [(status: String, progress: Double)] = [
        ("Order placed", 0.0),
        ("Preparing", 0.35),
        ("On the way", 0.7),
        ("Delivered", 1.0)
    ]

    private(set) var state: State = .idle
    private(set) var lastOrder: OrderSummary?

    private let router: any IntentRouting
    private let zomatoService: any ZomatoOrdering
    private let liveActivity: any LiveActivityDriving
    private let clock: any OrderProgressClock
    private let stepInterval: Double
    private let postDeliveryDismissDelay: Double
    private var progressTask: Task<Void, Never>?

    init(
        router: any IntentRouting = OrderingBrain.shared,
        zomatoService: any ZomatoOrdering = ZomatoService(),
        liveActivity: any LiveActivityDriving = LiveActivityAdapter(),
        clock: any OrderProgressClock = SystemOrderProgressClock(),
        stepInterval: Double = 17,
        postDeliveryDismissDelay: Double = 5
    ) {
        self.router = router
        self.zomatoService = zomatoService
        self.liveActivity = liveActivity
        self.clock = clock
        self.stepInterval = stepInterval
        self.postDeliveryDismissDelay = postDeliveryDismissDelay
    }

    /// Entry point from voice/touch — runs text through the brain first.
    @discardableResult
    func placeOrder(from text: String) async throws -> OrderSummary {
        progressTask?.cancel()
        progressTask = nil
        if lastOrder != nil {
            await liveActivity.end()
            lastOrder = nil
        }
        state = .placing

        let routed: RoutedIntent
        do {
            routed = try await router.route(text: text)
        } catch {
            let mapped = OrderingCoordinatorError.brainFailure(error.localizedDescription)
            state = .failed(mapped.localizedMessage)
            throw mapped
        }

        guard routed.domain == .zomato else {
            let mapped = OrderingCoordinatorError.unsupportedDomain(routed.domain)
            state = .failed(mapped.localizedMessage)
            throw mapped
        }

        let summary = zomatoService.buildOrderSummary(from: routed)
        return try activate(summary: summary)
    }

    /// Entry point from OrderMyUsualIntent — summary already built, skip the brain.
    @discardableResult
    func placeOrder(summary: OrderSummary) throws -> OrderSummary {
        progressTask?.cancel()
        progressTask = nil
        state = .placing
        return try activate(summary: summary)
    }

    // MARK: - Shared activation (Live Activity + state + auto-save)

    @discardableResult
    private func activate(summary: OrderSummary) throws -> OrderSummary {
        do {
            try liveActivity.start(for: summary)
        } catch {
            let mapped = OrderingCoordinatorError.liveActivityFailure(error.localizedDescription)
            state = .failed(mapped.localizedMessage)
            throw mapped
        }

        lastOrder = summary
        LastOrderStore.shared.save(summary)          // auto-saves as "my usual"
        state = .active(statusText: summary.initialStatus, progress: 0, etaMinutes: summary.etaMinutes)
        beginAutoProgress(for: summary)
        return summary
    }

    private func beginAutoProgress(for summary: OrderSummary) {
        progressTask = Task {
            for step in Self.steps.dropFirst() {
                await clock.sleep(seconds: stepInterval)
                if Task.isCancelled { return }
                let eta = summary.etaMinutes.map { Int(Double($0) * (1 - step.progress)) }
                await liveActivity.update(statusText: step.status, etaMinutes: eta, progress: step.progress)
                if Task.isCancelled { return }
                state = .active(statusText: step.status, progress: step.progress, etaMinutes: eta)
            }
            await clock.sleep(seconds: postDeliveryDismissDelay)
            if Task.isCancelled { return }
            await liveActivity.end()
            if Task.isCancelled { return }
            state = .idle
            lastOrder = nil
        }
    }
}
