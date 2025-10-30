import SwiftUI

@main
struct NanoStepsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var store = HabitStore()

    init() {
        let color = UIColor(named: "Ultramarine") ?? .systemBlue

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: color]
        appearance.largeTitleTextAttributes = [.foregroundColor: color]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = color

        UITabBar.appearance().tintColor = color
        
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .tint(Color("Ultramarine"))
                .preferredColorScheme(.light)
                .buttonStyle(.borderedProminent)

        }
    }
}
