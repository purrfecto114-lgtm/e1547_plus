package net.e1547

import android.hardware.fingerprint.FingerprintManager
import android.os.Build
import androidx.biometric.BiometricManager
import androidx.core.hardware.fingerprint.FingerprintManagerCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    // The pending result of a local network permission request, completed
    // from onRequestPermissionsResult once the user answers the dialog.
    private var localNetworkResult: MethodChannel.Result? = null

    // The framework fingerprint manager is deprecated on newer releases,
    // where it no longer routes to real hardware; the probe only asks it
    // on the old releases that still do.
    @Suppress("DEPRECATION")
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // local_auth probes biometrics through androidx.biometric, which
        // collapses several legacy failure modes into "no biometrics" and
        // can report an empty device on old android releases even when the
        // reader holds enrolled prints. This probe asks every available
        // signal directly, so the settings page can fall back to it.
        //
        // Each signal is isolated in its own runCatching: older OEM builds
        // guard parts of the fingerprint service, and one throwing probe
        // must not erase what the others still know. A probe that failed
        // reports null instead of false so the Dart side can tell the
        // answers apart.
        //
        // The framework probes exist because the compatibility layer can
        // stop answering: androidx.core turned FingerprintManagerCompat
        // into a no-op that always reports false (1.18), which silently
        // disabled every compat-based signal on the old releases that
        // still route through it. The framework fingerprint manager is
        // asked directly on those releases, where it keeps working.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "e1547/biometrics")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // The cronet engine ignores the android system proxy, so
                    // users behind one (wifi proxy settings, local proxy apps)
                    // cannot reach hosts their proxy would unlock. The dart
                    // side asks for the system proxy and routes through an
                    // adapter that honors it when one is set.
                    "systemProxy" -> {
                        fun probe(block: () -> Any?): Any? =
                            try {
                                block()
                            } catch (e: Exception) {
                                null
                            }
                        val host: String? = probe {
                            android.provider.Settings.Global.getString(
                                contentResolver,
                                android.provider.Settings.Global.HTTP_PROXY,
                            )?.split(":")?.firstOrNull()?.takeIf { it.isNotEmpty() }
                        } as String?
                        val port: Int? = probe {
                            android.provider.Settings.Global.getString(
                                contentResolver,
                                android.provider.Settings.Global.HTTP_PROXY,
                            )?.split(":")?.getOrNull(1)?.toIntOrNull()
                        } as Int?
                        result.success(
                            mapOf(
                                "host" to host,
                                "port" to port,
                            )
                        )
                    }
                    "fingerprintState" -> {
                        fun probe(block: () -> Any?): Any? =
                            try {
                                block()
                            } catch (e: Exception) {
                                null
                            }
                        // The framework manager is only asked on releases
                        // whose biometric stack still routes through the
                        // fingerprint service.
                        val framework: FingerprintManager? =
                            if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.P) {
                                probe {
                                    getSystemService(FingerprintManager::class.java)
                                } as FingerprintManager?
                            } else {
                                null
                            }
                        result.success(
                            mapOf(
                                "hardware" to probe {
                                    FingerprintManagerCompat.from(this@MainActivity).isHardwareDetected
                                },
                                "enrolled" to probe {
                                    FingerprintManagerCompat.from(this@MainActivity).hasEnrolledFingerprints()
                                },
                                "frameworkHardware" to probe {
                                    framework?.isHardwareDetected
                                },
                                "frameworkEnrolled" to probe {
                                    framework?.hasEnrolledFingerprints()
                                },
                                "weak" to probe {
                                    BiometricManager.from(this@MainActivity).canAuthenticate(
                                        BiometricManager.Authenticators.BIOMETRIC_WEAK,
                                    )
                                },
                                "strong" to probe {
                                    BiometricManager.from(this@MainActivity).canAuthenticate(
                                        BiometricManager.Authenticators.BIOMETRIC_STRONG,
                                    )
                                },
                            )
                        )
                    }
                    // Android 17 (API level 37) makes ACCESS_LOCAL_NETWORK
                    // a runtime permission for apps targeting it, and a
                    // proxy can sit on the local network (a router, or a
                    // local proxy app). The dart side calls this once it
                    // resolved such a host; older releases have no such
                    // permission, so they answer granted right away. The
                    // sdk check uses the literal because the new release's
                    // VERSION_CODES name is not worth guessing at.
                    "requestLocalNetworkPermission" -> {
                        val permission = "android.permission.ACCESS_LOCAL_NETWORK"
                        if (Build.VERSION.SDK_INT < 37 ||
                            checkSelfPermission(permission) ==
                                android.content.pm.PackageManager.PERMISSION_GRANTED
                        ) {
                            result.success(true)
                        } else {
                            localNetworkResult = result
                            requestPermissions(arrayOf(permission), LOCAL_NETWORK_REQUEST)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // This is a hack to prevent media_kit from hard-crashing the app
    override fun finishAfterTransition() {
        moveTaskToBack(true)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        if (requestCode == LOCAL_NETWORK_REQUEST) {
            localNetworkResult?.let { pending ->
                // A dead channel (the activity went away before the user
                // answered) must not take the app down.
                runCatching {
                    pending.success(
                        grantResults.firstOrNull() ==
                            android.content.pm.PackageManager.PERMISSION_GRANTED,
                    )
                }
            }
            localNetworkResult = null
        }
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    private companion object {
        // A distinctive request code, so plugins listening through the
        // flutter registry never mistake this answer for theirs.
        const val LOCAL_NETWORK_REQUEST = 41505
    }
}
