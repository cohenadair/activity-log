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
    companion object {
        const val EXTRA_ACTIVITY_ID = "activity_id"
        const val EXTRA_ACTIVITY_NAME = "activity_name"

        private const val TAG = "StopButtonReceiver"
        private const val KEY_ENDED_ACTIVITY_IDS = "ended_activity_ids"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val endedId = intent.getStringExtra(EXTRA_ACTIVITY_ID) ?: ""
        if (endedId.isEmpty()) {
            Log.d(TAG, "[Android] No activity ID provided")
            return
        }

        val debugName = "${intent.getStringExtra(EXTRA_ACTIVITY_ID) ?: ""}=$endedId"
        val prefs = context.getSharedPreferences(
            "group.cohenadair.activitylog",
            Context.MODE_PRIVATE
        )

        val currentIds = prefs.getString(KEY_ENDED_ACTIVITY_IDS, null)
        if (currentIds != null && currentIds.contains(endedId)) {
            Log.d(TAG, "[Android] Ended activity ($debugName) already exists in shared data")
            clearNotification(context, endedId) // End for good measure.
            return
        }

        val newIds = if (currentIds == null || currentIds.isEmpty()) {
            JSONArray()
        } else {
            JSONArray(currentIds)
        }

        newIds.put("$endedId:${Date().time}")
        Log.d(TAG, "[Android] Added activity $($debugName) to ended IDs")
        Log.d(TAG, "[Android] New ended activities in group data: $newIds")

        prefs.edit(commit = true) {
            putString(KEY_ENDED_ACTIVITY_IDS, newIds.toString())
        }
        clearNotification(context, endedId)
    }

    private fun clearNotification(context: Context, endedId: String) {
        val manager = if (LiveActivityManagerHolder.instance == null) {
            CustomLiveActivityManager(context)
        } else {
            LiveActivityManagerHolder.instance as CustomLiveActivityManager
        }
        manager.endActivity(endedId, emptyMap())
    }
}