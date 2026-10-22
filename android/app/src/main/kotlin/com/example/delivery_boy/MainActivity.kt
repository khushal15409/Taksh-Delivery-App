package com.example.delivery_boy

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createPushChannel()
    }

    /**
     * The channel push notifications are shown on (Android 8+). It must exist before a push
     * arrives; the id matches the manifest's default_notification_channel_id and the server's
     * FCM_ANDROID_CHANNEL_ID.
     */
    private fun createPushChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(NotificationManager::class.java) ?: return
        val channel = NotificationChannel(
            "taksh_orders",
            "Delivery updates",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Messages and updates from Taksh for delivery partners"
            enableLights(true)
            lightColor = 0xFFFFA340.toInt()
            enableVibration(true)
            setShowBadge(true)
        }
        manager.createNotificationChannel(channel)
    }
}
