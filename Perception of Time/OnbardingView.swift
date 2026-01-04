import SwiftUI

struct OnboardingStep: Identifiable {
    let id = UUID()
    let text: String
}

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0

    private let steps = [
        OnboardingStep(text: "We mark the time evenly. But we don’t perceive it like that."),
        OnboardingStep(text: "A deep sleep from midnight to 7am would pass quickly."),
        OnboardingStep(text: "But a boring one-hour meeting at 9am meeting would drag."),
        OnboardingStep(text: "How do you perceive the time?"),
    ]

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(0..<steps.count, id: \.self) { index in
                    VStack(spacing: 20) {
                        Spacer()
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
                                    .background(Color.primary)
                                    //.foregroundColor(.black)
                                    .cornerRadius(0)
                                    .padding(.horizontal, 40)
                            }
                        }
                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .tint(Color.accentColor)
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

