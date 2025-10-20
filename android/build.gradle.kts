// define Kotlin/Gradle plugin versions using Kotlin DSL-friendly variables
// Versions used by the buildscript (inlined below to avoid scope issues)
// kotlinVersion = "1.9.22"
// androidGradlePluginVersion = "8.4.0"

buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22")
        classpath("com.android.tools.build:gradle:8.10.0")
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
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
