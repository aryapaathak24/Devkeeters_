//
//  PurchaseHistoryStore.swift
//  Devkeeters_26
//
//  Same UserDefaults + Codable idiom as Models/LastOrderStore.swift.
//  seedIfNeeded() synthesizes ~6-8 weeks of mock history on first launch
//  so the prediction engine has something to compute on day one — four
//  consistent-interval items plus one deliberately high-variance item
//  (Chocolate), which the engine should exclude.
//

import Foundation

final class PurchaseHistoryStore {
    static let shared = PurchaseHistoryStore()
    private init() {}

    private let key = "com.devkeeters.purchaseHistory"

    func load() -> [PurchaseRecord] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let records = try? JSONDecoder().decode([PurchaseRecord].self, from: data) else {
            return []
        }
        return records
    }

    func save(_ records: [PurchaseRecord]) {
        guard let data = try? JSONEncoder().encode(records) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    func append(_ records: [PurchaseRecord]) {
        guard !records.isEmpty else { return }
        save(load() + records)
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }

    func seedIfNeeded(now: Date = Date()) {
        guard load().isEmpty else { return }
        save(Self.generateSeedHistory(endingAt: now))
    }

    private static func generateSeedHistory(endingAt now: Date) -> [PurchaseRecord] {
        let calendar = Calendar.current
        var records: [PurchaseRecord] = []

        func addRecurring(item: String, price: Int, intervalDays: Int, jitterDays: Int, occurrences: Int) {
            var date = now
            for _ in 0..<occurrences {
                let jitter = jitterDays > 0 ? Int.random(in: -jitterDays...jitterDays) : 0
                date = calendar.date(byAdding: .day, value: -(intervalDays + jitter), to: date) ?? date
                records.append(PurchaseRecord(itemName: item, date: date, price: price))
            }
        }

        addRecurring(item: "Milk", price: 45, intervalDays: 4, jitterDays: 1, occurrences: 12)
        addRecurring(item: "Bread", price: 40, intervalDays: 5, jitterDays: 1, occurrences: 10)
        addRecurring(item: "Eggs", price: 90, intervalDays: 9, jitterDays: 2, occurrences: 6)
        addRecurring(item: "Rice", price: 320, intervalDays: 20, jitterDays: 3, occurrences: 3)

        // High-variance item — the prediction engine should exclude this.
        var chocolateDate = now
        for gap in [2, 38, 5, 41, 3] {
            chocolateDate = calendar.date(byAdding: .day, value: -gap, to: chocolateDate) ?? chocolateDate
            records.append(PurchaseRecord(itemName: "Chocolate", date: chocolateDate, price: 60))
        }

        return records
    }
}
