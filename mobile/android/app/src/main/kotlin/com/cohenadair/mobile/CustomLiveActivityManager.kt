package com.cohenadair.mobile

import android.app.Notification
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import com.example.live_activities.LiveActivityManager

/// Note that this plugin requires API 26 so it can be assumed that nothing in this class
/// will be run on anything < API 26.
class CustomLiveActivityManager(context: Context) : LiveActivityManager(context) {
    private val context: Context = context.applicationContext

    private val pendingIntent = PendingIntent.getActivity(
        context, 200, Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
        }, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    private val remoteViews = RemoteViews(context.packageName, R.layout.live_activity)

    private fun updateRemoteViews(
        activityName: String,
    ) {
        remoteViews.setTextViewText(R.id.activity_name, activityName)
    }

    override suspend fun buildNotification(
        notification: Notification.Builder,
        event: String,
        data: Map<String, Any>
    ): Notification {
        val activityName = data["activity_name"] as String
        updateRemoteViews(activityName)

        return notification
            .setColor(context.getColor(R.color.app_theme))
            .setSmallIcon(R.drawable.ic_notification)
            .setOngoing(true)
            .setContentTitle(activityName)
            .setContentIntent(pendingIntent)
            .setStyle(Notification.DecoratedCustomViewStyle())
            .setCustomContentView(remoteViews) // TODO: Remove?
            .setCustomBigContentView(remoteViews)
            .setCategory(Notification.CATEGORY_EVENT)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .build()
    }
}
