import SwiftUI
import Combine

struct AICoachView: View {
    @EnvironmentObject var store: HabitStore

    @State private var goalInput = ""
    @State private var aiSuggestions: [String] = []
    @State private var loadingAI = false
    @State private var showConfetti = false

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading, spacing: 16) {
                    
                    TextField("Your goal (focus, health, sleep…)", text: $goalInput)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)

                    HStack {
                        Button(action: requestAISuggestions) {
                            if loadingAI {
                                ProgressView().scaleEffect(0.8)
                            } else {
                                Label("Ask coach", systemImage: "sparkles")
                                    .fontWeight(.semibold)
                            }
                        }
                        .disabled(goalInput.trimmingCharacters(in: .whitespaces).isEmpty)
                        .buttonStyle(.borderedProminent)

                        Spacer()

                        Button("Clear") {
                            aiSuggestions = []
                        }
                        .tint(.red)
                    }
                    .padding(.horizontal)

                    Divider().padding(.horizontal, 4)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            if aiSuggestions.isEmpty {
                                Text("Describe something you want to improve,\nlike focus or health.")
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                            } else {
                                Text("Tap to add:")
                                    .font(.headline)
                                    .padding(.horizontal)

                                ForEach(aiSuggestions, id: \.self) { suggestion in
                                    Button(action: {
                                        addHabitFromAI(suggestion)
                                    }) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(suggestion)
                                                    .foregroundColor(.primary)
                                                    .multilineTextAlignment(.leading)
                                            }
                                            Spacer()
                                            Image(systemName: "plus.circle.fill")
                                        }
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }

                    Spacer(minLength: 12)
                }
                .padding(.top, 16)

                ConfettiView(isActive: $showConfetti)
            }
            .navigationTitle("Habit Coach")
            .navigationBarTitleDisplayMode(.large)
        }
    }


    private func requestAISuggestions() {
        loadingAI = true
        let focus = UserPreferences.shared.focusAreas

        AIService.suggestHabitsCSV(
            goal: goalInput,
            existing: store.habits,
            focusAreas: focus
        ) { result in
            DispatchQueue.main.async {
                loadingAI = false
                switch result {
                case .success(let list):
                    aiSuggestions = list
                case .failure:
                    aiSuggestions = []
                }
            }
        }
    }

    private func addHabitFromAI(_ suggestion: String) {
        let newHabit = Habit(
            title: suggestion,
            trigger: "After existing routine",
            frequency: "Daily",
            measure: "1",
            type: .add
        )
        store.add(newHabit)
        store.awardXP(5)
        showConfetti = true
    }
}


