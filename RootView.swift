import SwiftUI

struct RootView: View {
    @AppStorage("NanoSteps.onboarded") private var onboarded: Bool = false
    @EnvironmentObject var store: HabitStore

    @State private var showSplash = true
    @State private var fadeOut = false

    var body: some View {
        ZStack {
            if onboarded {
                MainTabView()
                    .transition(.opacity)
            } else {
                OnboardingView {
                    withAnimation(.easeInOut) { onboarded = true }
                }
                .transition(.opacity)
            }

            if showSplash {
                splashView
                    .transition(.opacity)
            }
        }
        .onAppear {
            startLaunchAnimation()
        }
    }

    private var splashView: some View {
        ZStack {
            LinearGradient(colors: [Color("Ultramarine"), .indigo],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 58, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(fadeOut ? 1.6 : 1.0)
                    .opacity(fadeOut ? 0.0 : 1.0)

                Text("NanoSteps")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
            }
        }
    }

    private func startLaunchAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 1.2)) {
                fadeOut = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.8)) {
                showSplash = false
            }
        }
    }
}


