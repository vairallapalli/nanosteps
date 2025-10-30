

import Foundation
import SwiftUI

class UserPreferences {
    static let shared = UserPreferences()

    @AppStorage("NanoSteps.focusAreas") private var focusAreasData: Data = Data()
    @AppStorage("NanoSteps.demoMode") var demoMode: Bool = true
    @AppStorage("NanoSteps.theme") var theme: String = "ultramarine"

    var focusAreas: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: focusAreasData)) ?? []
        }
        set {
            focusAreasData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
}
