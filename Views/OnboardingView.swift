import SwiftUI

struct OnboardingView: View {

    var onFinished: () -> Void

    @State private var page = 0
    @State private var selectedFocus: Set<String> = []
    @State private var prefersEasyHabits: Bool = true
    @State private var notificationConsentAsked = false
    @AppStorage("NanoSteps.onboarded") private var onboarded: Bool = false

    private let focusOptions = ["Health", "Productivity", "Mindfulness", "Learning", "Sleep"]

    var body: some View {
        VStack {
            TabView(selection: $page) {
                introPage.tag(0)
                focusPage.tag(1)
                preferencesPage.tag(2)
                finishPage.tag(3)
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .animation(.easeInOut, value: page)
        .onAppear {
        }
    }

    private var introPage: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("Welcome to NanoSteps")
                .font(.largeTitle.bold())
            Text("Small habits. Big results.")
                .foregroundStyle(.secondary)

            Image(systemName: "sparkles")
                .font(.system(size: 48, weight: .semibold))
                .foregroundColor(Color("Ultramarine"))
                .padding(.top, 8)

            Spacer()
            Button("Get Started") { page = 1 }
                .buttonStyle(.borderedProminent)
                .padding(.bottom)
        }
        .padding()
    }

    private var focusPage: some View {
        VStack(spacing: 12) {
            Text("Pick your focus areas")
                .font(.title2.bold())
                .padding(.top)

            VStack(spacing: 10) {
                ForEach(focusOptions, id: \.self) { f in
                    Toggle(isOn: Binding(
                        get: { selectedFocus.contains(f) },
                        set: { isOn in
                            if isOn { selectedFocus.insert(f) } else { selectedFocus.remove(f) }
                        }
                    )) {
                        Text(f)
                    }
                    .toggleStyle(.switch)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)

            HStack {
                Button("Back") { page = 0 }
                Spacer()
                Button("Next") { page = 2 }
                    .buttonStyle(.borderedProminent)
            }
            .padding(.top)
            .padding(.horizontal)

            Spacer()
        }
    }

    private var preferencesPage: some View {
        VStack(spacing: 16) {
            Text("Preferences")
                .font(.title2.bold())
                .padding(.top)

            Toggle("Start with very easy habits (1–5 min)", isOn: $prefersEasyHabits)
                .padding(.horizontal)

            VStack(spacing: 8) {
                Text("Notifications")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                Text("We can remind you at a time you choose later. You can also enable/disable reminders per habit.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }

            HStack {
                Button("Back") { page = 1 }
                Spacer()
                Button("Next") {
                    if !notificationConsentAsked {
                        notificationConsentAsked = true
                        NotificationManager.requestAuthorizationIfNeeded()
                    }
                    page = 3
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top)
            .padding(.horizontal)

            Spacer()
        }
    }

    private var finishPage: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("All set!")
                .font(.title.bold())
            Text("We’ll personalize suggestions to your goals.")
                .foregroundStyle(.secondary)

            Button("Continue") {
                let arr = Array(selectedFocus)
                UserPreferences.shared.focusAreas = arr
                UserDefaults.standard.set(prefersEasyHabits, forKey: "NanoSteps.prefersEasy")

                onboarded = true
                onFinished()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)

            Button("Back") { page = 2 }
                .padding(.top, 8)

            Spacer()
        }
        .padding()
    }
}

