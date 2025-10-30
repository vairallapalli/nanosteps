import SwiftUI
import Combine

struct HabitDetailHost<Content: View>: View {
    @EnvironmentObject var store: HabitStore
    @State private var habitToEdit: Habit? = nil
    let content: () -> Content

    var body: some View {
        content()
            .onReceive(NotificationCenter.default.publisher(for: .init("OpenHabitEdit"))) { note in
                guard let idStr = note.object as? String,
                      let id = UUID(uuidString: idStr),
                      let habit = store.habits.first(where: { $0.id == id }) else { return }
                habitToEdit = habit
            }
            .sheet(item: $habitToEdit) { h in
                HabitDetailView(habit: h).environmentObject(store)
            }
    }
}
