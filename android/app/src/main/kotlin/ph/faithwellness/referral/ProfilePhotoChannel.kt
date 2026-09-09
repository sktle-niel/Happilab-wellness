package ph.faithwellness.referral

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.ClipData
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.ImageDecoder
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import androidx.core.content.FileProvider
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

/// Pictures on the platform side: the system photo picker and the camera,
/// one bounded JPEG kept under the app's private files for the profile, or
/// handed over from the cache for a chat, and the activity round trip that
/// joins them. Only the file's path crosses to Dart.
///
/// Hand-rolled over `image_picker` deliberately: the picker on 13+ and the
/// capture intent need no permission, and the plugin's ten transitive
/// packages buy nothing the share bridge next door does not already show how
/// to do.
class ProfilePhotoChannel(private val activity: Activity) {

    private var pending: MethodChannel.Result? = null
    private var captureUri: Uri? = null

    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, NAME).setMethodCallHandler { call, result ->
            when (call.method) {
                "current" -> result.success(current()?.path)
                "pick" -> open(result, pickIntent(), REQUEST_PICK)
                "capture" -> open(result, captureIntent(), REQUEST_CAPTURE)
                "attach" -> open(result, pickIntent(), REQUEST_ATTACH)
                "snap" -> open(result, captureIntent(), REQUEST_SNAP)
                "keep" -> keep(call.argument<String>("path")!!, result)
                "remove" -> {
                    discard()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    /// True when the result was this channel's. Backing out answers null; a
    /// picture that will not read answers an error the Dart side words.
    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode !in REQUESTS) return false
        val result = pending ?: return true
        pending = null
        val uri = if (requestCode == REQUEST_PICK || requestCode == REQUEST_ATTACH) data?.data else captureUri
        captureUri = null
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return true
        }
        storeAsync(uri, captureFile, result, forProfile = requestCode == REQUEST_PICK || requestCode == REQUEST_CAPTURE)
        return true
    }

    /// Decoding a full-size photo is too slow for the main thread; the channel
    /// still wants its answer there. [leftover] is what the round trip wrote
    /// to the cache and no longer needs.
    private fun storeAsync(uri: Uri, leftover: File, result: MethodChannel.Result, forProfile: Boolean = true) {
        Thread {
            val stored = runCatching { store(uri, forProfile) }
            leftover.delete()
            activity.runOnUiThread {
                stored.fold(
                    { result.success(it.path) },
                    { result.error("unreadable", it.message, null) },
                )
            }
        }.start()
    }

    /// Keeps a picture the app already holds — an avatar from the bundle,
    /// written to the cache by Dart — the same way as one from a source.
    private fun keep(path: String, result: MethodChannel.Result) {
        val file = File(path)
        storeAsync(Uri.fromFile(file), file, result)
    }

    private fun open(result: MethodChannel.Result, intent: Intent, requestCode: Int) {
        if (pending != null) {
            result.error("busy", "A picture is already being chosen.", null)
            return
        }
        pending = result
        try {
            activity.startActivityForResult(intent, requestCode)
        } catch (_: ActivityNotFoundException) {
            pending = null
            result.error("unavailable", null, null)
        }
    }

    /// The photo picker where the platform has one; the document chooser,
    /// narrowed to images, before that.
    private fun pickIntent(): Intent =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            Intent(MediaStore.ACTION_PICK_IMAGES).setType("image/*")
        } else {
            Intent(Intent.ACTION_GET_CONTENT)
                .addCategory(Intent.CATEGORY_OPENABLE)
                .setType("image/*")
        }

    /// The camera writes full size into the cache through the share provider.
    /// The write grant rides on the clip data — the one place startActivity
    /// honours it for an extra.
    private fun captureIntent(): Intent {
        val uri = FileProvider.getUriForFile(
            activity, "${activity.packageName}.fileprovider", captureFile
        )
        captureUri = uri
        return Intent(MediaStore.ACTION_IMAGE_CAPTURE).apply {
            putExtra(MediaStore.EXTRA_OUTPUT, uri)
            clipData = ClipData.newRawUri(null, uri)
            addFlags(
                Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
            )
        }
    }

    /// Keeps the picture as one JPEG, orientation baked in, under a fresh
    /// name — the fresh name is what lets the Dart image cache notice the
    /// change. A profile picture replaces the last one under the app's files;
    /// a chat photo goes to the cache, larger, and never touches the profile.
    private fun store(uri: Uri, forProfile: Boolean): File {
        val bitmap = decodeBounded(uri, if (forProfile) MAX_EDGE else CHAT_MAX_EDGE)
        val file = if (forProfile) {
            discard()
            File(activity.filesDir, "$PREFIX${System.currentTimeMillis()}.jpg")
        } else {
            File(activity.cacheDir, "$CHAT_PREFIX${System.currentTimeMillis()}.jpg")
        }
        FileOutputStream(file).use { bitmap.compress(Bitmap.CompressFormat.JPEG, 88, it) }
        return file
    }

    /// ImageDecoder applies the EXIF orientation itself; the BitmapFactory
    /// path before API 28 does not, which those few devices live with.
    private fun decodeBounded(uri: Uri, maxEdge: Int): Bitmap {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val source = ImageDecoder.createSource(activity.contentResolver, uri)
            return ImageDecoder.decodeBitmap(source) { decoder, info, _ ->
                decoder.allocator = ImageDecoder.ALLOCATOR_SOFTWARE
                decoder.setTargetSampleSize(sampleSize(info.size.width, info.size.height, maxEdge))
            }
        }
        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        activity.contentResolver.openInputStream(uri)!!.use {
            BitmapFactory.decodeStream(it, null, bounds)
        }
        val options = BitmapFactory.Options().apply {
            inSampleSize = sampleSize(bounds.outWidth, bounds.outHeight, maxEdge)
        }
        return activity.contentResolver.openInputStream(uri)!!.use {
            BitmapFactory.decodeStream(it, null, options)
        } ?: throw IllegalArgumentException("Not a picture")
    }

    /// The largest power of two that still leaves the longer side at least
    /// [maxEdge] — the decoder only shrinks in those steps.
    private fun sampleSize(width: Int, height: Int, maxEdge: Int): Int {
        var sample = 1
        while (maxOf(width, height) / (sample * 2) >= maxEdge) sample *= 2
        return sample
    }

    private fun current(): File? = photos().maxByOrNull { it.name }

    private fun discard() = photos().forEach { it.delete() }

    private fun photos(): List<File> =
        activity.filesDir.listFiles { file -> file.name.startsWith(PREFIX) }?.toList()
            ?: emptyList()

    private val captureFile: File
        get() = File(activity.cacheDir, "camera-capture.jpg")

    private companion object {
        const val NAME = "happilab/profile_photo"
        const val REQUEST_PICK = 0x9101
        const val REQUEST_CAPTURE = 0x9102
        const val REQUEST_ATTACH = 0x9103
        const val REQUEST_SNAP = 0x9104
        val REQUESTS = setOf(REQUEST_PICK, REQUEST_CAPTURE, REQUEST_ATTACH, REQUEST_SNAP)
        const val PREFIX = "profile-photo-"
        const val CHAT_PREFIX = "chat-photo-"
        const val MAX_EDGE = 1024
        // A wallet screenshot has to stay legible; the profile disc does not.
        const val CHAT_MAX_EDGE = 1600
    }
}
