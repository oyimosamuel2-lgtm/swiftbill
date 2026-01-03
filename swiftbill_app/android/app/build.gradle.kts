plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.swiftbill_app"
    compileSdk = 35  // Changed from flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"  // Added explicit NDK version

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.swiftbill_app"
        minSdk = 21  // Changed from flutter.minSdkVersion
        targetSdk = 34  // Changed from flutter.targetSdkVersion
        versionCode = 1  // Changed from flutter.versionCode
        versionName = "1.0.0"  // Changed from flutter.versionName
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
