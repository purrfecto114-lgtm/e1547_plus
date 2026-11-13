package net.e1547

import androidx.biometric.BiometricManager
import androidx.core.hardware.fingerprint.FingerprintManagerCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
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
                        result.success(
                            mapOf(
                                "hardware" to probe {
                                    FingerprintManagerCompat.from(this@MainActivity).isHardwareDetected
                                },
                                "enrolled" to probe {
                                    FingerprintManagerCompat.from(this@MainActivity).hasEnrolledFingerprints()
                                },
                                "enrolledCount" to probe {
                                    FingerprintManagerCompat.from(this@MainActivity)
                                        .getEnrolledFingerprints()
                                        .size
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
