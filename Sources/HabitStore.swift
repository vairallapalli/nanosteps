import Foundation
import SwiftUI
import Combine

class Persistence {
    static let key = "NanoSteps.habits.v3"
    static func save(_ habits: [Habit]) {
        if let data = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    static func load() -> [Habit] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Habit].self, from: data)
        else { return [] }
        return decoded
    }
}

class HabitStore: ObservableObject {
    @Published var habits: [Habit] = [] {
        didSet { Persistence.save(habits) }
    }
    @Published var xp: Int = 0 {
        didSet { UserDefaults.standard.set(xp, forKey: "NanoSteps.xp") }
    }

    init() {
        habits = Persistence.load()
        xp = UserDefaults.standard.integer(forKey: "NanoSteps.xp")
    }

    func add(_ h: Habit) {
        habits.append(h)
        objectWillChange.send()
    }

    func update(_ h: Habit) {
        if let i = habits.firstIndex(where: { $0.id == h.id }) {
            habits[i] = h
            objectWillChange.send() 
        }
    }

    func remove(_ h: Habit) {
        habits.removeAll { $0.id == h.id }
        objectWillChange.send()
    }

    func awardXP(_ amount: Int) {
        xp += amount
        objectWillChange.send()
    }
}
