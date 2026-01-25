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

// MARK: - Widget State Enums
enum WidgetState: String {
    case empty = "empty"
    case active = "active"
    case urgent = "urgent"
}

enum UrgencyLevel: String {
    case green = "green"
    case yellow = "yellow"
    case red = "red"
}

// MARK: - Widget Data Model
struct WidgetData {
    // Widget State (NEW)
    let state: WidgetState
    let urgencyLevel: UrgencyLevel?

    // Next Sweet Spot Data
    let nextSweetSpotTime: String
    let minutesRemaining: Int?
    let sweetSpotProgress: Double
    let confidenceScore: Int?

    // Today's Summary
    let totalSleepHours: Double
    let totalFeedingCount: Int
    let totalDiaperCount: Int

    // Next Action (Legacy)
    let nextActionType: String
    let nextActionTime: String
    let nextActionMinutes: Int

    // Lock Screen Data
    let nextFeedingTime: String

    static var placeholder: WidgetData {
        WidgetData(
            state: .active,
            urgencyLevel: .green,
            nextSweetSpotTime: "14:30",
            minutesRemaining: 52,
            sweetSpotProgress: 0.65,
            confidenceScore: 85,
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

        // Read widget state (NEW)
        let stateString = sharedDefaults?.string(forKey: "widget_state") ?? "empty"
        let state = WidgetState(rawValue: stateString) ?? .empty

        let urgencyString = sharedDefaults?.string(forKey: "widget_urgency_level")
        let urgencyLevel = urgencyString != nil ? UrgencyLevel(rawValue: urgencyString!) : nil

        let minutesRemaining = sharedDefaults?.object(forKey: "widget_minutes_remaining") as? Int
        let confidenceScore = sharedDefaults?.object(forKey: "widget_confidence_score") as? Int

        return WidgetData(
            state: state,
            urgencyLevel: urgencyLevel,
            nextSweetSpotTime: sharedDefaults?.string(forKey: "widget_next_sweet_spot_time") ?? "00:00",
            minutesRemaining: minutesRemaining,
            sweetSpotProgress: sharedDefaults?.double(forKey: "widget_sweet_spot_progress") ?? 0.0,
            confidenceScore: confidenceScore,
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

            // State-based content
            switch entry.widgetData.state {
            case .empty:
                EmptyStateView()
            case .active:
                ActiveStateView(widgetData: entry.widgetData)
            case .urgent:
                UrgentStateView(widgetData: entry.widgetData)
            }
        }
        .widgetURL(getDeepLinkURL(for: entry.widgetData.state))
    }

    // Helper to get deep link URL based on state
    private func getDeepLinkURL(for state: WidgetState) -> URL? {
        switch state {
        case .empty:
            return URL(string: "lulu://log-wake")
        case .active, .urgent:
            return URL(string: "lulu://log-sleep")
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("🌙")
                .font(.system(size: 36))

            Text("Find your\nbaby's\ngolden time")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            Text("Log wake time")
                .font(.system(size: 10, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .padding(.top, 4)
        }
        .padding(12)
    }
}

// MARK: - Active State View
struct ActiveStateView: View {
    let widgetData: WidgetData

    var body: some View {
        VStack(spacing: 12) {
            // Urgency indicator badge
            if let urgency = widgetData.urgencyLevel {
                HStack {
                    Spacer()
                    Circle()
                        .fill(getUrgencyColor(urgency))
                        .frame(width: 8, height: 8)
                        .padding(.trailing, 8)
                        .padding(.top, 8)
                }
            }

            Spacer()

            // Minutes remaining
            if let minutes = widgetData.minutesRemaining {
                Text("\(minutes)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("min left")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }

            // Sweet Spot Label
            Text("Next Sweet Spot")
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .padding(.top, 2)

            // Time
            Text(widgetData.nextSweetSpotTime)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)

            Spacer()
        }
    }

    private func getUrgencyColor(_ urgency: UrgencyLevel) -> Color {
        switch urgency {
        case .green:
            return Color(red: 0.4, green: 0.8, blue: 0.4) // Green
        case .yellow:
            return Color(red: 1.0, green: 0.84, blue: 0.0) // Yellow
        case .red:
            return Color(red: 1.0, green: 0.4, blue: 0.4) // Red
        }
    }
}

// MARK: - Urgent State View
struct UrgentStateView: View {
    let widgetData: WidgetData

    var body: some View {
        VStack(spacing: 10) {
            Text("💤")
                .font(.system(size: 36))

            Text("It's Sweet\nSpot time!")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            Text(widgetData.nextSweetSpotTime)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .padding(.top, 2)

            Text("Log sleep")
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))
                .padding(.top, 4)
        }
        .padding(12)
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

            switch entry.widgetData.state {
            case .empty:
                MediumEmptyStateView()
            case .active:
                MediumActiveStateView(widgetData: entry.widgetData)
            case .urgent:
                MediumUrgentStateView(widgetData: entry.widgetData)
            }
        }
    }
}

// MARK: - Medium Empty State
struct MediumEmptyStateView: View {
    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text("🌙")
                    .font(.system(size: 48))

