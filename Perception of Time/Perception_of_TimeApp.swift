//
//  Perception_of_TimeApp.swift
//  Perception of Time
//
//  Created by Eray Alan on 5/22/25.
//

import SwiftUI

@main
struct Perception_of_TimeApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                ContentView()
            } else {
                OnboardingView()
            }
        }
    }
}

