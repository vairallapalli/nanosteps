import SwiftUI

struct HabitsView: View {
    @EnvironmentObject var store: HabitStore
    @AppStorage("NanoSteps.demoMode") private var demoMode: Bool = true

    @State private var showAdd = false
    @State private var showConfetti = false

    private var growHabits: [Habit] { store.habits.filter { $0.type != .remove } }
    private var reduceHabits: [Habit] { store.habits.filter { $0.type == .remove } }

    var body: some View {
        NavigationStack {
            ZStack {
                List {


                    if !growHabits.isEmpty {
                        Section(header: Text("Grow (+)").font(.headline)) {
                            ForEach(growHabits) { habit in
                                HabitRow(
                                    habit: habit,
                                    onRingTap: { complete(habit) },
                                    onOpen: { openDetail(habit) }
                                )
                            }
                            .onDelete(perform: deleteGrow)
                        }
                    }



                    if !reduceHabits.isEmpty {
                        Section(header: Text("Reduce (–)").font(.headline)) {
                            ForEach(reduceHabits) { habit in
                                HabitRow(
                                    habit: habit,
                                    onRingTap: { complete(habit) },
                                    onOpen: { openDetail(habit) }
                                )
                            }
                            .onDelete(perform: deleteReduce)
                        }
                    }

                    if store.habits.isEmpty {
                        Text("No habits yet — tap + to add your first NanoStep 🚀")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.secondary)
                    }
                }
                .listStyle(.insetGrouped)
                .navigationTitle("Habits")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showAdd = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                    }
                }

                ConfettiView(isActive: $showConfetti)
            }
            .nanoBackground()
            .sheet(isPresented: $showAdd) {
                AddHabitView()
                    .environmentObject(store)
            }
        }
    }


    
    
    private func complete(_ habit: Habit) {
        var updated = habit
        updated.recordCompletion(demoMode: demoMode)

        store.update(updated)
        store.awardXP(5)

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        showConfetti = true
    }

    private func openDetail(_ habit: Habit) {
        NotificationCenter.default.post(
            name: .init("OpenHabitEdit"),
            object: habit.id.uuidString
        )
    }

    
    private func deleteGrow(_ offsets: IndexSet) {
        offsets.map { growHabits[$0] }.forEach(store.remove)
    }

    
    private func deleteReduce(_ offsets: IndexSet) {
        offsets.map { reduceHabits[$0] }.forEach(store.remove)
    }
}

private struct HabitRow: View {
    @EnvironmentObject var store: HabitStore
    let habit: Habit
    let onRingTap: () -> Void
    let onOpen: () -> Void

    var progress: Double {
        let recentThisMonth = habit.streakHistory.filter {
            Calendar.current.isDate($0, equalTo: Date(), toGranularity: .month)
        }.count
        return Double(recentThisMonth) / 30.0
    }

    var typeColor: Color {
        switch habit.type {
        case .add: return .green
        case .improve: return .orange
        case .remove: return .red
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onRingTap) {
                ProgressRing(progress: progress, size: 50, lineWidth: 6)
            }
            .buttonStyle(.plain)

            Button(action: onOpen) {
                VStack(alignment: .leading) {
                    Text(habit.title)
                        .font(.headline)
                    if let identity = habit.identityStatement, !identity.isEmpty {
                        Text("I am: \(identity)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text(habit.trigger)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Text(habit.type.rawValue)
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .foregroundColor(typeColor)
                .background(typeColor.opacity(0.15))
                .clipShape(Capsule())
        }
        .contentShape(Rectangle())
    }
}


