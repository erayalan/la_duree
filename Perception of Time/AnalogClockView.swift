//
//  AnalogClockView.swift
//  Perception of Time
//
//  Updated analog clock with AM/PM support and always-draggable numbers
//

import SwiftUI

struct AnalogClockView: View {
    @StateObject private var settings = ClockSettings()
    @State private var currentTime = Date()
    @State private var lastHapticAngles: [Int: Double] = [:] // Track last angle that triggered haptic
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let clockRadius: CGFloat = 150
    
    var body: some View {
        VStack(spacing: 80) {
            // Clock Face
            ZStack {
                // Clock face
                Circle()
                    .stroke(Color.primary, lineWidth:12)
                    .frame(width: 360, height: 360)
                // Dynamic minute markers (4 between each hour)
                ForEach(minuteMarkerAngles, id: \.self) { angle in
                    Rectangle()
                        .fill(Color.primary.opacity(1))
                        .frame(width: 1, height: 10)
                        .offset(y: -170)
                        .rotationEffect(.degrees(angle))
                }
                
                // Grouped Hour markers and numbers
                ForEach(1...12, id: \.self) { hour in
                    ZStack {
                        Rectangle()
                            .fill(Color.primary)
                            .frame(width: 8, height: 20)
                            .offset(y: -168)
    
                        // Hour number (Regular number)
                        Text("\(hour)")
                            .font(.system(size: 24, weight: .heavy))
                            .foregroundColor(Color.primary)
                            .rotationEffect(.degrees(-(currentMarkerAngles[hour] ?? Double(hour) * 30))) // Counter-rotate the text
                            .offset(y: -135) // Position numbers closer to center than markers
                    }
                    .rotationEffect(.degrees(currentMarkerAngles[hour] ?? Double(hour) * 30))
                    .gesture(
                        // Only apply gesture to hours 1-11, NOT hour 12
                        hour == 12 ? nil : DragGesture()
                            .onChanged { value in
                                let center = CGPoint(x: 0, y: 0)
                                let rawAngle = angleFromPoint(value.location, center: center)
                                // Snap to 6-degree increments (minute markers)
                                let snappedAngle = snapToSixDegreeIncrements(rawAngle)
                                
                                // Apply boundary constraints
                                let constrainedAngle = applyBoundaryConstraints(for: hour, proposedAngle: snappedAngle)
                                
                                // Trigger haptic feedback if we've moved to a new step
                                if let lastAngle = lastHapticAngles[hour],
                                   abs(constrainedAngle - lastAngle) >= 6.0 {
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                    lastHapticAngles[hour] = constrainedAngle
                                } else if lastHapticAngles[hour] == nil {
                                    // First drag, set initial value
                                    lastHapticAngles[hour] = constrainedAngle
                                }
                                
                                settings.updatePosition(hour: hour, angle: constrainedAngle)
                            }
                            .onEnded { _ in
                                // Reset haptic tracking when drag ends
                                lastHapticAngles[hour] = nil
                            }
                    )
                }
                
                // Minute hand
                Rectangle()
                    .fill(Color.primary)
                    .frame(width: 8, height: 80)
                    .offset(y: -55)
                    .rotationEffect(.degrees(warpedMinuteAngle))
                    .animation(.easeInOut(duration: 0.5), value: warpedMinuteAngle)
            
                
                // Hour hand
                Rectangle()
                    .fill(Color.primary)
                    .frame(width: 8, height: 60)
                    .offset(y: -40)
                    .rotationEffect(.degrees(warpedHourAngle))
                    .animation(.easeInOut(duration: 0.5), value: warpedHourAngle)
                
                Circle()
                    .fill(Color.primary)
                    .frame(width: 32, height: 32)
            }
            
            .frame(width: 300, height: 300)
            // AM/PM Text Buttons
            HStack(spacing:0) {
                Button(action: {
                    if !settings.isAMMode {
                        settings.toggleAMPM()
                    }
                }) {
                    Text("AM")
                        .font(.headline)
                        .fontWeight(settings.isAMMode ? .bold : .regular)
                        .foregroundColor(settings.isAMMode ? .primary : .gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(settings.isAMMode ? Color.primary : Color.primary, lineWidth: settings.isAMMode ? 8 : 1)
//                                .background(
//                                    RoundedRectangle(cornerRadius: 8)
//                                        .fill(settings.isAMMode ? Color.yellow.opacity(0) : Color.clear)
//                                )
                        )
                }
                .disabled(settings.isAMMode)
                
                Button(action: {
                    if settings.isAMMode {
                        settings.toggleAMPM()
                    }
                }) {
                    Text("PM")
                        .font(.headline)
                        .fontWeight(!settings.isAMMode ? .bold : .regular)
                        .foregroundColor(!settings.isAMMode ? .primary : .gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(!settings.isAMMode ? Color.primary : Color.primary, lineWidth: !settings.isAMMode ? 8 : 1)
//                                .background(
//                                    RoundedRectangle(cornerRadius: 8)
//                                        .fill(!settings.isAMMode ? Color.yellow.opacity(0.1) : Color.clear)
//                                )
                        )
                }
                .disabled(!settings.isAMMode)
            }
            
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }
    
    private var minuteMarkerAngles: [Double] {
        var angles: [Double] = []
        let positions = currentMarkerAngles

        // Create a sorted list of (hour, angle)
        let sortedHours = (1...12).map { hour in
            (hour, normalizeAngle(positions[hour] ?? Double(hour) * 30))
        }.sorted { $0.1 < $1.1 }

        for i in 0..<12 {
            let current = sortedHours[i]
            let next = sortedHours[(i + 1) % 12] // Wrap around

            let startAngle = current.1
            let endAngle = next.1 >= startAngle ? next.1 : next.1 + 360

            let angleDiff = endAngle - startAngle

            for j in 1...4 {
                let step = Double(j) / 5.0
                let minuteAngle = startAngle + step * angleDiff
                angles.append(normalizeAngle(minuteAngle))
            }
        }

        return angles
    }

    
    // Calculate the shortest angular difference between two angles
    private func calculateAngularDifference(from startAngle: Double, to endAngle: Double) -> Double {
        let normalizedStart = normalizeAngle(startAngle)
        let normalizedEnd = normalizeAngle(endAngle)
        
        var diff = normalizedEnd - normalizedStart
        
        // Choose the shortest path around the circle
        if diff > 180 {
            diff -= 360
        } else if diff < -180 {
            diff += 360
        }
        
        return diff
    }
    
    // Get current marker angles based on editing mode
    private var currentMarkerAngles: [Int: Double] {
        return settings.getEditingPositions()
    }
    
    private var sortedHourAngles: [(hour: Int, angle: Double)] {
        (1...12)
            .map { hour in
                (hour, normalizeAngle(settings.getCurrentPositions()[hour] ?? Double(hour) * 30))
            }
            .sorted { $0.angle < $1.angle }
    }
    
    // Calculate the warped hour angle (points to current hour number's position)
    private var warpedHourAngle: Double {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: currentTime) % 12
        let minute = calendar.component(.minute, from: currentTime)
        let hourValue = hour == 0 ? 12 : hour
        
        let sorted = sortedHourAngles

        // Find index of current hour
        guard let currentIndex = sorted.firstIndex(where: { $0.hour == hourValue }) else {
            return Double(hourValue) * 30 // fallback
        }

        let nextIndex = (currentIndex + 1) % 12
        let currentAngle = sorted[currentIndex].angle
        let nextAngle = sorted[nextIndex].angle >= currentAngle
            ? sorted[nextIndex].angle
            : sorted[nextIndex].angle + 360

        let progress = Double(minute) / 60.0
        let interpolated = currentAngle + (nextAngle - currentAngle) * progress
        return normalizeAngle(interpolated)
    }

    
    // Calculate the warped minute angle (moves between hour markers every 5 minutes)
    private var warpedMinuteAngle: Double {
        let calendar = Calendar.current
        let minute = calendar.component(.minute, from: currentTime)
        
        let segment = minute / 5
        let minuteOffset = minute % 5

        // Convert segment to hour numbers (segment 0 = 12)
        let currentHour = segment == 0 ? 12 : segment
        let nextHour = currentHour == 12 ? 1 : currentHour + 1
        
        let sorted = sortedHourAngles
        guard let currentIndex = sorted.firstIndex(where: { $0.hour == currentHour }) else {
            return Double(minute) * 6
        }
        let nextIndex = (currentIndex + 1) % 12
        let currentAngle = sorted[currentIndex].angle
        let nextAngle = sorted[nextIndex].angle >= currentAngle
            ? sorted[nextIndex].angle
            : sorted[nextIndex].angle + 360

        let progress = Double(minuteOffset) / 5.0
        let interpolated = currentAngle + (nextAngle - currentAngle) * progress
        return normalizeAngle(interpolated)
    }

    
    // Helper function to interpolate between two angles, handling the 0°/360° boundary
    private func interpolateAngles(from startAngle: Double, to endAngle: Double, progress: Double) -> Double {
        let normalizedStart = normalizeAngle(startAngle)
        let normalizedEnd = normalizeAngle(endAngle)
        
        // Calculate the shortest path between angles
        var diff = normalizedEnd - normalizedStart
        
        // Handle crossing the 0°/360° boundary
        if diff > 180 {
            diff -= 360
        } else if diff < -180 {
            diff += 360
        }
        
        let result = normalizedStart + (diff * progress)
        return normalizeAngle(result)
    }
    
