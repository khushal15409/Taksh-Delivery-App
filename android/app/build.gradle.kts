plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.delivery_boy"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.delivery_boy"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// Firebase push notifications (same Firebase project as the Taksh customer app). The Google
// Services plugin turns google-services.json into the app's Firebase configuration, but it FAILS
// the build when that file has no client for this applicationId. So it is applied only when the
// file is registered for this app. Otherwise the same configuration values (src/firebaseFallback/res)
// are compiled in, so Firebase still starts and push works; register this applicationId in Firebase
// and commit its google-services.json to switch to the standard setup.
val applicationIdValue = android.defaultConfig.applicationId
val googleServicesFile = file("google-services.json")
if (googleServicesFile.exists() &&
    Regex("\"package_name\"\\s*:\\s*\"${Regex.escape(applicationIdValue ?: "")}\"")
        .containsMatchIn(googleServicesFile.readText())
) {
    apply(plugin = "com.google.gms.google-services")
} else {
    android.sourceSets.getByName("main").res.srcDir("src/firebaseFallback/res")
    logger.warn("google-services.json is not registered for $applicationIdValue: using the built-in Firebase configuration (src/firebaseFallback)")
}
