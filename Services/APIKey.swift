



import Foundation

// Put your API_KEY in return string or set environment variables, whichever is preferred
struct APIKey {
    static var value: String {
        if let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !key.isEmpty {
            return key
        }
        return ""
    }
}
