package com.cohenadair.mobile

import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import androidx.test.core.app.ApplicationProvider
import com.example.live_activities.LiveActivityManagerHolder
import io.mockk.EqMatcher
import io.mockk.mockk
import io.mockk.mockkConstructor
import io.mockk.verify
import junit.framework.TestCase.assertEquals
import junit.framework.TestCase.assertNotNull
import junit.framework.TestCase.assertNull
import junit.framework.TestCase.assertTrue
import org.json.JSONArray
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [36])
class StopButtonReceiverTest {
    private lateinit var receiver: StopButtonReceiver
    private lateinit var context: Context
    private lateinit var prefs: SharedPreferences

    @Before
    fun setup() {
        context = ApplicationProvider.getApplicationContext()
        receiver = StopButtonReceiver()
        prefs = context.getSharedPreferences(
            "group.cohenadair.activitylog",
            Context.MODE_PRIVATE
        )
        prefs.edit().clear().commit()
        LiveActivityManagerHolder.instance = null
    }

    @Test
    fun testOnReceiveNoActivityId() {
        receiver.onReceive(context, Intent())

        // SharedPreferences should remain unchanged.
        assertNull(prefs.getString("ended_activity_ids", null))
    }

    @Test
    fun testOnReceiveEndedActivityIdAlreadyExists() {
        val manager = mockk<CustomLiveActivityManager>(relaxed = true)
        LiveActivityManagerHolder.instance = manager

        // Setup existing data.
        prefs
            .edit()
            .putString(
                "ended_activity_ids",
                JSONArray().apply { put("test-id") }.toString()
            )
            .commit()
        val expected = prefs.getString("ended_activity_ids", null)

        receiver.onReceive(context, Intent().apply {
            putExtra("activity_id", "test-id")
        })

        // SharedPreferences should remain unchanged.
        assertEquals(expected, prefs.getString("ended_activity_ids", null))

        // Live activity is ended.
        verify { manager.endActivity("test-id", emptyMap()) }
    }

    @Test
    fun testOnReceiveWithEmptyPreferences() {
        LiveActivityManagerHolder.instance = mockk<CustomLiveActivityManager>(relaxed = true)
        receiver.onReceive(context, Intent().apply {
            putExtra("activity_id", "test-id")
        })

        val result = prefs.getString("ended_activity_ids", null)
        assertNotNull(result)

        val array = JSONArray(result!!)
        assertEquals(1, array.length())
        assertTrue(array.getString(0).startsWith("test-id:"))
    }

    @Test
    fun testOnReceiveWithNonEmptyPreferences() {
        // Setup existing data.
        prefs
            .edit()
            .putString(
                "ended_activity_ids",
                JSONArray().apply { put("test-existing-id") }.toString()
            )
            .commit()

        val manager = mockk<CustomLiveActivityManager>(relaxed = true)
        LiveActivityManagerHolder.instance = manager

        receiver.onReceive(context, Intent().apply {
            putExtra("activity_id", "test-new-id")
        })

        val stored = prefs.getString("ended_activity_ids", null)
        assertNotNull(stored)

        val array = JSONArray(stored!!)
        assertEquals(2, array.length())
        assertEquals("test-existing-id", array.getString(0))
        assertTrue(array.getString(1).startsWith("test-new-id:"))
    }

    @Test
    fun testOnReceiveLiveActivityManagerExists() {
        val manager = mockk<CustomLiveActivityManager>(relaxed = true)
        LiveActivityManagerHolder.instance = manager

        receiver.onReceive(context, Intent().apply {
            putExtra("activity_id", "test-id")
        })

        verify { manager.endActivity("test-id", emptyMap()) }
    }

    @Test
    fun testOnReceiveLiveActivityManagerDoesNotExist() {
        // Holder instance intentionally null.
        LiveActivityManagerHolder.instance = null

        // Spy on constructor.
        mockkConstructor(CustomLiveActivityManager::class)

        receiver.onReceive(context, Intent().apply {
            putExtra("activity_id", "test-id")
        })

        verify {
            constructedWith<CustomLiveActivityManager>(EqMatcher(context))
                .endActivity("test-id", emptyMap())
        }
    }
}