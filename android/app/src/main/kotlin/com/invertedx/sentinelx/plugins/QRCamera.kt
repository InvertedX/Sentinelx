package com.invertedx.sentinelx.plugins

import android.app.Activity
import android.content.Context
import android.view.View
import com.invertedx.sentinelx.i
import com.invertedx.sentinelx.plugins.codescanner.CodeScanner
import com.invertedx.sentinelx.plugins.codescanner.CodeScannerView
import com.invertedx.sentinelx.plugins.codescanner.DecodeCallback
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory


object QRCameraPlugin {
    fun registerWith(registrar: Registrar, activity: Activity) {
        registrar
                .platformViewRegistry()
                .registerViewFactory(
                        "plugins.sentinelx.qr_camera", QRCameraFactory(registrar.messenger(), activity))
    }
}


class QRCameraFactory(private val messenger: BinaryMessenger, val activity: Activity) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, id: Int, o: Any?): PlatformView {
        return QRCameraPlatformView(context, messenger, id, activity)
    }
}


class QRCameraPlatformView internal constructor(context: Context,
                                                messenger: BinaryMessenger?,
                                                id: Int?,
                                                private val activity: Activity) : PlatformView, MethodCallHandler {
    private val codeScanner: CodeScannerView = CodeScannerView(context)
    private val methodChannel: MethodChannel = MethodChannel(messenger, "plugins.sentinelx.qr_camera_$id")
    private val mCodeScanner = CodeScanner(context, codeScanner)
//    private val eventChannel = EventChannel(messenger, "plugins.sentinelx.qr_camera");

    init {
        methodChannel.setMethodCallHandler(this)
        codeScanner.setFrameAspectRatio(1f, 1f)
        codeScanner.frameSize = 0.75f

    }

    override fun getView(): View {
        return codeScanner
    }

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.method) {
            "start_preview" -> {
                i("Camera Start")
                mCodeScanner.decodeCallback = DecodeCallback {
                    activity.runOnUiThread {
                        result.success(it.text);
                    }
                }
                mCodeScanner.startPreview()
            }
            "stop_preview" -> {
                i("Camera Stop")
                mCodeScanner.stopPreview()
                mCodeScanner.releaseResources()
            }
            else -> result.notImplemented()
        }
    }


    override fun dispose() {
        i("dispose camera")
        try {
            mCodeScanner.stopPreview()
            mCodeScanner.releaseResources()
            codeScanner.removeAllViews()
        } catch (e: Exception) {
            e.printStackTrace();
        }

    }
}