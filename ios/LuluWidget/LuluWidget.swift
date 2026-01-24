//
//  LuluWidget.swift
//  LuluWidget
//
//  🎨 Lulu Home Screen Widgets - Apple WidgetKit
//  Intelligent baby tracking widgets with Midnight Blue glassmorphism design
//

import WidgetKit
import SwiftUI

// MARK: - Widget Entry
struct LuluWidgetEntry: TimelineEntry {
    let date: Date
    let widgetData: WidgetData
}

// MARK: - Widget Data Model
struct WidgetData {
    // Next Sweet Spot Data
    let nextSweetSpotTime: String
    let minutesUntilSweetSpot: Int
    let sweetSpotProgress: Double
    let isUrgent: Bool

    // Today's Summary
    let totalSleepHours: Double
    let totalFeedingCount: Int
    let totalDiaperCount: Int

    // Next Action
    let nextActionType: String // "sleep" or "feeding"
    let nextActionTime: String
    let nextActionMinutes: Int

    // Lock Screen Data
    let nextFeedingTime: String

    static var placeholder: WidgetData {
        WidgetData(
            nextSweetSpotTime: "14:30",
            minutesUntilSweetSpot: 52,
            sweetSpotProgress: 0.65,
            isUrgent: false,
            totalSleepHours: 12.5,
            totalFeedingCount: 8,
            totalDiaperCount: 6,
            nextActionType: "sleep",
            nextActionTime: "14:30",
            nextActionMinutes: 52,
            nextFeedingTime: "15:45"
        )
    }
}

// MARK: - Timeline Provider
struct LuluWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> LuluWidgetEntry {
        LuluWidgetEntry(date: Date(), widgetData: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (LuluWidgetEntry) -> Void) {
        let entry = LuluWidgetEntry(date: Date(), widgetData: loadWidgetData())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LuluWidgetEntry>) -> Void) {
        let currentDate = Date()
        let widgetData = loadWidgetData()
        let entry = LuluWidgetEntry(date: currentDate, widgetData: widgetData)

        // Determine next update time based on urgency
        let updateInterval: TimeInterval
        if widgetData.minutesUntilSweetSpot < 15 {
            updateInterval = 5 * 60 // 5 minutes
        } else if widgetData.minutesUntilSweetSpot < 30 {
            updateInterval = 10 * 60 // 10 minutes
        } else {
            updateInterval = 15 * 60 // 15 minutes
        }

        let nextUpdate = currentDate.addingTimeInterval(updateInterval)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    // Load widget data from HomeWidget shared preferences
    private func loadWidgetData() -> WidgetData {
        let sharedDefaults = UserDefaults(suiteName: "group.com.lulu.babytracker")

        return WidgetData(
            nextSweetSpotTime: sharedDefaults?.string(forKey: "widget_next_sweet_spot_time") ?? "00:00",
            minutesUntilSweetSpot: sharedDefaults?.integer(forKey: "widget_minutes_until_sweet_spot") ?? 0,
            sweetSpotProgress: sharedDefaults?.double(forKey: "widget_sweet_spot_progress") ?? 0.0,
            isUrgent: sharedDefaults?.bool(forKey: "widget_is_urgent") ?? false,
            totalSleepHours: sharedDefaults?.double(forKey: "widget_total_sleep_hours") ?? 0.0,
            totalFeedingCount: sharedDefaults?.integer(forKey: "widget_total_feeding_count") ?? 0,
            totalDiaperCount: sharedDefaults?.integer(forKey: "widget_total_diaper_count") ?? 0,
            nextActionType: sharedDefaults?.string(forKey: "widget_next_action_type") ?? "sleep",
            nextActionTime: sharedDefaults?.string(forKey: "widget_next_action_time") ?? "00:00",
            nextActionMinutes: sharedDefaults?.integer(forKey: "widget_next_action_minutes") ?? 0,
            nextFeedingTime: sharedDefaults?.string(forKey: "widget_next_feeding_time") ?? "00:00"
        )
    }
}

// MARK: - Small Widget View (2x2)
struct SmallWidgetView: View {
    let entry: LuluWidgetEntry

