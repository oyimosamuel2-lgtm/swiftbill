plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.swiftbill_app"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.swiftbill_app"
        minSdk = 23  // Firebase requires minimum 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true  // ADDED: Required for Firebase
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

dependencies {
    // Import the Firebase BoM (Bill of Materials)
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))

    // Firebase products - versions managed by BoM
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")  // ADDED: For authentication
    implementation("com.google.firebase:firebase-firestore")  // ADDED: For database
    
    // AndroidX and Kotlin support
    implementation("androidx.multidex:multidex:2.0.1")  // ADDED: For MultiDex support
}

// IMPORTANT: Apply Google Services plugin at the very end
apply(plugin = "com.google.gms.google-services")