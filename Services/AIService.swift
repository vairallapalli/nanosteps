import Foundation

struct OpenAIError: Error { let message: String }

class AIService {
    private static var apiKey: String { APIKey.value }

    static func suggestHabitsCSV(goal: String, existing: [Habit], focusAreas: [String], completion: @escaping (Result<[String], Error>) -> Void) {
        guard !apiKey.isEmpty && !apiKey.hasPrefix("<YOUR_") else {
            completion(.success(parseCSV("Drink water after waking,Read 5 pages after dinner,Walk 10 minutes after lunch,Do 5 pushups after brushing teeth,Write 1 gratitude sentence")))
            return
        }
        let existingList = existing.map { "\($0.title) (\($0.type.rawValue))" }.joined(separator: "; ")
        let focus = focusAreas.joined(separator: ", ")
        let prompt = """
You are a friendly but action-focused Atomic Habits coach for students.

User’s Focus Areas: \(focus)
User Goal: "\(goal)"
Avoid Habits Already Doing: \(existingList)

Generate 6 unique habit ideas that:
• Fit a busy student's daily schedule
• Are extremely easy (1–5 minutes)
• Have clear triggers (before/after existing routines)
• Are measurable and specific
• Do not repeat any existing habits
• Encourage positive identity (who they want to become)

• Vary time of day and context (morning, after school, bedtime)


Output ONLY a comma-separated list of short habits (5–10 words each), no numbering.
"""

        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role":"system","content":"You are a concise helpful habit coach."],
                ["role":"user","content":prompt]
            ],
            "max_tokens": 350,
            "temperature": 0.85
        ]
        callOpenAIText(body: body) { res in
            switch res {
            case .failure(let e): completion(.failure(e))
            case .success(let text): completion(.success(parseCSV(text)))
            }
        }
    }

    static func improvementFromReflection(habit: Habit, reflection: String, completion: @escaping (Result<String,Error>) -> Void) {
        guard !apiKey.isEmpty && !apiKey.hasPrefix("<YOUR_") else {
            completion(.success("Try making the habit smaller: reduce the measure or attach it to an existing routine."))
            return
        }
        let prompt = """
        You are a supportive and practical Atomic Habits coach for teens.

        Habit: \(habit.title)
        Type: \(habit.type.rawValue)
        Trigger: \(habit.trigger)
        Frequency: \(habit.frequency)
        Measure: \(habit.measure)
        Reflection: \(reflection)

        Your task:
        1) One short encouraging motivational sentence
        2) 3 tiny, practical next steps for tomorrow (1–5 minutes each)
        3) One small environment change to make the habit easier

        Keep it short and upbeat.
        """


        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role":"system","content":"You are a practical behavior-change advisor."],
                ["role":"user","content":prompt]
            ],
            "temperature": 0.85,
            "max_tokens": 350
        ]
        callOpenAIText(body: body, completion: completion)
    }

    private static func callOpenAIText(body: [String: Any], completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            completion(.failure(OpenAIError(message: "Bad URL"))); return
        }
        var req = URLRequest(url: url); req.httpMethod = "POST"
        req.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do { req.httpBody = try JSONSerialization.data(withJSONObject: body) } catch {
            completion(.failure(error)); return
        }
        URLSession.shared.dataTask(with: req) { data, _, err in
            if let e = err { completion(.failure(e)); return }
            guard let d = data else { completion(.failure(OpenAIError(message: "No data"))); return }
            do {
                if let json = try JSONSerialization.jsonObject(with: d) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let first = choices.first,
                   let message = (first["message"] as? [String: Any])?["content"] as? String {
                    completion(.success(message.trimmingCharacters(in: .whitespacesAndNewlines)))
                } else if let s = String(data: d, encoding: .utf8) {
                    completion(.success(s))
                } else {
                    completion(.failure(OpenAIError(message: "Unexpected response")))
                }
            } catch { completion(.failure(error)) }
        }.resume()
    }

    static func parseCSV(_ text: String) -> [String] {
        var t = text.replacingOccurrences(of: "\n", with: ",")
        let parts = t.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        return parts.filter { !$0.isEmpty }
    }
}
