import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: HabitStore
    @AppStorage("NanoSteps.demoMode") var demoMode: Bool = true
    @AppStorage("NanoSteps.theme") var theme: String = "ultramarine"
    @AppStorage("NanoSteps.onboarded") var onboarded: Bool = true

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Demo")) {
                    Toggle("Demo Mode (allow multiple completions)", isOn: $demoMode)
                    Button("Reset XP") { store.xp = 0 }
                    Button("Reset Habits") {
                        store.habits.removeAll()
                    }.foregroundColor(.white)
                }

            
                Section(header: Text("Onboarding")) {
                    Button("Re-run Onboarding") { onboarded = false }
                }

            
            }
            .navigationTitle("Settings")
        }
    }
}
