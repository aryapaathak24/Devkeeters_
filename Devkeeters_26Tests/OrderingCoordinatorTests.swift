import XCTest
@testable import Devkeeters_26

@MainActor
final class OrderingCoordinatorTests: XCTestCase {

    func test_placeOrder_zomato_startsLiveActivityAndAutoProgressesToIdle() async throws {
        let router = FakeRouter(result: .success(
            RoutedIntent(domain: .zomato, summary: "butter chicken", items: ["butter chicken", "naan"], secondaryAction: nil)
        ))
        let service = FakeZomatoService(summary: OrderSummary(domain: .zomato, title: "Butter Chicken, Naan", items: ["butter chicken", "naan"], restaurantName: "Spice Garden", totalPrice: 340, initialStatus: "Order placed", etaMinutes: 30))
        let liveActivity = FakeLiveActivity()
        let coordinator = OrderingCoordinator(router: router, zomatoService: service, liveActivity: liveActivity, clock: InstantClock(), stepInterval: 0, postDeliveryDismissDelay: 0)

        let summary = try await coordinator.placeOrder(from: "butter chicken and naan")
        XCTAssertEqual(summary.title, "Butter Chicken, Naan")
        XCTAssertEqual(liveActivity.startedTitles, ["Butter Chicken, Naan"])

        try await Task.sleep(for: .milliseconds(50)) // let the detached progress Task drain

        XCTAssertEqual(liveActivity.updateStatuses, ["Preparing", "On the way", "Delivered"])
        XCTAssertEqual(liveActivity.endCallCount, 1)
        guard case .idle = coordinator.state else { return XCTFail("expected idle after full progression") }
    }

    func test_placeOrder_nonZomatoDomain_throwsUnsupportedDomain() async {
        let router = FakeRouter(result: .success(
            RoutedIntent(domain: .blinkit, summary: "milk", items: ["milk"], secondaryAction: nil)
        ))
        let coordinator = OrderingCoordinator(router: router, zomatoService: FakeZomatoService(summary: .init(domain: .zomato, title: "x", items: ["x"], restaurantName: "Spice Garden", totalPrice: 100, initialStatus: "y", etaMinutes: nil)), liveActivity: FakeLiveActivity(), clock: InstantClock(), stepInterval: 0)

        do {
            _ = try await coordinator.placeOrder(from: "milk and eggs")
            XCTFail("expected unsupportedDomain")
        } catch OrderingCoordinatorError.unsupportedDomain(let domain) {
            XCTAssertEqual(domain, .blinkit)
        } catch { XCTFail("unexpected error \(error)") }
    }

    func test_placeOrder_supersedingOrder_endsPreviousLiveActivityFirst() async throws {
        let router = FakeRouter(result: .success(RoutedIntent(domain: .zomato, summary: "pizza", items: ["pizza"], secondaryAction: nil)))
        let service = FakeZomatoService(summary: .init(domain: .zomato, title: "Pizza", items: ["pizza"], restaurantName: "Spice Garden", totalPrice: 350, initialStatus: "Order placed", etaMinutes: 20))
        let liveActivity = FakeLiveActivity()
        let coordinator = OrderingCoordinator(router: router, zomatoService: service, liveActivity: liveActivity, clock: InstantClock(), stepInterval: 9999, postDeliveryDismissDelay: 9999)

        _ = try await coordinator.placeOrder(from: "pizza")
        _ = try await coordinator.placeOrder(from: "pizza again")

        XCTAssertEqual(liveActivity.startedTitles, ["Pizza", "Pizza"])
        XCTAssertEqual(liveActivity.endCallCount, 1) // the first order's activity was ended before the second started
    }
}

// MARK: - Fakes

private final class FakeRouter: IntentRouting {
    let result: Result<RoutedIntent, Error>
    init(result: Result<RoutedIntent, Error>) { self.result = result }
    func route(text: String) async throws -> RoutedIntent { try result.get() }
}

private final class FakeZomatoService: ZomatoOrdering {
    let summary: OrderSummary
    init(summary: OrderSummary) { self.summary = summary }
    func buildOrderSummary(from routed: RoutedIntent) -> OrderSummary { summary }
    func buildOrderSummary(from items: [String], restaurant: String) -> OrderSummary { summary }
    func checkAvailability(for items: [String]) -> [String: Bool] {
        Dictionary(uniqueKeysWithValues: items.map { ($0, true) })
    }
}

private final class FakeLiveActivity: LiveActivityDriving {
    private(set) var startedTitles: [String] = []
    private(set) var updateStatuses: [String] = []
    private(set) var endCallCount = 0
    func start(for summary: OrderSummary) throws { startedTitles.append(summary.title) }
    func update(statusText: String, etaMinutes: Int?, progress: Double) async { updateStatuses.append(statusText) }
    func end() async { endCallCount += 1 }
}

private struct InstantClock: OrderProgressClock {
    func sleep(seconds: Double) async {}
}
