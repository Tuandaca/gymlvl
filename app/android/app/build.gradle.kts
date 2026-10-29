plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Operator-owned release signing. Never commit credentials or fall back to debug signing.
val releaseSigningInputs = listOf(
    "GYMLVL_RELEASE_STORE_FILE",
    "GYMLVL_RELEASE_STORE_PASSWORD",
    "GYMLVL_RELEASE_KEY_ALIAS",
    "GYMLVL_RELEASE_KEY_PASSWORD",
)
val releaseSigningValues = releaseSigningInputs.associateWith {
    providers.environmentVariable(it).orNull?.takeIf { value -> value.isNotBlank() }
}
val missingReleaseSigning = releaseSigningInputs.filter { releaseSigningValues[it] == null }

android {
    namespace = "com.gymlvl.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.gymlvl.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (missingReleaseSigning.isEmpty()) {
                storeFile = file(releaseSigningValues.getValue("GYMLVL_RELEASE_STORE_FILE")!!)
                storePassword = releaseSigningValues.getValue("GYMLVL_RELEASE_STORE_PASSWORD")!!
                keyAlias = releaseSigningValues.getValue("GYMLVL_RELEASE_KEY_ALIAS")!!
                keyPassword = releaseSigningValues.getValue("GYMLVL_RELEASE_KEY_PASSWORD")!!
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

// Gate execution, not configuration: help, debug and manifest inspection need no keys.
val releasePackagingTasks = setOf(
    "validateSigningRelease",
    "packageRelease",
    "packageReleaseBundle",
    "signReleaseBundle",
    "bundleRelease",
    "assembleRelease",
)
val validateReleaseSigningInputs = tasks.register("validateReleaseSigningInputs") {
    doLast {
        if (missingReleaseSigning.isNotEmpty()) {
            throw GradleException(
                "Release signing configuration is incomplete. Missing inputs: " +
                    "${missingReleaseSigning.joinToString(", ")}. Supply all four GYMLVL_RELEASE_* inputs; values are never logged."
            )
        }
    }
}
tasks.configureEach {
    if (name in releasePackagingTasks) {
        // A separate dependency cannot be skipped by AGP's signing-task onlyIf predicate.
        dependsOn(validateReleaseSigningInputs)
    }
}

flutter {
    source = "../.."
}
