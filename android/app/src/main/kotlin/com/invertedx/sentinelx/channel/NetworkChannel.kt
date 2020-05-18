package com.invertedx.sentinelx.channel

import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.net.wifi.WifiManager
import android.util.Log
import android.widget.Toast
import com.invertedx.sentinelx.MainActivity
import com.invertedx.sentinelx.SentinelxApp
import com.invertedx.sentinelx.api.ApiService
import com.invertedx.sentinelx.tor.TorManager
import com.invertedx.sentinelx.tor.TorService
import com.invertedx.sentinelx.utils.Connectivity
import com.invertedx.torservice.TorProxyManager
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.schedulers.Schedulers
import org.bitcoinj.core.Transaction
import org.bouncycastle.util.encoders.Hex
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

                        val circuitLogs =  TorManager.getInstance(applicationContext)!!
                                .circuitLogs;


                        val logs =  TorManager.getInstance(applicationContext)!!
                                .torLogs;


                        val logger  = Observable.merge(circuitLogs,logs)
                                ?.subscribeOn(Schedulers.io())
                                ?.observeOn(AndroidSchedulers.mainThread())
                                ?.subscribe {
                                    eventSink?.success(it)
                                }

                        logger?.let { compositeDisposable.add(it) }

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
                            ?.torStatus
                            ?.subscribeOn(Schedulers.io())
                            ?.observeOn(AndroidSchedulers.mainThread())
                            ?.subscribe({
                                if (it != null)
                                    when (it) {
                                        TorProxyManager.ConnectionStatus.CONNECTED -> {

                                            result.success(true)
                                        }
                                        TorProxyManager.ConnectionStatus.IDLE -> {

                                        }
                                        TorProxyManager.ConnectionStatus.DISCONNECTED -> {

                                        }
                                        TorProxyManager.ConnectionStatus.CONNECTING -> {
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
                result.success(true);
            }

            "newNym" -> {
                val startIntent = Intent(applicationContext, TorService::class.java)
                startIntent.action = TorService.RENEW_IDENTITY
                applicationContext.startService(startIntent)
                result.success(true);
            }

            "connectivityStatus" -> {
                result.success(connectivity.networkType)
            }

            "torStatus" -> {
                if (TorManager.getInstance(applicationContext)?.state == null) {
                    return result.success("IDLE")
                }
                return when (TorManager.getInstance(applicationContext)?.state) {
                    TorProxyManager.ConnectionStatus.CONNECTED -> {
                        result.success("CONNECTED")
                    }
                    TorProxyManager.ConnectionStatus.IDLE -> {
                        result.success("IDLE")
                    }
                    TorProxyManager.ConnectionStatus.DISCONNECTED -> {
                        result.success("DISCONNECTED")
                    }
                    TorProxyManager.ConnectionStatus.CONNECTING -> {
                        result.success("CONNECTING")
                    }
                    else -> {
                        result.success("WAITING")

                    }
                }
            }

            "setTorSocksPort" -> {
                try {
                    val port = methodCall.arguments as Int
                    port?.let {
                        TorManager.getInstance(applicationContext)?.setPort(it);
                        Toast.makeText(applicationContext, "Reloading tor configurations...", Toast.LENGTH_SHORT).show()
                        result.success(true);
                        return
                    }
                } catch (ex: Exception) {
                    ex.printStackTrace()
                    result.error(null, ex.message, null);
                }
            }

        }
    }
    
    override fun onListen(args: Any?, events: EventChannel.EventSink?) {

        val disposable = TorManager.getInstance(applicationContext)
                ?.torStatus
                ?.subscribeOn(Schedulers.io())
                ?.observeOn(AndroidSchedulers.mainThread())
                ?.subscribe {
                    if (it != null && events != null)
                        when (it) {
                            TorProxyManager.ConnectionStatus.CONNECTED -> {
                                events.success("CONNECTED")
                            }
                            TorProxyManager.ConnectionStatus.IDLE -> {
                                events.success("IDLE")
                            }
                            TorProxyManager.ConnectionStatus.DISCONNECTED -> {
                                events.success("DISCONNECTED")
                            }
                            TorProxyManager.ConnectionStatus.CONNECTING -> {
                                events.success("CONNECTING")

                            }
                        }
                }
        disposable?.let { compositeDisposable.add(it) }

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