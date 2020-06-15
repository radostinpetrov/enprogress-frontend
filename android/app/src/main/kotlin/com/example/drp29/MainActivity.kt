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
import android.content.ContentValues.TAG
import android.util.Log
import android.os.Bundle
import java.util.HashMap


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
            } else if (call.method == "turnDoNotDisturbModeOn") {
//                startActivityForResult(Intent(android.provider.Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS), NotificationManager.INTERRUPTION_FILTER_NONE);

                val mNotificationManager: NotificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                mNotificationManager.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_NONE)


                if (!mNotificationManager.isNotificationPolicyAccessGranted()) {
                    result.success(0)
                }

                result.success(1)
            } else if (call.method == "turnDoNotDisturbModeOff") {
                val mNotificationManager: NotificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                mNotificationManager.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_ALL)


//                if (!mNotificationManager.isNotificationPolicyAccessGranted()) {
//                    startActivityForResult(Intent(android.provider.Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS), NotificationManager.INTERRUPTION_FILTER_NONE);
//                    result.success(0)
//                }

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

//    private val VERBOSE = true
//
//
//    private val TAG = "SampleActivity"
//    override fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
//        if (VERBOSE) Log.v(TAG, "+++ ON CREATE +++")
//
//        MethodChannel(getFlutterEngine()!!.dartExecutor!!.binaryMessenger!!, CHANNEL).invokeMethod("foo", null);
//
//    }
//
//    override fun onStart() {
//        super.onStart()
//        if (VERBOSE) Log.v(TAG, "++ ON START ++")
//        MethodChannel(getFlutterEngine()!!.dartExecutor!!.binaryMessenger!!, CHANNEL).invokeMethod("foo", null);
//
//    }
//
//    override fun onResume() {
//        super.onResume()
//        if (VERBOSE) Log.v(TAG, "+ ON RESUME +")
//        MethodChannel(getFlutterEngine()!!.dartExecutor!!.binaryMessenger!!, CHANNEL).invokeMethod("foo", null);
//
//    }
//
//    override fun onPause() {
//        super.onPause()
//        if (VERBOSE) Log.v(TAG, "- ON PAUSE -")
//        MethodChannel(getFlutterEngine()!!.dartExecutor!!.binaryMessenger!!, CHANNEL).invokeMethod("foo", null);
//
//    }
//
//    override fun onStop() {
//        super.onStop()
//        if (VERBOSE) Log.v(TAG, "-- ON STOP --")
//        MethodChannel(getFlutterEngine()!!.dartExecutor!!.binaryMessenger!!, CHANNEL).invokeMethod("foo", null);
//
//    }
//
//    override fun onDestroy() {
//        super.onDestroy()
//        if (VERBOSE) Log.v(TAG, "- ON DESTROY -")
//        MethodChannel(getFlutterEngine()!!.dartExecutor!!.binaryMessenger!!, CHANNEL).invokeMethod("foo", null);
//
//    }

}
