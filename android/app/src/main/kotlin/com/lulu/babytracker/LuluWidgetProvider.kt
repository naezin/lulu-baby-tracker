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
        private const val ACTION_FEEDING = "com.lulu.babytracker.FEEDING"
        private const val ACTION_DIAPER = "com.lulu.babytracker.DIAPER"
        private const val ACTION_OPEN_APP = "com.lulu.babytracker.OPEN_APP"

        // Midnight Blue Colors
        private const val MIDNIGHT_BLUE_START = "#FF1A1F3A"
        private const val MIDNIGHT_BLUE_END = "#FF2D3351"
        private const val LAVENDER_MIST = "#FFC7ABE6"
        private const val WARNING_SOFT = "#FFFFD670"
        private const val INFO_SOFT = "#FF99D9FF"
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
            ACTION_SLEEP -> {
                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    putExtra("widget_action", "sleep")
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

        return WidgetData(
            nextSweetSpotTime = prefs.getString("widget_next_sweet_spot_time", "00:00") ?: "00:00",
            minutesUntilSweetSpot = prefs.getInt("widget_minutes_until_sweet_spot", 0),
            sweetSpotProgress = prefs.getFloat("widget_sweet_spot_progress", 0f).toDouble(),
            isUrgent = prefs.getBoolean("widget_is_urgent", false),
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

        // Set widget data
        views.setTextViewText(R.id.minutes_text, "${data.minutesUntilSweetSpot}m")
        views.setTextViewText(R.id.sweet_spot_time_text, data.nextSweetSpotTime)

        // Set progress (circular progress requires custom view or approximation)
        val progressPercent = (data.sweetSpotProgress * 100).toInt()
        views.setProgressBar(R.id.progress_bar, 100, progressPercent, false)

        // Set click intent
        val intent = Intent(context, LuluWidgetProvider::class.java).apply {
            action = ACTION_SLEEP
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

        return views
    }

    private fun createMediumWidget(context: Context, data: WidgetData): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_medium)

        // Today's Summary
        views.setTextViewText(R.id.sleep_hours_text, String.format("%.1fh", data.totalSleepHours))
        views.setTextViewText(R.id.feeding_count_text, "${data.totalFeedingCount}×")
        views.setTextViewText(R.id.diaper_count_text, "${data.totalDiaperCount}×")

        // Next Action
        val nextActionLabel = if (data.nextActionType == "sleep") "Next Sleep" else "Next Feed"
        views.setTextViewText(R.id.next_action_label, nextActionLabel)
        views.setTextViewText(R.id.next_action_time, data.nextActionTime)
        views.setTextViewText(R.id.next_action_minutes, "in ${data.nextActionMinutes}m")

        // Set urgent color if needed
        if (data.isUrgent) {
            views.setTextColor(R.id.next_action_minutes, Color.parseColor("#FFFF7070"))
        }

        // Action button intents
        val sleepIntent = createActionIntent(context, ACTION_SLEEP)
        views.setOnClickPendingIntent(R.id.sleep_button, sleepIntent)

        val feedingIntent = createActionIntent(context, ACTION_FEEDING)
        views.setOnClickPendingIntent(R.id.feeding_button, feedingIntent)

        val diaperIntent = createActionIntent(context, ACTION_DIAPER)
        views.setOnClickPendingIntent(R.id.diaper_button, diaperIntent)

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
        val nextSweetSpotTime: String,
        val minutesUntilSweetSpot: Int,
        val sweetSpotProgress: Double,
        val isUrgent: Boolean,
        val totalSleepHours: Double,
        val totalFeedingCount: Int,
        val totalDiaperCount: Int,
        val nextActionType: String,
        val nextActionTime: String,
        val nextActionMinutes: Int,
        val nextFeedingTime: String
    )
}
