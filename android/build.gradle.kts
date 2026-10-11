buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // 🔥 Firebase plugin
        classpath("com.google.gms:google-services:4.4.1")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Opsiyonel: build klasörünü dışa taşımak istersen bu kalsın
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

// Uygulama modülünü tüm alt projelerden önce değerlendirmek için
subprojects {
    project.evaluationDependsOn(":app")
}

// Temizleme task'ı
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
