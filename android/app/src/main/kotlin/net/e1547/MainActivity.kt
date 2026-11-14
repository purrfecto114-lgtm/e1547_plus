package net.e1547

import android.hardware.fingerprint.FingerprintManager
import android.os.Build
import androidx.biometric.BiometricManager
import androidx.core.hardware.fingerprint.FingerprintManagerCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
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
                                "enrolledCount" to probe {
                                    framework?.enrolledFingerprints?.size
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
                    else -> result.notImplemented()
                }
            }
    }

    // This is a hack to prevent media_kit from hard-crashing the app
    override fun finishAfterTransition() {
        moveTaskToBack(true)
    }
}
