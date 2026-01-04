//
//  ClockSettings.swift
//  Perception of Time
//
//  Settings and UserDefaults management for clock positions
//

import Foundation
import WidgetKit

class ClockSettings: ObservableObject {
    @Published var isAMMode = true
    @Published var amPositions: [Int: Double] = [:]
    @Published var pmPositions: [Int: Double] = [:]
    
    private let amPositionsKey = "AMClockPositions"
    private let pmPositionsKey = "PMClockPositions"
    private let suiteName = "group.com.ThisOrThat.PerceptionOfTime"
    
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }
    
    init() {
        loadPositions()
        setupDefaultPositions()
        setInitialAMPMMode()
    }
    
    private func setInitialAMPMMode() {
        let hour = Calendar.current.component(.hour, from: Date())
        isAMMode = hour < 12
    }
    
    private func setupDefaultPositions() {
        if amPositions.isEmpty {
            for hour in 1...12 {
                amPositions[hour] = Double(hour) * 30
            }
        }
        if pmPositions.isEmpty {
            for hour in 1...12 {
                pmPositions[hour] = Double(hour) * 30
            }
        }
    }
    
    func getCurrentPositions() -> [Int: Double] {
        let hour = Calendar.current.component(.hour, from: Date())
        let isCurrentlyAM = hour < 12
        return isCurrentlyAM ? amPositions : pmPositions
    }
    
    func getEditingPositions() -> [Int: Double] {
        return isAMMode ? amPositions : pmPositions
    }
    
    func updatePosition(hour: Int, angle: Double) {
        if isAMMode {
            amPositions[hour] = angle
        } else {
            pmPositions[hour] = angle
        }
        savePositions()
    }
    
    func toggleAMPM() {
        isAMMode.toggle()
    }
    
    private func savePositions() {
        if let defaults = sharedDefaults {
            let amData = try? JSONEncoder().encode(amPositions)
            defaults.set(amData, forKey: amPositionsKey)
            
            let pmData = try? JSONEncoder().encode(pmPositions)
            defaults.set(pmData, forKey: pmPositionsKey)
        } else {
            // Fallback to standard defaults if App Group not available
            let amData = try? JSONEncoder().encode(amPositions)
            UserDefaults.standard.set(amData, forKey: amPositionsKey)
            
            let pmData = try? JSONEncoder().encode(pmPositions)
            UserDefaults.standard.set(pmData, forKey: pmPositionsKey)
        }
        
        // 🔄 Notify Widget to update
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func loadPositions() {
        if let defaults = sharedDefaults {
            if let amData = defaults.data(forKey: amPositionsKey),
               let loadedAM = try? JSONDecoder().decode([Int: Double].self, from: amData) {
                amPositions = loadedAM
            }
            if let pmData = defaults.data(forKey: pmPositionsKey),
               let loadedPM = try? JSONDecoder().decode([Int: Double].self, from: pmData) {
                pmPositions = loadedPM
            }
        } else {
            if let amData = UserDefaults.standard.data(forKey: amPositionsKey),
               let loadedAM = try? JSONDecoder().decode([Int: Double].self, from: amData) {
                amPositions = loadedAM
            }
            if let pmData = UserDefaults.standard.data(forKey: pmPositionsKey),
               let loadedPM = try? JSONDecoder().decode([Int: Double].self, from: pmData) {
                pmPositions = loadedPM
            }
        }
    }
}