    // Apply boundary constraints to prevent hours from crossing each other
    private func applyBoundaryConstraints(for hour: Int, proposedAngle: Double) -> Double {
        let positions = settings.getEditingPositions()
        
        // Get the angles of adjacent hours
        let previousHour = hour == 1 ? 12 : hour - 1
        let nextHour = hour == 12 ? 1 : hour + 1
        
        let previousAngle = positions[previousHour] ?? Double(previousHour) * 30
        let nextAngle = positions[nextHour] ?? Double(nextHour) * 30
        
        // Normalize angles to handle 0°/360° boundary
        let normalizedProposed = normalizeAngle(proposedAngle)
        let normalizedPrevious = normalizeAngle(previousAngle)
        let normalizedNext = normalizeAngle(nextAngle)
        
        // Handle special cases around 12 o'clock (0°/360°)
        if hour == 1 {
            // Hour 1 needs to maintain 12° gap from both hour 12 and hour 2
            let minAngleFrom12 = normalizedPrevious + 12 // At least 12° from hour 12
            let maxAngleFrom2 = normalizedNext - 12 // At least 12° from hour 2
            
            // Handle the case where hour 12 is near 360° and hour 1 is near 0°
            if normalizedPrevious > 180 { // Hour 12 is in the upper half
                // Hour 1 should be at least 12° clockwise from hour 12
                let adjustedMinAngle = normalizedPrevious + 12
                if adjustedMinAngle >= 360 {
                    // Wrap around: hour 1 must be at least (12 + previous - 360)°
                    let wrappedMinAngle = adjustedMinAngle - 360
                    return max(wrappedMinAngle, min(normalizedProposed, maxAngleFrom2))
                } else {
                    return max(minAngleFrom12, min(normalizedProposed, maxAngleFrom2))
                }
            } else {
                // Normal case: constrain between the two bounds
                return max(minAngleFrom12, min(normalizedProposed, maxAngleFrom2))
            }
        } else if hour == 11 {
            // Special handling for hour 11 (adjacent to hour 12 at 0°)
            let minAngleFrom10 = normalizedPrevious + 12
            
            if normalizedNext < 180 { // Hour 12 is in the lower half (near 0°)
                // Hour 11 can go up to 348° (12° before 0°/360°)
                let maxAngleFrom12 = 360 - 12 // 348°
                return max(minAngleFrom10, min(normalizedProposed, Double(maxAngleFrom12)))
            } else {
                // Normal case
                let maxAngleFrom12 = normalizedNext - 12
                return max(minAngleFrom10, min(normalizedProposed, maxAngleFrom12))
            }
        } else {
            // For hours 2-10, use normal constraints
            let minAngle = normalizedPrevious + 12 // Leave at least 12° gap
            let maxAngle = normalizedNext - 12 // Leave at least 12° gap
            return max(minAngle, min(normalizedProposed, maxAngle))
        }
    }
    
