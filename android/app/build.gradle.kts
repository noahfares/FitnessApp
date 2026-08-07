import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// F-REL-002 / ADR-0007 — the upload keystore. `release.yml` decodes it from
// GitHub Secrets to a file and passes its path and passwords as environment
// variables; nothing signing-related is ever committed. `key.properties`
// (also git-ignored) is the equivalent for a local release build, so a
// contributor with their own keystore can test the release path without
// touching CI at all.
//
// Imported rather than fully qualified (`java.util.Properties()`): inside
// this script's scope, top-level `java` resolves to the Android/Kotlin
// plugins' Java extension accessor, not the `java` package, so
// `java.util.Properties()` fails to resolve at all (broke CI — see the
// commit that added this comment).
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

fun signingProperty(propertyName: String, envName: String): String? =
    keystoreProperties.getProperty(propertyName) ?: System.getenv(envName)

android {
    namespace = "com.noahfares.fitness_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // PERMANENT. Changing this after any public release makes the app a
        // different app to Android: existing installs cannot upgrade, and their
        // training history is stranded. See docs/70-decisions/ADR-0007-signing.md.
        applicationId = "com.noahfares.fitnessapp"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val storeFilePath = signingProperty("storeFile", "ANDROID_KEYSTORE_PATH")
            val storePasswordValue =
                signingProperty("storePassword", "ANDROID_KEYSTORE_PASSWORD")
            val keyAliasValue = signingProperty("keyAlias", "ANDROID_KEY_ALIAS")
            val keyPasswordValue = signingProperty("keyPassword", "ANDROID_KEY_PASSWORD")

            if (storeFilePath != null &&
                storePasswordValue != null &&
                keyAliasValue != null &&
                keyPasswordValue != null
            ) {
                storeFile = file(storeFilePath)
                storePassword = storePasswordValue
                keyAlias = keyAliasValue
                keyPassword = keyPasswordValue
            }
        }
    }

    buildTypes {
        release {
            val releaseSigning = signingConfigs.getByName("release")
            val isSigningConfigured = releaseSigning.storeFile != null

            // `release.yml` sets this so a release build with any signing
            // material missing fails the build outright, rather than quietly
            // falling back to a debug-signed APK — an unsigned or
            // wrongly-signed public artefact breaks every future upgrade
            // (ADR-0007). Local `flutter build apk --release` without a
            // keystore configured still falls back, for dev convenience.
            if (System.getenv("REQUIRE_RELEASE_SIGNING") == "true" && !isSigningConfigured) {
                throw GradleException(
                    "F-REL-002: release signing material is missing. Set " +
                        "ANDROID_KEYSTORE_PATH, ANDROID_KEYSTORE_PASSWORD, " +
                        "ANDROID_KEY_ALIAS and ANDROID_KEY_PASSWORD " +
                        "(see docs/62-RELEASE.md)."
                )
            }

            signingConfig = if (isSigningConfigured) {
                releaseSigning
            } else {
                signingConfigs.getByName("debug")
            }
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
