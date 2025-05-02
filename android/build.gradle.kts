plugins {
    id("com.google.gms.google-services") version "4.3.15" apply false
}


buildscript {
    repositories {
        google()
        mavenCentral()
    }
}

// Configure repositories for all projects
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Custom build directory configuration
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

// Ensure app module evaluation
subprojects {
    project.evaluationDependsOn(":app")
}

// Clean task to delete build directory
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}