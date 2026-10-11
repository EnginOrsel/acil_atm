import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // Firebase plugin ↓
    id("com.google.gms.google-services") 
    // Flutter plugin sonra gelmeli
    id("dev.flutter.flutter-gradle-plugin")
}

// Google Maps API anahtarı android/local.properties içinden okunur (git'e dahil değildir)
val localProperties = Properties().apply {
    val file = rootProject.file("local.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}

android {
    namespace = "com.example.acil_atm"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "29.0.13846066"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.acil_atm"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["MAPS_API_KEY"] = localProperties.getProperty("MAPS_API_KEY") ?: ""
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // 🔥 Firebase BOM platformu
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))

    // 🔥 Firebase Analytics (ilk test için)
    implementation("com.google.firebase:firebase-analytics")
}
