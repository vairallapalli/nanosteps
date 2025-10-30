import SwiftUI
import Combine

struct AddHabitView: View {
    @EnvironmentObject var store: HabitStore
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var identity = ""
    @State private var trigger = ""
    @State private var frequency = "Daily"
    @State private var measure = "1"
    @State private var type: HabitActionType = .add

    @State private var reminderEnabled = false
    @State private var reminderTime = Date()

    @State private var aiGoal = ""
    @State private var aiSuggestions: [String] = []
    @State private var loadingAI = false
    @State private var showConfetti = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 14) {
                    
                    Text("Create NanoStep")
                        .font(.title2.bold())
                        .padding(.top)

                    Group {
                        TextField("I will… (behavior)", text: $title)
                        TextField("Trigger: after/before …", text: $trigger)
                        TextField("Frequency: e.g., Daily / 3x week", text: $frequency)
                        TextField("I am/I can… (identity)", text: $identity)
                        TextField("Measure: e.g., 10 min, 5 pages", text: $measure)
                        
                        Picker("Type", selection: $type) {
                            ForEach(HabitActionType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                    Toggle("Set reminder", isOn: $reminderEnabled)
                        .padding(.horizontal)

                    if reminderEnabled {
                        DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                            .padding(.horizontal)
                    }

                    Divider().padding(.vertical, 6)

                    VStack(alignment: .leading, spacing: 10) {

                        Text("AI Suggestions")
                            .font(.headline)

                        TextField("Goal (ex: study, sleep, fitness…)", text: $aiGoal)
                            .textFieldStyle(.roundedBorder)

                        HStack {
                            Button(action: requestAISuggestions) {
                                if loadingAI {
                                    ProgressView().scaleEffect(0.8)
                                } else {
                                    Label("Ask AI", systemImage: "sparkles")
                                }
                            }
                            .disabled(aiGoal.trimmingCharacters(in: .whitespaces).isEmpty || loadingAI)

                            Spacer()

                            Button("Clear") {
                                aiSuggestions = []
                            }
                            .foregroundColor(.white)
                        }

                        if !aiSuggestions.isEmpty {
                            ForEach(aiSuggestions, id: \.self) { s in
                                Button(action: {
                                    title = s
                                    if trigger.isEmpty {
                                        trigger = "After existing routine"
                                    }
                                }) {
                                    HStack {
                                        Text(s)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Image(systemName: "plus.circle.fill")
                                    }
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                    .padding(.horizontal)

                    Divider()

                    Button("Add Habit") {
                        addHabit()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .padding()

                    Spacer(minLength: 20)
                }
            }
            .navigationTitle("Add Habit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .overlay(
                ConfettiView(isActive: $showConfetti)
            )
        }
    }

    private func addHabit() {
        var h = Habit(
            title: title,
            identityStatement: identity.isEmpty ? nil : identity,
            trigger: trigger,
            frequency: frequency,
            measure: measure,
            type: type,
            reminderTime: reminderEnabled ? reminderTime : nil
        )
        store.add(h)
        store.awardXP(10)

        if reminderEnabled {
            NotificationManager.scheduleNotification(for: h)
        }

        showConfetti = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            dismiss()
        }
    }

    private func requestAISuggestions() {
        loadingAI = true
        let focus = UserPreferences.shared.focusAreas

        AIService.suggestHabitsCSV(goal: aiGoal,
                                  existing: store.habits,
                                  focusAreas: focus) { result in
            DispatchQueue.main.async {
                loadingAI = false
                switch result {
                case .failure:
                    aiSuggestions = []
                case .success(let arr):
                    aiSuggestions = arr
                }
            }
        }
    }
}


