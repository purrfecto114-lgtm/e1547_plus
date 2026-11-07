package net.e1547

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
        // reader holds enrolled prints. FingerprintManagerCompat asks the
        // hardware directly, so the settings page falls back to this probe.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "e1547/biometrics")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "fingerprintState" -> {
                        val fingerprint = FingerprintManagerCompat.from(this)
                        result.success(
                            mapOf(
                                "hardware" to fingerprint.isHardwareDetected,
                                "enrolled" to fingerprint.hasEnrolledFingerprints(),
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
