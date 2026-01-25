package com.lulu.babytracker

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * 🎨 Lulu Home Screen Widgets - Android AppWidget
 * Intelligent baby tracking widgets with Midnight Blue glassmorphism design
 */
class LuluWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val PREFS_NAME = "HomeWidgetPreferences"
        private const val ACTION_SLEEP = "com.lulu.babytracker.SLEEP"
        private const val ACTION_LOG_WAKE = "com.lulu.babytracker.LOG_WAKE"
        private const val ACTION_LOG_SLEEP = "com.lulu.babytracker.LOG_SLEEP"
        private const val ACTION_FEEDING = "com.lulu.babytracker.FEEDING"
        private const val ACTION_DIAPER = "com.lulu.babytracker.DIAPER"
        private const val ACTION_OPEN_APP = "com.lulu.babytracker.OPEN_APP"

        // Midnight Blue Colors
        private const val MIDNIGHT_BLUE_START = "#FF1A1F3A"
        private const val MIDNIGHT_BLUE_END = "#FF2D3351"
        private const val LAVENDER_MIST = "#FFC7ABE6"
        private const val WARNING_SOFT = "#FFFFD670"
        private const val INFO_SOFT = "#FF99D9FF"
        private const val GREEN_URGENCY = "#FF66CC66"
        private const val YELLOW_URGENCY = "#FFFFD670"
        private const val RED_URGENCY = "#FFFF6666"
    }

    // Widget State Enum
    enum class WidgetState {
        EMPTY, ACTIVE, URGENT;

        companion object {
            fun fromString(value: String?): WidgetState {
                return when (value?.lowercase()) {
                    "empty" -> EMPTY
                    "active" -> ACTIVE
                    "urgent" -> URGENT
                    else -> EMPTY
                }
            }
        }
    }

    // Urgency Level Enum
    enum class UrgencyLevel {
        GREEN, YELLOW, RED;

        companion object {
            fun fromString(value: String?): UrgencyLevel? {
                return when (value?.lowercase()) {
                    "green" -> GREEN
                    "yellow" -> YELLOW
                    "red" -> RED
                    else -> null
                }
            }
        }

        fun getColor(): String {
            return when (this) {
                GREEN -> GREEN_URGENCY
                YELLOW -> YELLOW_URGENCY
                RED -> RED_URGENCY
            }
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        when (intent.action) {
            ACTION_LOG_WAKE -> {
                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    putExtra("widget_action", "log-wake")
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                }
                context.startActivity(launchIntent)
            }
            ACTION_LOG_SLEEP, ACTION_SLEEP -> {
                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    putExtra("widget_action", "log-sleep")
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                }
                context.startActivity(launchIntent)
            }
            ACTION_FEEDING -> {
                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    putExtra("widget_action", "feeding")
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                }
                context.startActivity(launchIntent)
            }
            ACTION_DIAPER -> {
                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    putExtra("widget_action", "diaper")
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                }
                context.startActivity(launchIntent)
            }
            ACTION_OPEN_APP -> {
                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                }
                context.startActivity(launchIntent)
            }
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val widgetData = loadWidgetData(context)
        val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
        val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)

        val views = when {
            minWidth < 200 -> createSmallWidget(context, widgetData)
            else -> createMediumWidget(context, widgetData)
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun loadWidgetData(context: Context): WidgetData {
        val prefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        // Read widget state (NEW)
        val state = WidgetState.fromString(prefs.getString("widget_state", "empty"))
        val urgencyLevel = UrgencyLevel.fromString(prefs.getString("widget_urgency_level", null))
        val minutesRemaining = if (prefs.contains("widget_minutes_remaining"))
            prefs.getInt("widget_minutes_remaining", 0) else null
        val confidenceScore = if (prefs.contains("widget_confidence_score"))
            prefs.getInt("widget_confidence_score", 0) else null

        return WidgetData(
            state = state,
            urgencyLevel = urgencyLevel,
            minutesRemaining = minutesRemaining,
            confidenceScore = confidenceScore,
            nextSweetSpotTime = prefs.getString("widget_next_sweet_spot_time", "00:00") ?: "00:00",
            sweetSpotProgress = prefs.getFloat("widget_sweet_spot_progress", 0f).toDouble(),
            totalSleepHours = prefs.getFloat("widget_total_sleep_hours", 0f).toDouble(),
            totalFeedingCount = prefs.getInt("widget_total_feeding_count", 0),
            totalDiaperCount = prefs.getInt("widget_total_diaper_count", 0),
            nextActionType = prefs.getString("widget_next_action_type", "sleep") ?: "sleep",
            nextActionTime = prefs.getString("widget_next_action_time", "00:00") ?: "00:00",
            nextActionMinutes = prefs.getInt("widget_next_action_minutes", 0),
            nextFeedingTime = prefs.getString("widget_next_feeding_time", "00:00") ?: "00:00"
        )
    }

    private fun createSmallWidget(context: Context, data: WidgetData): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_small)

        when (data.state) {
            WidgetState.EMPTY -> {
                // Empty State: Show "Find your baby's golden time"
                views.setViewVisibility(R.id.empty_state_container, android.view.View.VISIBLE)
                views.setViewVisibility(R.id.active_state_container, android.view.View.GONE)
                views.setViewVisibility(R.id.urgent_state_container, android.view.View.GONE)

                views.setTextViewText(R.id.empty_header, "🌙")
                views.setTextViewText(R.id.empty_title, "Find your\nbaby's\ngolden time")
                views.setTextViewText(R.id.empty_subtitle, "Log wake time")

                // Set click intent to log wake
                val intent = Intent(context, LuluWidgetProvider::class.java).apply {
                    action = ACTION_LOG_WAKE
                }
                val pendingIntent = PendingIntent.getBroadcast(
                    context, 0, intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }

            WidgetState.ACTIVE -> {
                // Active State: Show countdown with urgency indicator
                views.setViewVisibility(R.id.empty_state_container, android.view.View.GONE)
                views.setViewVisibility(R.id.active_state_container, android.view.View.VISIBLE)
                views.setViewVisibility(R.id.urgent_state_container, android.view.View.GONE)

                // Set urgency indicator color
                data.urgencyLevel?.let { urgency ->
                    views.setInt(R.id.urgency_indicator, "setBackgroundColor",
                        Color.parseColor(urgency.getColor()))
                }

                // Set minutes remaining
                data.minutesRemaining?.let { minutes ->
                    views.setTextViewText(R.id.minutes_text, "$minutes")
                    views.setTextViewText(R.id.minutes_label, "min left")
                }

                views.setTextViewText(R.id.sweet_spot_label, "Next Sweet Spot")
                views.setTextViewText(R.id.sweet_spot_time_text, data.nextSweetSpotTime)

                // Set confidence score
                data.confidenceScore?.let { confidence ->
                    views.setTextViewText(R.id.confidence_text, "$confidence% confidence")
                }

                // Set click intent to log sleep
                val intent = Intent(context, LuluWidgetProvider::class.java).apply {
                    action = ACTION_LOG_SLEEP
                }
                val pendingIntent = PendingIntent.getBroadcast(
                    context, 0, intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }

            WidgetState.URGENT -> {
                // Urgent State: Show "It's Sweet Spot time!"
                views.setViewVisibility(R.id.empty_state_container, android.view.View.GONE)
                views.setViewVisibility(R.id.active_state_container, android.view.View.GONE)
                views.setViewVisibility(R.id.urgent_state_container, android.view.View.VISIBLE)

                views.setTextViewText(R.id.urgent_emoji, "💤")
                views.setTextViewText(R.id.urgent_title, "It's Sweet\nSpot time!")
                views.setTextViewText(R.id.urgent_time, data.nextSweetSpotTime)
                views.setTextViewText(R.id.urgent_action, "Log sleep")

                // Set click intent to log sleep
                val intent = Intent(context, LuluWidgetProvider::class.java).apply {
                    action = ACTION_LOG_SLEEP
                }
                val pendingIntent = PendingIntent.getBroadcast(
                    context, 0, intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }
        }

        return views
    }

    private fun createMediumWidget(context: Context, data: WidgetData): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_medium)

        when (data.state) {
            WidgetState.EMPTY -> {
                // Empty State: Show "Find your baby's golden time" with action button
                views.setViewVisibility(R.id.empty_state_container, android.view.View.VISIBLE)
                views.setViewVisibility(R.id.active_state_container, android.view.View.GONE)
                views.setViewVisibility(R.id.urgent_state_container, android.view.View.GONE)

                views.setTextViewText(R.id.empty_emoji, "🌙")
                views.setTextViewText(R.id.empty_title, "Find your baby's\ngolden time")
                views.setTextViewText(R.id.empty_body, "Tell us when your baby\nwoke up")

                // Log wake button
                val wakeIntent = createActionIntent(context, ACTION_LOG_WAKE)
                views.setOnClickPendingIntent(R.id.log_wake_button, wakeIntent)
            }

            WidgetState.ACTIVE -> {
                // Active State: Show Sweet Spot info + Today's summary
                views.setViewVisibility(R.id.empty_state_container, android.view.View.GONE)
                views.setViewVisibility(R.id.active_state_container, android.view.View.VISIBLE)
                views.setViewVisibility(R.id.urgent_state_container, android.view.View.GONE)

                // Sweet Spot Info (Left)
                data.urgencyLevel?.let { urgency ->
                    views.setInt(R.id.urgency_indicator, "setBackgroundColor",
                        Color.parseColor(urgency.getColor()))
                }

                views.setTextViewText(R.id.sweet_spot_header, "Next Sweet Spot")

                data.minutesRemaining?.let { minutes ->
                    views.setTextViewText(R.id.minutes_large, "$minutes")
                    views.setTextViewText(R.id.minutes_label, "min left")
                }

                views.setTextViewText(R.id.sweet_spot_time, data.nextSweetSpotTime)

                data.confidenceScore?.let { confidence ->
                    views.setTextViewText(R.id.confidence_text, "$confidence% confidence")
                }

                // Today's Summary (Right)
                views.setTextViewText(R.id.today_header, "Today")
                views.setTextViewText(R.id.sleep_hours_text, String.format("%.1fh", data.totalSleepHours))
                views.setTextViewText(R.id.feeding_count_text, "${data.totalFeedingCount}×")
                views.setTextViewText(R.id.diaper_count_text, "${data.totalDiaperCount}×")

                // Action buttons
                val sleepIntent = createActionIntent(context, ACTION_LOG_SLEEP)
                views.setOnClickPendingIntent(R.id.sleep_button, sleepIntent)

                val feedingIntent = createActionIntent(context, ACTION_FEEDING)
                views.setOnClickPendingIntent(R.id.feeding_button, feedingIntent)
            }

            WidgetState.URGENT -> {
                // Urgent State: Show "It's Sweet Spot time!" with prominent action
                views.setViewVisibility(R.id.empty_state_container, android.view.View.GONE)
                views.setViewVisibility(R.id.active_state_container, android.view.View.GONE)
                views.setViewVisibility(R.id.urgent_state_container, android.view.View.VISIBLE)

                views.setTextViewText(R.id.urgent_emoji, "💤")
                views.setTextViewText(R.id.urgent_title, "It's Sweet Spot\ntime!")
                views.setTextViewText(R.id.urgent_body, "This is when your baby\nfalls asleep most easily")
                views.setTextViewText(R.id.urgent_time_display, data.nextSweetSpotTime)

                // Log sleep button
                val sleepIntent = createActionIntent(context, ACTION_LOG_SLEEP)
                views.setOnClickPendingIntent(R.id.log_sleep_button, sleepIntent)
            }
        }

        return views
    }

    private fun createActionIntent(context: Context, action: String): PendingIntent {
        val intent = Intent(context, LuluWidgetProvider::class.java).apply {
            this.action = action
        }
        return PendingIntent.getBroadcast(
            context,
            action.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    data class WidgetData(
        // Widget State (NEW)
        val state: WidgetState,
        val urgencyLevel: UrgencyLevel?,
        val minutesRemaining: Int?,
        val confidenceScore: Int?,

        // Sweet Spot Data
        val nextSweetSpotTime: String,
        val sweetSpotProgress: Double,

        // Today's Summary
        val totalSleepHours: Double,
        val totalFeedingCount: Int,
        val totalDiaperCount: Int,

        // Legacy fields (for backward compatibility)
        val nextActionType: String,
        val nextActionTime: String,
        val nextActionMinutes: Int,
        val nextFeedingTime: String
    )
}
