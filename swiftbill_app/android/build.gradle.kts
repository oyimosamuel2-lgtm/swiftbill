allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
android {
    compileSdkVersion 34  // Use 34 or higher
    
    defaultConfig {
        applicationId "com.example.swiftbill_app"
        minSdkVersion 21      // Minimum Android 5.0
        targetSdkVersion 34   // Target latest
        versionCode 1
        versionName "1.0"
    }
}