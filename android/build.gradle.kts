// define Kotlin/Gradle plugin versions using Kotlin DSL-friendly variables
// Versions used by the buildscript (inlined below to avoid scope issues)
// kotlinVersion = "1.9.22"
// androidGradlePluginVersion = "8.4.0"

buildscript {
    extra.apply {
        set("kotlin_version", "2.1.0")
        set("gradle_version", "8.12.0")
        set("compileSdkVersion", 36)
        set("targetSdkVersion", 36)
        set("minSdkVersion", 24)
    }
    
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")
        classpath("com.android.tools.build:gradle:8.12.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Optional: Keeps all build outputs in one folder
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    afterEvaluate {
        // Apply Android configuration to all subprojects that use Android plugin
        if (project.plugins.hasPlugin("com.android.application") || 
            project.plugins.hasPlugin("com.android.library")) {
            
            project.extensions.findByType<com.android.build.gradle.BaseExtension>()?.apply {
                compileSdkVersion(36)
                
                defaultConfig {
                    minSdk = 24
                    targetSdk = 36
                }
                
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_21
                    targetCompatibility = JavaVersion.VERSION_21
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
