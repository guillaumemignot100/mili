import java.util.Base64
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val dartEnvironmentVariables: Map<String, String> =
    if (project.hasProperty("dart-defines")) {
        (project.property("dart-defines") as String)
            .split(",")
            .associate { entry ->
                val pair = String(Base64.getDecoder().decode(entry), Charsets.UTF_8).split("=")
                pair.first() to pair.last()
            }
    } else {
        mapOf("ENV" to "production")
    }

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("signature/key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.visuamobile.liberation"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_21.toString()
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        applicationId = "com.visuamobile.liberation"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (System.getenv("ANDROID_KEYSTORE_PATH") != null) {
            create("release") {
                storeFile = file(System.getenv("ANDROID_KEYSTORE_PATH")!!)
                keyAlias = System.getenv("ANDROID_KEYSTORE_ALIAS")
                keyPassword = System.getenv("ANDROID_KEYSTORE_PRIVATE_KEY_PASSWORD")
                storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
            }
        } else {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
                storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String?
            }
        }
    }

    flavorDimensions += "default"
    productFlavors {
        create("production") {
            dimension = "default"
            applicationIdSuffix = ""
            manifestPlaceholders["appName"] = "Libération: Info et Actualités"
        }
        create("staging") {
            dimension = "default"
            applicationIdSuffix = ".stg"
            manifestPlaceholders["appName"] = "[STG]Liberation"
        }
        create("development") {
            dimension = "default"
            applicationIdSuffix = ".dev"
            manifestPlaceholders["appName"] = "[DEV]Liberation"
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android.txt"),
                "proguard-rules.pro"
            )
        }
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

val readerVersion: String by rootProject.extra

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    implementation("org.jetbrains.kotlin:kotlin-stdlib:2.2.10")
    implementation("com.google.android.gms:play-services-base:18.7.2")

    // Milibris
    api("com.milibris:one-reader:$readerVersion") {
        exclude(group = "androidx.lifecycle")
    }
    api("com.milibris:milibris-reader:$readerVersion")

}
