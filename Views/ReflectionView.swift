import SwiftUI

struct ReflectionView: View {
    @EnvironmentObject var store: HabitStore
    @State private var selectedHabitID: UUID?
    @State private var reflectionText = ""
    @State private var suggestedImprovement: String? = nil
    @State private var loadingAI = false

    var selectedHabit: Habit? { store.habits.first { $0.id == selectedHabitID } }

    let prompts = [
        "What small action did I try today?",
        "What made this habit easier or harder?",
        "What cue triggered this habit?",
        "What identity do I want to reinforce?",
        "One tiny change I could make tomorrow"
    ]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {

                Picker("Select a NanoStep", selection: $selectedHabitID) {
                    ForEach(store.habits) { habit in
                        Text(habit.title).tag(habit.id as UUID?)
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal)

                if let habit = selectedHabit {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Reflection prompts for “\(habit.title)”")
                                .font(.headline)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(prompts, id: \.self) { p in
                                        Button {
                                            if !reflectionText.isEmpty { reflectionText.append("\n") }
                                            reflectionText.append(p + " ")
                                        } label: {
                                            Text(p)
                                                .font(.caption)
                                                .padding(.vertical, 6)
                                                .padding(.horizontal, 10)
                                                .background(Color.accentColor.opacity(0.15))
                                                .cornerRadius(12)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }

                            TextEditor(text: $reflectionText)
                                .frame(minHeight: 160)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                                )
                                .padding(.horizontal)

                            HStack {
                                Button("Save Locally") {
                                    guard var h = selectedHabit else { return }
                                    let trimmed = reflectionText.trimmingCharacters(in: .whitespacesAndNewlines)
                                    if !trimmed.isEmpty {
                                        h.reflections.append(trimmed)
                                        store.update(h)
                                        reflectionText = ""
                                        suggestedImprovement = nil
                                    }
                                }
                                .buttonStyle(.bordered)

                                Spacer()

                                Button(action: requestAIImprovement) {
                                    if loadingAI { ProgressView().scaleEffect(0.8) } else { Text("Ask AI to Improve") }
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || loadingAI)
                            }
                            .padding(.horizontal)


                            if let suggested = suggestedImprovement {
                                Divider().padding(.horizontal)

                                VStack(alignment: .leading, spacing: 12) {
                                    Text("AI Suggestion").font(.headline)
                                    Text(suggested)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.horizontal)
                                .transition(.opacity)
                            }

                            Spacer(minLength: 30)
                        }
                    }
                    .scrollDismissesKeyboard(.interactively)
                } else {
                    Text("Select a habit to write a quick reflection")
                        .foregroundColor(.secondary)
                        .padding()
                    Spacer()
                }
            }
            .navigationTitle("Review and Reflect")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private func requestAIImprovement() {
        guard let habit = selectedHabit else { return }
        loadingAI = true
        AIService.improvementFromReflection(habit: habit, reflection: reflectionText) { res in
            DispatchQueue.main.async {
                loadingAI = false
                switch res {
                case .failure(let err):
                    suggestedImprovement = "AI Error: \(err.localizedDescription)"
                case .success(let text):
                    suggestedImprovement = text
                }
            }
        }
    }
}


