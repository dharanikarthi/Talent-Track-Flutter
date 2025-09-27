package com.example.talent_track

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "talent_track/pose"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "analyzePushup" -> {
                    val videoPath = call.argument<String>("videoPath")
                    if (videoPath == null) {
                        result.error("ARG_ERROR", "videoPath is null", null)
                        return@setMethodCallHandler
                    }
                    val cacheDir = externalCacheDir ?: cacheDir
                    val csvFile = File(cacheDir, "ondevice_pushup_result.csv")
                    csvFile.writeText("count,down_time,up_time,dip_duration_sec,min_angle,correct,activity,timestamp,notes\n")
                    val summary = mapOf(
                        "activity" to "pushup",
                        "total_reps" to 0,
                        "correct_reps" to 0,
                        "accuracy_pct" to 0.0,
                        "duration_sec" to 0.0
                    )
                    val payload = mapOf(
                        "annotated_video_url" to videoPath,
                        "csv_url" to csvFile.absolutePath,
                        "summary" to summary
                    )
                    result.success(payload)
                }
                else -> result.notImplemented()
            }
        }
    }
}
