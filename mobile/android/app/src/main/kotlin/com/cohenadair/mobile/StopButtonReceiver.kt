package com.cohenadair.mobile

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.example.live_activities.LiveActivityManagerHolder
import io.flutter.Log
import androidx.core.content.edit
import org.json.JSONArray
import java.util.Date

class StopButtonReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val endedId = intent.getStringExtra("activity_id") ?: ""
        if (endedId.isEmpty()) {
            Log.d("StopButtonReceiver", "[Android] No activity ID provided")
            return
        }

        val prefs = context.getSharedPreferences(
            "group.cohenadair.activitylog",
            Context.MODE_PRIVATE
        )

        val currentIds = prefs.getString("ended_activity_ids", null)
        val newIds = if (currentIds == null || currentIds.isEmpty()) {
            JSONArray()
        } else {
            JSONArray(currentIds)
        }

        newIds.put("$endedId:${Date().time}")
        Log.d("StopButtonReceiver", "[Android] Setting ended activities in group data to $newIds")

        prefs.edit(commit = true) {
            putString("ended_activity_ids", newIds.toString())
        }

        // Clear the notification.
        val manager = if (LiveActivityManagerHolder.instance != null) {
            LiveActivityManagerHolder.instance as CustomLiveActivityManager
        } else {
            CustomLiveActivityManager(context)
        }
        manager.endActivity(endedId, emptyMap())
    }
}