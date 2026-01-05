package com.example.swiftbill_app
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.ContentValues
import android.provider.MediaStore
import android.os.Environment

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.swiftbill_app/download_channel" // Match the Dart channel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "saveToDownloads") {
                val fileName = call.argument<String>("fileName")
                val bytes = call.argument<ByteArray>("bytes")
                val mimeType = call.argument<String?>("mimeType") ?: "application/pdf"

                val values = ContentValues().apply {
                    put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                    put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                    put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
                }

                val uri = contentResolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                uri?.let {
                    contentResolver.openOutputStream(it).use { output ->
                        output?.write(bytes)
                    }
                    result.success(true)
                } ?: run {
                    result.error("UNAVAILABLE", "Could not save file.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}




