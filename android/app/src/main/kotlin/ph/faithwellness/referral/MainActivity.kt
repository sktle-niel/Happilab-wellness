package ph.faithwellness.referral

import android.content.ActivityNotFoundException
import android.content.ClipData
import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    // The one thing Dart cannot do through a URL scheme: hand another app a
    // picture together with its caption via ACTION_SEND.
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "happilab/share")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "send" -> result.success(
                        send(
                            call.argument<String>("text") ?: "",
                            call.argument<String>("imagePath"),
                            call.argument<String>("package"),
                        )
                    )
                    "sendToStory" -> result.success(
                        sendToStory(call.argument<String>("imagePath")!!)
                    )
                    else -> result.notImplemented()
                }
            }
    }

    /// Facebook's add-to-story intent, backed by [imagePath]. Facebook wants
    /// the sharing app's public Facebook app id alongside it; that id lives in
    /// the manifest meta-data and is passed along whenever it is set.
    private fun sendToStory(imagePath: String): Boolean {
        val uri = FileProvider.getUriForFile(
            this, "$packageName.fileprovider", File(imagePath)
        )
        val intent = Intent("com.facebook.stories.ADD_TO_STORY")
        intent.setDataAndType(uri, "image/png")
        intent.setPackage("com.facebook.katana")
        intent.clipData = ClipData.newRawUri(null, uri)
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        val appId = packageManager
            .getApplicationInfo(packageName, PackageManager.GET_META_DATA)
            .metaData?.get("com.facebook.sdk.ApplicationId")?.toString()
        if (!appId.isNullOrBlank()) {
            intent.putExtra("com.facebook.platform.extra.APPLICATION_ID", appId)
        }
        return try {
            startActivity(intent)
            true
        } catch (_: ActivityNotFoundException) {
            false
        }
    }

    /// False when the target app is not installed — the Dart side owns the
    /// message the member then sees.
    private fun send(text: String, imagePath: String?, targetPackage: String?): Boolean {
        val intent = Intent(Intent.ACTION_SEND)
        if (imagePath == null) {
            intent.type = "text/plain"
        } else {
            val uri = FileProvider.getUriForFile(
                this, "$packageName.fileprovider", File(imagePath)
            )
            intent.type = "image/png"
            intent.putExtra(Intent.EXTRA_STREAM, uri)
            // ClipData carries the read grant to whichever activity the
            // receiving app resolves the send to.
            intent.clipData = ClipData.newRawUri(null, uri)
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        intent.putExtra(Intent.EXTRA_TEXT, text)
        if (targetPackage != null) intent.setPackage(targetPackage)
        return try {
            startActivity(intent)
            true
        } catch (_: ActivityNotFoundException) {
            false
        }
    }
}
