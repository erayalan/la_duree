# La Durée

> A clock that bends to match how time actually feels

## What is this?

**La Durée** (French for "the duration") is an iOS app that lets you create a personal clock based on your subjective experience of time. Because let's be honest - traditional clocks lie. They tell us every hour is the same length, but we all know that's not how it feels.

A 7-hour sleep? Gone in a flash. A 1-hour boring meeting? An eternity.

With La Durée, you can stretch and shrink each hour to match your reality.

## Features

### Interactive Clock Customization
- **Drag hour markers** to compress or expand time periods
- **Haptic feedback** so you can feel each adjustment
- **AM/PM support** for different time perceptions throughout the day
- Hours snap to precise 6-degree increments for smooth adjustments

### Home Screen Widgets
Pin your personalized clock to your iPhone home screen and see time the way *you* experience it, all day long.

### Beautiful Design
Clean, minimal interface that puts your custom time perception front and center.

## How It Works

1. **Drag any hour marker** (except 12 o'clock, which stays fixed)
2. Stretch hours that feel long, shrink hours that fly by
3. Switch between AM and PM to customize different parts of your day
4. The clock hands move through your warped time, showing you the current moment in your personal timeline

## The Philosophy

Traditional clocks divide time into equal segments. But our brains don't work that way. Time perception is subjective, influenced by:
- How engaged we are
- How much we're enjoying (or dreading) something
- Our energy levels
- Repetition vs. novelty

La Durée acknowledges this reality. It's a clock that reflects the human experience of time, not just the mechanical measurement of it.

## Technical Details

- Built with **SwiftUI** for iOS
- Includes **WidgetKit** integration for home screen widgets
- Interactive gesture-based interface with boundary constraints
- Persistent settings that sync across app and widgets
- Smooth animations and real-time clock updates

## Getting Started

1. Clone this repository
2. Open `Perception of Time.xcodeproj` in Xcode
3. Build and run on your iOS device or simulator
4. Go through the onboarding to understand the concept
5. Start customizing your perception of time!

## Project Structure

```
Perception of Time/
├── Perception_of_TimeApp.swift    # Main app entry point
├── ContentView.swift              # Main view container
├── AnalogClockView.swift          # Interactive clock interface
├── OnboardingView.swift           # First-time user experience
├── ClockSettings.swift            # Persistent clock configuration
└── PerceptionOfTimeWidget/        # Home screen widget implementation
    ├── PerceptionOfTimeWidget.swift
    ├── SharedClockView.swift
    └── ...
```

## Requirements

- iOS 16.0+
- Xcode 14.0+
- Swift 5.5+

## Why "La Durée"?

The name comes from French philosopher Henri Bergson's concept of "durée" - lived time as opposed to measured time. Bergson argued that real time is experienced subjectively and can't be fully captured by clocks and calendars. This app is a playful exploration of that idea.

## Contributing

Found a bug? Have an idea? Feel free to open an issue or submit a pull request!

## License

[Add your license here]

---

*"Time flies when you're having fun, and drags when you're not. So why shouldn't your clock reflect that?"*