    var body: some View {
        ZStack {
            // Glassmorphism background
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.12, blue: 0.23).opacity(0.95), // Midnight Blue
                    Color(red: 0.18, green: 0.20, blue: 0.32).opacity(0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 12) {
                // Circular Progress Gauge
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 4)
                        .frame(width: 60, height: 60)

                    Circle()
                        .trim(from: 0, to: CGFloat(entry.widgetData.sweetSpotProgress))
                        .stroke(
                            Color(red: 0.78, green: 0.67, blue: 0.90), // Lavender Mist
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))

                    Text("\(entry.widgetData.minutesUntilSweetSpot)m")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                // Sweet Spot Label
                Text("Next Sweet Spot")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))

                // Time
                Text(entry.widgetData.nextSweetSpotTime)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .widgetURL(URL(string: "lulu://sleep"))
    }
}

// MARK: - Medium Widget View (4x2)
struct MediumWidgetView: View {
    let entry: LuluWidgetEntry

    var body: some View {
        ZStack {
            // Glassmorphism background
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.12, blue: 0.23).opacity(0.95),
                    Color(red: 0.18, green: 0.20, blue: 0.32).opacity(0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            HStack(spacing: 16) {
                // Today's Summary (Left Side)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))

                    HStack(spacing: 4) {
                        Image(systemName: "bed.double.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.78, green: 0.67, blue: 0.90))
                        Text("\(String(format: "%.1f", entry.widgetData.totalSleepHours))h")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.44))
                        Text("\(entry.widgetData.totalFeedingCount)×")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.60, green: 0.85, blue: 1.0))
                        Text("\(entry.widgetData.totalDiaperCount)×")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider()
                    .background(Color.white.opacity(0.2))

                // Next Action (Right Side)
                VStack(spacing: 8) {
                    Text(entry.widgetData.nextActionType == "sleep" ? "Next Sleep" : "Next Feed")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))

                    Text(entry.widgetData.nextActionTime)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("in \(entry.widgetData.nextActionMinutes)m")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(entry.widgetData.isUrgent ? Color(red: 1.0, green: 0.44, blue: 0.44) : Color.white.opacity(0.8))

                    // Action Buttons
                    HStack(spacing: 8) {
                        Link(destination: URL(string: "lulu://sleep")!) {
                            Image(systemName: "bed.double.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(8)
                        }

                        Link(destination: URL(string: "lulu://feeding")!) {
                            Image(systemName: "drop.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(8)
                        }

                        Link(destination: URL(string: "lulu://diaper")!) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(8)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(16)
        }
    }
}

// MARK: - Lock Screen Widget View
struct LockScreenWidgetView: View {
    let entry: LuluWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Next Feed")
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(.secondary)

            Text(entry.widgetData.nextFeedingTime)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
        }
        .widgetURL(URL(string: "lulu://feeding"))
    }
}

// MARK: - Widget Configuration
@main
struct LuluWidgetBundle: WidgetBundle {
    var body: some Widget {
        LuluSmallWidget()
        LuluMediumWidget()
        LuluLockScreenWidget()
    }
}

struct LuluSmallWidget: Widget {
    let kind: String = "LuluSmallWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LuluWidgetProvider()) { entry in
            SmallWidgetView(entry: entry)
        }
        .configurationDisplayName("Next Sweet Spot")
        .description("See when your baby is ready to sleep.")
        .supportedFamilies([.systemSmall])
    }
}

struct LuluMediumWidget: Widget {
    let kind: String = "LuluMediumWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LuluWidgetProvider()) { entry in
            MediumWidgetView(entry: entry)
        }
        .configurationDisplayName("Daily Summary")
        .description("Today's activities and next action.")
        .supportedFamilies([.systemMedium])
    }
}

struct LuluLockScreenWidget: Widget {
    let kind: String = "LuluLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LuluWidgetProvider()) { entry in
            LockScreenWidgetView(entry: entry)
        }
        .configurationDisplayName("Next Feeding")
        .description("Quick glance at next feeding time.")
        .supportedFamilies([.accessoryRectangular])
    }
}
