plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "dz.deliveryos.driver"
    // 37, not Flutter's default of 36: flutter_secure_storage 11 requires it.
    // That package holds the only copy of the database encryption key, and
    // version 11 is where its Android implementation moved to AES-GCM with
    // RSA-OAEP-SHA256 key wrapping, replacing 9.x's PKCS1v1.5. For the one
    // secret in this app that protects a driver's entire history, the newer
    // primitive is worth the SDK bump.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Permanent once published. Product namespace, not a personal handle,
        // leaving room for dz.deliveryos.dispatch when the V3 dispatcher ships.
        applicationId = "dz.deliveryos.driver"
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

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
