import SwiftUI

struct MainTabView: View {
    var body: some View {
        HabitDetailHost {
            TabView {
                DashboardView()
                    .tabItem { Label("Dashboard", systemImage: "chart.bar.fill") }

                HabitsView()
                    .tabItem { Label("Habits", systemImage: "list.bullet") }

                AICoachView()
                    .tabItem { Label("AI Coach", systemImage: "sparkles") }

                ReflectionView()
                    .tabItem { Label("Reflect", systemImage: "pencil.tip") }

                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gear") }
            }
            .nanoBackground()
        }
    }
}


