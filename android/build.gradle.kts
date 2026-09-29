allprojects {
    repositories {
        google()
        mavenCentral()
        // dl.google.com answers 404 through this network's proxy, so new
        // AndroidX artifacts (e.g. androidx.browser for url_launcher) come
        // from Aliyun's mirror of the same repository. Google stays first.
        maven { url = uri("https://maven.aliyun.com/repository/google") }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
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
