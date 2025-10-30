import Foundation

enum HabitActionType: String, Codable, CaseIterable {
    case add = "Add"
    case improve = "Improve"
    case remove = "Remove"
}

struct Habit: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var identityStatement: String?
    var trigger: String
    var frequency: String
    var measure: String
    var type: HabitActionType
    var streakHistory: [Date]
    var reminderTime: Date?
    var reflections: [String]
    var createdAt: Date

    init(id: UUID = .init(),
         title: String,
         identityStatement: String? = nil,
         trigger: String = "",
         frequency: String = "Daily",
         measure: String = "1",
         type: HabitActionType = .add,
         streakHistory: [Date] = [],
         reminderTime: Date? = nil,
         reflections: [String] = [],
         createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.identityStatement = identityStatement
        self.trigger = trigger
        self.frequency = frequency
        self.measure = measure
        self.type = type
        self.streakHistory = streakHistory
        self.reminderTime = reminderTime
        self.reflections = reflections
        self.createdAt = createdAt
    }

    mutating func recordCompletion(demoMode: Bool = false, date: Date = Date()) {
        let cal = Calendar.current
        if demoMode {
            streakHistory.append(date) // allow multiple taps for demo
        } else {
            if !streakHistory.contains(where: { cal.isDate($0, inSameDayAs: date) }) {
                streakHistory.append(date)
            }
        }
    }

    func completedToday() -> Bool {
        let cal = Calendar.current
        return streakHistory.contains { cal.isDate($0, inSameDayAs: Date()) }
    }

    func currentStreak() -> Int {
        let cal = Calendar.current
        var streak = 0
        var day = Date()
        while true {
            if streakHistory.contains(where: { cal.isDate($0, inSameDayAs: day) }) {
                streak += 1
                guard let prev = cal.date(byAdding: .day, value: -1, to: day) else { break }
                day = prev
            } else { break }
        }
        return streak
    }

    func completionCount() -> Int { streakHistory.count }
}