                Text("Find your baby's\ngolden time")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineSpacing(4)

                Text("Tell us when your baby\nwoke up")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .lineSpacing(2)
            }

            Spacer()

            Link(destination: URL(string: "lulu://log-wake")!) {
                VStack(spacing: 6) {
                    Image(systemName: "sunrise.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)

                    Text("Log wake")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(width: 80, height: 80)
                .background(Color.white.opacity(0.15))
                .cornerRadius(16)
            }
        }
        .padding(20)
    }
}

// MARK: - Medium Active State
struct MediumActiveStateView: View {
    let widgetData: WidgetData

    var body: some View {
        HStack(spacing: 16) {
            // Sweet Spot Info (Left)
            VStack(alignment: .leading, spacing: 8) {
                // Urgency indicator
                HStack(spacing: 6) {
                    if let urgency = widgetData.urgencyLevel {
                        Circle()
                            .fill(getUrgencyColor(urgency))
                            .frame(width: 8, height: 8)
                    }
                    Text("Next Sweet Spot")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }

                if let minutes = widgetData.minutesRemaining {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(minutes)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("min left")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }

                Text(widgetData.nextSweetSpotTime)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)

                if let confidence = widgetData.confidenceScore {
                    Text("\(confidence)% confidence")
                        .font(.system(size: 10, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()
                .background(Color.white.opacity(0.2))

            // Today's Summary (Right)
            VStack(alignment: .leading, spacing: 8) {
                Text("Today")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))

                HStack(spacing: 4) {
                    Image(systemName: "bed.double.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.78, green: 0.67, blue: 0.90))
                    Text("\(String(format: "%.1f", widgetData.totalSleepHours))h")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                HStack(spacing: 4) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.44))
                    Text("\(widgetData.totalFeedingCount)×")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.60, green: 0.85, blue: 1.0))
                    Text("\(widgetData.totalDiaperCount)×")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                // Quick Actions
                HStack(spacing: 6) {
                    Link(destination: URL(string: "lulu://log-sleep")!) {
                        Image(systemName: "bed.double.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(6)
                    }

                    Link(destination: URL(string: "lulu://feeding")!) {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(6)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(16)
    }

    private func getUrgencyColor(_ urgency: UrgencyLevel) -> Color {
        switch urgency {
        case .green:
            return Color(red: 0.4, green: 0.8, blue: 0.4)
        case .yellow:
            return Color(red: 1.0, green: 0.84, blue: 0.0)
        case .red:
            return Color(red: 1.0, green: 0.4, blue: 0.4)
        }
    }
}

// MARK: - Medium Urgent State
struct MediumUrgentStateView: View {
    let widgetData: WidgetData

    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text("💤")
                    .font(.system(size: 48))

                Text("It's Sweet Spot\ntime!")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineSpacing(4)

                Text("This is when your baby\nfalls asleep most easily")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(2)

                Text(widgetData.nextSweetSpotTime)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))
            }

            Spacer()

            Link(destination: URL(string: "lulu://log-sleep")!) {
                VStack(spacing: 6) {
                    Image(systemName: "bed.double.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)

                    Text("Log sleep")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(width: 80, height: 80)
                .background(Color(red: 1.0, green: 0.4, blue: 0.4).opacity(0.3))
                .cornerRadius(16)
            }
        }
        .padding(20)
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
