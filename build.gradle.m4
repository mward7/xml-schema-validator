apply plugin: 'java'

version = '0.1'
buildDir = 'build'

task(debug, dependsOn: 'classes', type: JavaExec) {
    main = 'org.gtri.niem.schema_assembly.CLI'
    classpath = sourceSets.main.runtimeClasspath
//        args 'server', 'my-application.yml'
    debug true
}

jar {
    manifest {
        attributes 'Implementation-Title': 'XML Schema Validator',
                'Implementation-Version': version,
		        'Main-Class': 'org.gtri.niem.xml_schema_validator.CLI'
    }
}

repositories {
    mavenCentral()
}

dependencies {
    compile 'commons-cli:commons-cli:1.2'
    compile 'xerces:xercesImpl:2.11.0'
    compile 'org.slf4j:slf4j-api:1.7.7'
    // compile 'org.slf4j:slf4j-api:1.7.25'
    compile 'org.slf4j:slf4j-simple:1.7.7'
    compile 'org.slf4j:slf4j-ext:1.7.7'
    compile 'xml-resolver:xml-resolver:1.2'
    testCompile 'junit:junit:4.12'
    // testCompile group: 'junit', name: 'junit', version: '4.+'
}

test {
    systemProperties 'property': 'value'

    useJUnit()

    maxHeapSize = '1G'
}

uploadArchives {
    repositories {
        flatDir {
            dirs 'repos'
        }
    }
}

task dist(type: Tar) {
    dependsOn jar
    into('') {
        from jar.archivePath
        from configurations.runtime
    }
}

artifacts {
   archives dist
}

allprojects {
    gradle.projectsEvaluated {
        tasks.withType(JavaCompile) {
            options.compilerArgs << "-Xlint:all"
        }
    }
}
