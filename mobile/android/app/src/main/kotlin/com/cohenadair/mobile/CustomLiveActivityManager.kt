package com.cohenadair.mobile

import android.app.Notification
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import android.widget.RemoteViews
import com.example.live_activities.LiveActivityManager

/// Note that this plugin requires API 26 so it can be assumed that nothing in this class
/// will be run on anything < API 26.
class CustomLiveActivityManager(context: Context) : LiveActivityManager(context) {
    private val intentFlags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    private val context = context.applicationContext
    private var activityId = ""

    private val contentIntent = PendingIntent.getActivity(
        context, 200, Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
        }, intentFlags
    )

    private val remoteViews = RemoteViews(context.packageName, R.layout.live_activity)

    private fun stopActivityIntent() = PendingIntent.getBroadcast(
        context, 200, Intent(context, StopButtonReceiver::class.java).apply {
            putExtra("activity_id", activityId)
        }, intentFlags
    )

    private fun updateRemoteViews(data: Map<String, Any>) {
        activityId = data["activity_id"] as String
        remoteViews.setChronometer(
            R.id.timer,
            SystemClock.elapsedRealtime()
                    - (System.currentTimeMillis() - data["session_start_timestamp"] as Long),
            null,
            true
        )
        remoteViews.setTextViewText(R.id.activity_name, data["activity_name"] as String)
        remoteViews.setOnClickPendingIntent(R.id.stop_button, stopActivityIntent())
    }

    override suspend fun buildNotification(
        notification: Notification.Builder,
        event: String,
        data: Map<String, Any>
    ): Notification {
        updateRemoteViews(data)
        return notification
            .setColor(context.getColor(R.color.app_theme))
            .setSmallIcon(R.drawable.ic_notification)
            .setOngoing(true)
            .setContentIntent(contentIntent)
            .setStyle(Notification.DecoratedCustomViewStyle())
            .setCustomContentView(remoteViews)
            .setCategory(Notification.CATEGORY_EVENT)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .build()
    }
}
