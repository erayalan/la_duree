//
//  PerceptionOfTimeWidget.swift
//  PerceptionOfTimeWidget
//
//  Created by eray.alan on 7/30/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), positions: loadPositions())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(SimpleEntry(date: Date(), positions: loadPositions()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        print("📌 getTimeline called at \(Date())")

        var entries: [SimpleEntry] = []

        let currentDate = Date()
        for minuteOffset in 0..<60 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            print("🔄 Adding entry for \(entryDate)")
            let entry = SimpleEntry(date: entryDate, positions: loadPositions())
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        print("✅ Timeline created with \(entries.count) entries. First: \(entries.first!.date), Last: \(entries.last!.date)")
        completion(timeline)
    }



    private func loadPositions() -> [Int: Double] {
        let suiteName = "group.com.ThisOrThat.PerceptionOfTime"
        let defaults = UserDefaults(suiteName: suiteName)
        let key = Calendar.current.component(.hour, from: Date()) < 12 ? "AMClockPositions" : "PMClockPositions"
        if let data = defaults?.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Int: Double].self, from: data) {
            return decoded
        }
        return (1...12).reduce(into: [Int: Double]()) { $0[$1] = Double($1) * 30 }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let positions: [Int: Double]
}

struct PerceptionOfTimeWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        SharedClockView(positions: entry.positions, date: entry.date)
    }
}


struct PerceptionOfTimeWidget: Widget {
    let kind: String = "PerceptionOfTimeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                PerceptionOfTimeWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                PerceptionOfTimeWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}