    // Normalize angle to 0-360 range
    private func normalizeAngle(_ angle: Double) -> Double {
        let normalized = angle.truncatingRemainder(dividingBy: 360)
        return normalized >= 0 ? normalized : normalized + 360
    }
    
    // Snap angle to 6-degree increments
    private func snapToSixDegreeIncrements(_ angle: Double) -> Double {
        let step: Double = 6.0
        let normalizedAngle = angle.truncatingRemainder(dividingBy: 360)
        let adjustedAngle = normalizedAngle >= 0 ? normalizedAngle : normalizedAngle + 360
        let snappedAngle = round(adjustedAngle / step) * step
        return snappedAngle.truncatingRemainder(dividingBy: 360)
    }
    
    // Calculate angle from a point relative to center
    private func angleFromPoint(_ point: CGPoint, center: CGPoint) -> Double {
        let deltaX = point.x - center.x
        let deltaY = point.y - center.y
        let radians = atan2(deltaY, deltaX)
        var degrees = radians * 180 / .pi
        
        // Convert to clock angle (0° at top, clockwise)
        degrees = degrees + 90
        if degrees < 0 {
            degrees += 360
        }
        
        return degrees
    }
}

// MARK: - Preview
struct AnalogClockView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Default preview
            AnalogClockView()
                .previewDisplayName("Default")
        }
    }
}
