import SwiftUI

struct HabitDetailView: View, Identifiable {
    var id: UUID { habit.id }

    @EnvironmentObject var store: HabitStore
    @Environment(\.dismiss) private var dismiss

    @State var habit: Habit
    @State private var reminderEnabled = false
    @State private var reminderTime = Date()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Identity")) {
                    TextField("I am …", text:
                        Binding(
                            get: { habit.identityStatement ?? "" },
                            set: { habit.identityStatement = $0 }
                        )
                    )
                }

                Section(header: Text("Habit Template")) {
                    TextField("I will …", text: $habit.title)
                    TextField("Trigger — after/before …", text: $habit.trigger)
                    TextField("Frequency — e.g. Daily", text: $habit.frequency)
                    TextField("Measure — e.g. 10 min", text: $habit.measure)
                }

                Section(header: Text("Type")) {
                    Picker("Type", selection: $habit.type) {
                        ForEach(HabitActionType.allCases, id: \.self) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                }

                Section(header: Text("Reminder")) {
                    Toggle("Enable reminder", isOn: $reminderEnabled)
                    if reminderEnabled {
                        DatePicker(
                            "Time",
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                    }
                }

                Section {
                    Button("Save") {
                        habit.reminderTime = reminderEnabled ? reminderTime : nil
                        store.update(habit)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
            .navigationTitle("Edit Habit")
            .onAppear {
                reminderEnabled = habit.reminderTime != nil
                reminderTime = habit.reminderTime ?? Date()
            }
        }
    }
}

