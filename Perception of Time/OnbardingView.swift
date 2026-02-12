import SwiftUI

struct OnboardingStep: Identifiable {
    let id = UUID()
    let text: String
}

struct OnboardingClockView: View {
    var page: Int
    
    // Predefined hour angles for each onboarding step
    private let hourAngles: [[Int: Double]] = [
        // Step 1: Even clock
        (1...12).reduce(into: [Int: Double]()) { $0[$1] = Double($1) * 30 },
        // Step 2: Squeezed at bottom (hours 5-8 compressed)
        [
            1: 12, 2: 24, 3: 36, 4: 48,
            5: 60, 6: 72, 7: 84, 8: 120,
            9: 180, 10: 240, 11: 300, 12: 360
        ],
        // Step 3: Even more squeezed at lower right
        [
            1: 12, 2: 24, 3: 36, 4: 48,
            5: 60, 6: 72, 7: 84, 8: 120,
            9: 150, 10: 300, 11: 330, 12: 360
        ],
        [
            1: 30, 2: 60, 3: 90, 4: 120,
            5: 150, 6: 180, 7: 210, 8: 240,
            9: 270, 10: 300, 11: 330, 12: 360
        ]
    ]
    
    var body: some View {
        GeometryReader { geo in
            let progress = Double(page)
            // Interpolate between angle sets
            let a1 = hourAngles[min(Int(floor(progress)), 3)]
            let a2 = hourAngles[min(Int(ceil(progress)), 3)]
            let t = progress - floor(progress)
            let angles = (1...12).reduce(into: [Int: Double]()) { dict, hour in
                let angle1 = a1[hour] ?? Double(hour) * 30
                let angle2 = a2[hour] ?? Double(hour) * 30
                dict[hour] = angle1 + (angle2 - angle1) * t
            }
            ZStack {
                AnalogClockFaceView(positions: angles)
            }
            .frame(width: min(geo.size.width, 320), height: min(geo.size.width, 320))
            .frame(maxWidth: .infinity)
        }
        .frame(height: 340)
        .animation(.easeInOut(duration: 0.7), value: page)
    }
}

// Minimal clock face rendering for onboarding
struct AnalogClockFaceView: View {
    let positions: [Int: Double]
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.primary, lineWidth: 12)
                .frame(width: 320, height: 320)
             //Minute markers
//            ForEach(0..<60, id: \.self) { i in
//                Rectangle()
//                    .fill(Color.primary.opacity(i % 5 == 0 ? 1 : 0.6))
//                    .frame(width: i % 5 == 0 ? 3 : 1, height: i % 5 == 0 ? 18 : 8)
//                    .offset(y: -146)
//                    .rotationEffect(.degrees(Double(i) * 6))
//            }
            // Hour markers and numbers
            ForEach(1...12, id: \.self) { hour in
                VStack {
                    Rectangle()
                        .fill(Color.primary)
                        .frame(width: 5, height: 22)
                        .offset(y: -130)
                    Text("\(hour)")
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundColor(Color.primary)
                        .rotationEffect(.degrees(-(positions[hour] ?? Double(hour) * 30)))
                        .offset(y: -118)
                }
                .rotationEffect(.degrees(positions[hour] ?? Double(hour) * 30))
            }
            // Hands: hour and minute fixed per image
            // For each step, use 12:19 as in screenshots
            Rectangle()
                .fill(Color.primary)
                .frame(width: 7, height: 76)
                .offset(y: -48)
                .rotationEffect(.degrees(115)) // Minute hand at 19
            Rectangle()
                .fill(Color.primary)
                .frame(width: 7, height: 60)
                .offset(y: -36)
                .rotationEffect(.degrees(0)) // Hour hand at 12
            Circle()
                .fill(Color.primary)
                .frame(width: 28, height: 28)
        }
    }
}

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0
    @State private var animatedPage: Double = 0

    private let steps = [
        OnboardingStep(text: "Clocks divide time evenly. But this doesn’t match our perception."),
        OnboardingStep(text: "A deep sleep from midnight to 7 a.m. passes quickly."),
        OnboardingStep(text: "But a boring one-hour meeting at 9 a.m. drags."),
        OnboardingStep(text: "How do you perceive time?"),
    ]

    var body: some View {
        VStack {
            Spacer(minLength: 120)
            OnboardingClockView(page: Int(animatedPage))
            Spacer()
            TabView(selection: $currentPage) {
                ForEach(0..<steps.count, id: \.self) { index in
                    VStack(spacing: 20) {
                        Text(steps[index].text)
                            .font(.title)
                            .multilineTextAlignment(.center)
                            .padding()
                            .transition(.opacity)
                        if index == steps.count - 1 {
                            Button(action: {
                                hasSeenOnboarding = true
                            }) {
                                Text("Set Up Your Clock")
                                    .bold()
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(Color.primary, lineWidth: 5)
                                    )
                                    .foregroundColor(.primary)
                                    .cornerRadius(24)
                                    .padding(.horizontal, 36)
                            }
                        }
                    }
                    .padding(.bottom, 32)
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .tint(Color.accentColor)
        }
        .onChange(of: currentPage) { oldValue, newValue in
            withAnimation {
                animatedPage = Double(newValue)
            }
        }
        .onAppear {
            animatedPage = 0
        }
    }
}


#Preview("Onboarding") {
    // Ensure onboarding shows in preview regardless of stored value
    OnboardingView()
        .onAppear {
            UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
        }
}
