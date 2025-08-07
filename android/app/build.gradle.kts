plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // Mengubah namespace ke nama paket yang lebih spesifik dan unik
    namespace = "com.fortunaUserApp" // <--- PERBEDAAN DI SINI
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Mengubah applicationId agar sesuai dengan namespace dan menjadi unik
        applicationId = "com.fortunaUserApp" // <--- PERBEDAAN DI SINI
        // minSdk dan targetSdk tetap menggunakan nilai dari flutter.minSdkVersion dan flutter.targetSdkVersion
        // Ini memastikan Anda menargetkan versi Android yang direkomendasikan (saat ini targetSdk 34)
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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
