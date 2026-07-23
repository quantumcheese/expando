plugins {
    kotlin("jvm") version "2.4.10"
    application
}

repositories {
    mavenCentral()
}

dependencies {
    testImplementation(kotlin("test"))
    testImplementation("org.junit.jupiter:junit-jupiter:5.10.0")
}

application {
    // No main class needed for library; placeholder
    mainClass.set("ExpandoKt")
}

tasks.test {
    useJUnitPlatform()
}
