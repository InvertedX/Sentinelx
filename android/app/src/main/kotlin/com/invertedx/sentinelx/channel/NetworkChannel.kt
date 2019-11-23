package com.invertedx.sentinelx.channel

import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.net.wifi.WifiManager
import com.invertedx.sentinelx.MainActivity
import com.invertedx.sentinelx.tor.TorManager
import com.invertedx.sentinelx.tor.TorService
import com.invertedx.sentinelx.utils.Connectivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.functions.Consumer
import io.reactivex.schedulers.Schedulers
import java.util.concurrent.TimeUnit


class NetworkChannel(private val applicationContext: Context, private val activity: MainActivity) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val TOR_STREAM = "TOR_EVENT_STREAM"
    private val TOR_LOG_STREAM = "TOR_LOG_STREAM"
    private val CONNECTIVITY_CHANNEL = "CONNECTIVITY_CHANNEL"
    private val compositeDisposable: CompositeDisposable = CompositeDisposable()
    private val connectivity: Connectivity
    private val eventChannel: EventChannel

    init {
        /**
         *  Event channel to emit tor status to the flutter ui
         */
        EventChannel(activity.flutterView, TOR_STREAM)
                .setStreamHandler(this)

        EventChannel(activity.flutterView, TOR_LOG_STREAM)
                .setStreamHandler(object : EventChannel.StreamHandler {
                    override fun onListen(arg: Any?, eventSink: EventChannel.EventSink?) {
                        val logger = Observable.interval(2, TimeUnit.SECONDS, Schedulers.io())
                                .map { TorManager.getInstance(applicationContext).latestLogs }
                                .observeOn(AndroidSchedulers.mainThread())
                                .subscribe({
                                    eventSink?.success(it)
                                }, {

                                })
                        compositeDisposable.add(logger)

                    }

                    override fun onCancel(p0: Any?) {
                    }

                })

        eventChannel = EventChannel(activity.flutterView, CONNECTIVITY_CHANNEL)

        val connectivityManager = applicationContext.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val wifiManager = applicationContext.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        connectivity = Connectivity(connectivityManager, wifiManager)

    }

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.method) {

            "startTor" -> {
                try {
                    val startIntent = Intent(applicationContext, TorService::class.java)
                    startIntent.action = TorService.START_SERVICE
                    applicationContext.startService(startIntent)
                    result.success(true);
                } catch (ex: Exception) {
                }
            }
            "startAndWait" -> {
                try {
                    val startIntent = Intent(applicationContext, TorService::class.java)
                    startIntent.action = TorService.START_SERVICE
                    applicationContext.startService(startIntent)
                    val disposable = TorManager.getInstance(applicationContext)
                            .torStatus
                            .subscribeOn(Schedulers.io())
                            .observeOn(AndroidSchedulers.mainThread())
                            .subscribe ({
                                if (it != null)
                                    when (it) {
                                        TorManager.CONNECTION_STATES.CONNECTED -> {

                                            result.success(true)
                                        }
                                        TorManager.CONNECTION_STATES.IDLE -> {

                                        }
                                        TorManager.CONNECTION_STATES.DISCONNECTED -> {

                                        }
                                        TorManager.CONNECTION_STATES.CONNECTING -> {
                                        }
                                    }
                            }, {
                                print(it);
                            })

                    compositeDisposable.addAll(disposable)
                } catch (ex: Exception) {
                    result.error("Error", "TorError", ex.message)
                }
            }

            "stopTor" -> {
                val startIntent = Intent(applicationContext, TorService::class.java)
                startIntent.action = TorService.STOP_SERVICE
                applicationContext.startService(startIntent)
            }

            "newNym" -> {
                val startIntent = Intent(applicationContext, TorService::class.java)
                startIntent.action = TorService.RENEW_IDENTITY
                applicationContext.startService(startIntent)
            }

            "connectivityStatus" -> {
                result.success(connectivity.networkType)
            }

            "torStatus" -> {
                if (TorManager.getInstance(applicationContext).state == null) {
                    return result.success("IDLE")
                }
                return when (TorManager.getInstance(applicationContext).state) {
                    TorManager.CONNECTION_STATES.CONNECTED -> {
                        result.success("CONNECTED")
                    }
                    TorManager.CONNECTION_STATES.IDLE -> {
                        result.success("IDLE")
                    }
                    TorManager.CONNECTION_STATES.DISCONNECTED -> {
                        result.success("DISCONNECTED")
                    }
                    TorManager.CONNECTION_STATES.CONNECTING -> {
                        result.success("CONNECTING")
                    }
                }
            }

        }
    }

    override fun onListen(args: Any?, events: EventChannel.EventSink?) {

        val disposable = TorManager.getInstance(applicationContext)
                .torStatus
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe {
                    if (it != null && events != null)
                        when (it) {
                            TorManager.CONNECTION_STATES.CONNECTED -> {
                                events.success("CONNECTED")
                            }
                            TorManager.CONNECTION_STATES.IDLE -> {
                                events.success("IDLE")
                            }
                            TorManager.CONNECTION_STATES.DISCONNECTED -> {
                                events.success("DISCONNECTED")
                            }
                            TorManager.CONNECTION_STATES.CONNECTING -> {
                                events.success("CONNECTING")

                            }
                        }
                }
        compositeDisposable.add(disposable)

    }

    override fun onCancel(args: Any?) {
        compositeDisposable.clear()

    }


    /**
     * Dispose method for clearing from activity
     */
    fun dispose() {

        compositeDisposable.dispose()
    }

}