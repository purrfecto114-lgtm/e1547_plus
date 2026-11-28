plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("keys/key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "net.e1547"
    // Android 17 (API level 37) groundwork: the flutter pin of this sdk
    // version still sits at 36, so the levels are pinned here until the
    // framework raises them. AGP 8.x is tested through 36 and only warns
    // about 37; the flutter CI for API 37 rides AGP 9.3.1, a move that
    // should follow the framework rather than lead it.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "net.e1547"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // The fork verifies its behavior against Android 7; pin the
        // floor instead of following the flutter default.
        minSdk = 24
        // Targeting API 37 opts the app into android 17's targeting
        // behaviors: the local network runtime permission (declared in
        // the manifest, requested from the proxy path), certificate
        // transparency on by default for platform-stack connections, and
        // the removal of the large-screen orientation opt-out, which the
        // adaptive wide layout already covers by handling both.
        targetSdk = 37
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystoreProperties.containsKey("storeFile")) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            } else {
                initWith(getByName("debug"))
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
        debug {
            applicationIdSuffix = ".debug"
        }
    }

    // Splits and AAB builds are mutually exclusive in AGP 8 (the bundle
    // task chokes on per-ABI shrunk-resources outputs). Enable splits
    // only when the gradle invocation is building APKs, not bundles.
    // See https://issuetracker.google.com/402800800
    val buildingBundle = gradle.startParameter.taskNames.any {
        it.contains("bundle", ignoreCase = true)
    }
    splits {
        abi {
            isEnable = !buildingBundle
            reset()
            include("arm64-v8a", "armeabi-v7a")
            isUniversalApk = true
        }
    }

    dependenciesInfo {
        includeInApk = false
        includeInBundle = false
    }
}

flutter {
    source = "../.."
}

androidComponents {
    onVariants(selector().withBuildType("release")) { variant ->
        // AAR-provided native libraries (libmpv, cronet, sqlite) ignore
        // flutter's --target-platform flag, and build type abi filters do
        // not apply to split outputs. Excluding the paths from the native
        // library merge drops the x86_64 copies from the release universal
        // APK. No phone runs x86_64; debug builds stay unfiltered for
        // emulator developers.
        variant.packaging.jniLibs.excludes.addAll(
            listOf("lib/x86_64/**", "**/lib/x86_64/**", "lib/x86/**")
        )
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    // The biometric fallback probe asks the fingerprint hardware directly;
    // FingerprintManagerCompat lives in androidx.core, so name it instead
    // of leaning on whatever the flutter embedding happens to pull in.
    implementation("androidx.core:core:1.13.1")
    // The fallback also cross-checks androidx BiometricManager, whose
    // canAuthenticate answers fold hardware, enrollment and availability
    // into one code; the version matches what local_auth itself ships.
    implementation("androidx.biometric:biometric:1.1.0")
}

// androidx.core 1.18 turned FingerprintManagerCompat into a no-op that
// always reports false, which silently disabled every fingerprint probe —
// local_auth's included — on android releases that route through the
// fingerprint service (android 9 and older). local_auth pulls core 1.18
// transitively; holding the line at 1.17, where the compatibility
// manager still asks the hardware, keeps those devices working. The app's
// own probe asks the framework manager directly as well, so detection
// survives even without this pin, but local_auth's own answers need it.
configurations.all {
    resolutionStrategy {
        force("androidx.core:core:1.17.0")
    }
}
