import SwiftUI

struct SharedClockView: View {
    let positions: [Int: Double]
    let date: Date

    private var sortedHourAngles: [(hour: Int, angle: Double)] {
        (1...12).map { hour in
            (hour, positions[hour] ?? Double(hour) * 30)
        }.sorted { $0.angle < $1.angle }
    }

    // Generate warped minute marker angles between the hour markers
    private var minuteMarkerAngles: [Double] {
        var angles: [Double] = []
        let sorted = sortedHourAngles

        for i in 0..<12 {
            let current = sorted[i]
            let next = sorted[(i + 1) % 12]

            let startAngle = current.angle
            let endAngle = next.angle >= startAngle ? next.angle : next.angle + 360
            let step = (endAngle - startAngle) / 5.0

            // 4 markers between each hour
            for j in 1...4 {
                angles.append(normalizeAngle(startAngle + step * Double(j)))
            }
        }

        return angles
    }

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            let radius = size * 0.5
            let ringLineWidth = size * 0.02
            let tickOuter = radius * 0.92
            let minuteTickWidth = max(0.8, size * 0.006)
            let minuteTickHeight = size * 0.035
            let hourTickWidth = max(2, size * 0.012)
            let hourTickHeight = size * 0.07
            let numberRadius = radius * 0.72
            let numberFontSize = max(8, size * 0.06)
            let hourHandLen = radius * 0.4
            let minuteHandLen = radius * 0.5
            let handWidth = max(2, size * 0.012)
            let centerDot = max(16, size * 0.09)

            ZStack {
                Circle()
                    .stroke(Color.primary, lineWidth: ringLineWidth)

                // Dynamic minute tick marks
                ForEach(minuteMarkerAngles, id: \.self) { angle in
                    Rectangle()
                        .fill(Color.primary.opacity(0.6))
                        .frame(width: minuteTickWidth, height: minuteTickHeight)
                        .offset(y: -tickOuter)
                        .rotationEffect(.degrees(angle))
                }

                // Hour tick marks
                ForEach(1...12, id: \.self) { hour in
                    Rectangle()
                        .fill(Color.primary)
                        .frame(width: hourTickWidth, height: hourTickHeight)
                        .offset(y: -tickOuter)
                        .rotationEffect(.degrees(positions[hour] ?? Double(hour) * 30))
                }

                // Hour numbers
                ForEach(1...12, id: \.self) { hour in
                    Text("\(hour)")
                        .font(.system(size: numberFontSize, weight: .bold))
                        .foregroundColor(.primary)
                        .rotationEffect(.degrees(-(positions[hour] ?? Double(hour)*30)))
                        .offset(y: -numberRadius)
                        .rotationEffect(.degrees(positions[hour] ?? Double(hour)*30))
                }

                // Hour hand
                Rectangle()
                    .fill(Color.primary)
                    .frame(width: handWidth, height: hourHandLen)
                    .offset(y: -hourHandLen/2)
                    .rotationEffect(.degrees(hourAngle))

                // Minute hand
                Rectangle()
                    .fill(Color.primary)
                    .frame(width: handWidth, height: minuteHandLen)
                    .offset(y: -minuteHandLen/2)
                    .rotationEffect(.degrees(minuteAngle))

                Circle()
                    .fill(Color.primary)
                    .frame(width: centerDot, height: centerDot)
            }
            .frame(width: size, height: size)
            .position(x: proxy.size.width/2, y: proxy.size.height/2)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var hourAngle: Double {
        let hour = Calendar.current.component(.hour, from: date) % 12
        let minute = Calendar.current.component(.minute, from: date)
        let base = positions[hour == 0 ? 12 : hour] ?? Double(hour == 0 ? 12 : hour) * 30
        let nextHour = positions[hour == 12 ? 1 : hour + 1] ?? Double(hour == 12 ? 1 : hour + 1) * 30
        return base + (nextHour - base) * (Double(minute)/60.0)
    }

    private var minuteAngle: Double {
        let minute = Calendar.current.component(.minute, from: date)
        let segment = minute / 5
        let offset = minute % 5

        let currentHour = segment == 0 ? 12 : segment
        let nextHour = currentHour == 12 ? 1 : currentHour + 1

        let currentAngle = positions[currentHour] ?? Double(currentHour) * 30
        let nextAngle = positions[nextHour] ?? Double(nextHour) * 30
        let adjustedNextAngle = nextAngle >= currentAngle ? nextAngle : nextAngle + 360

        return normalizeAngle(currentAngle + (adjustedNextAngle - currentAngle) * Double(offset) / 5.0)
    }

    private func normalizeAngle(_ angle: Double) -> Double {
        let a = angle.truncatingRemainder(dividingBy: 360)
        return a >= 0 ? a : a + 360
    }
}
