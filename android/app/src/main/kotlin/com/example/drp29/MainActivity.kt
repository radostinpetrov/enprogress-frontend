package com.example.drp29

import io.flutter.embedding.android.FlutterActivity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.app.NotificationManager









class MainActivity : FlutterActivity() {
    private val CHANNEL = "flutter/enprogress"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getBatteryLevel") {
                val batteryLevel = getBatteryLevel()

                if (batteryLevel != -1) {
                    result.success(batteryLevel)
                } else {
                    result.error("UNAVAILABLE", "Battery level not available.", null)
                }
            } else if (call.method == "turnWorkModeOn") {

                /*val requestPermissions = registerForActivityResult(RequestMultiplePermissions()
                ) { result ->
                    // the result from RequestMultiplePermissions is a map linking each
                    // request permission to a boolean of whether it is GRANTED

                    // check if the permission is granted
                    if (result[Manifest.permission.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS]) {
                        // it was granted
                    } else {
                        // it was not granted
                    }
                }
                when {
                    ContextCompat.checkSelfPermission(
                            CONTEXT,
                            Manifest.permission.REQUESTED_PERMISSION
                    ) == PackageManager.PERMISSION_GRANTED -> {
                        // You can use the API that requires the permission.
                        performAction(...)
                    }
                    shouldShowRequestPermissionRationale(...) -> {
                    // In an educational UI, explain to the user why your app requires this
                    // permission for a specific feature to behave as expected. In this UI,
                    // include a "cancel" or "no thanks" button that allows the user to
                    // continue using your app without granting the permission.
                    showInContextUI(...)
                }
                    else -> {
                        // We can request the permission by launching the ActivityResultLauncher
                        requestPermissions.launch(...)
                        // The registered ActivityResultCallback gets the result of the request.
                    }
                }*/

                startActivityForResult(Intent(android.provider.Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS), 0);
                val mNotificationManager: NotificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                mNotificationManager.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_NONE)


                if (!mNotificationManager.isNotificationPolicyAccessGranted()) {
                    /*val intent = Intent(android.provider.Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
                    startActivity(intent)

                    val intent = Intent(Settings.ACTION_CHANNEL_NOTIFICATION_SETTINGS)
                    intent.putExtra(Settings.EXTRA_CHANNEL_ID, mChannel.getId())
                    intent.putExtra(Settings.EXTRA_APP_PACKAGE, getPackageName())
                    startActivity(intent)*/
                    result.success(0)
                }
                result.success(1)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getBatteryLevel(): Int {
        val batteryLevel: Int
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            batteryLevel = intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        }

        return batteryLevel
    }


}
