package com.invertedx.sentinelx.tor

import android.content.Context
import android.util.Log
import com.invertedx.torservice.TorPrefernceConstants
import com.invertedx.torservice.TorProxyManager
import com.invertedx.torservice.TorProxyManager.ConnectionStatus
import io.reactivex.Completable
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.schedulers.Schedulers
import io.reactivex.subjects.Subject
import java.net.Proxy
import com.invertedx.torservice.util.Prefs
import io.reactivex.disposables.Disposable


class TorManager private constructor(private val context: Context) {
    private val compositeDisposable = CompositeDisposable()


    var state = ConnectionStatus.IDLE
    private val torProxyManager: TorProxyManager = TorProxyManager(context)


    fun startTor(): Observable<Boolean> {
        Log.i(TAG, "startTor: ")
        return Observable.fromCallable {
            torProxyManager.startTor()
            true
        }
    }

    val isConnected: Boolean
        get() {
            return try {
                state == ConnectionStatus.CONNECTED
            } catch (Ex: Exception) {
                false
            }
        }

    fun stopTor(): Completable {
        return torProxyManager.stopTor()
    }

    fun renew(): Completable {
        return torProxyManager.newIdentity()
    }

    val torStatus: Subject<ConnectionStatus>
        get() = torProxyManager.torStatus

    val torLogs: Subject<String>
        get() = torProxyManager.torLogs

    val circuitLogs: Subject<String>
        get() = torProxyManager.torCircuitStatus

    val bandWidth: Subject<MutableMap<String, Long>>?
        get() = torProxyManager.bandWidthStatus

    fun dispose() {
        compositeDisposable.dispose()
    }

    fun getProxy(): Proxy? {
        return torProxyManager.proxy;
    }

    fun setPort(port: Int) {
        val prefs = Prefs.getSharedPrefs(this.context);

        prefs.edit().putString(TorPrefernceConstants.PREF_SOCKS, if (port == 0) "auto" else port.toString()).apply();

        torProxyManager.updateTorrcCustomFile();
        val disposable = torProxyManager.stopTor()
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe {
                    startTor().subscribeOn(Schedulers.io())
                            .observeOn(AndroidSchedulers.mainThread()).subscribe { }
                }
        compositeDisposable.add(disposable);
    }

    companion object {
        private const val TAG = "TorManager"
        var instance: TorManager? = null
        fun getInstance(ctx: Context): TorManager? {
            if (instance == null) {
                instance = TorManager(ctx)
            }
            return instance
        }
    }

    init {
        val disposable = torProxyManager.torStatus
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe { status: ConnectionStatus ->
                    state = status

                }
        compositeDisposable.add(disposable)
    }
}