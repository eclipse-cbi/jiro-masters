[![Build Status](https://ci.eclipse.org/cbi/buildStatus/icon?job=jiro-masters%2Fmaster)](https://ci.eclipse.org/cbi/job/jiro-masters/job/master/)

# JIRO Masters

Defines the metadata for JIRO controllers (for container images among other things). It uses [Jsonnet](https://jsonnet.org) and follows some [best practices](https://github.com/databricks/jsonnet-style-guide).

## How to add a new controller version?

If you want to just add a new controller following the template from `jiro.libsonnet`, you have to add a new instance the `masters` array in the file `masters.jsonnet`, calling the `newController(controllerVersion, remotingVersion)` constructor:

```jsonnet
local jiro = import "jiro.libsonnet";

{
  # Latest references an ID, not the version that is used
  # but as the default id=version so it looks like we're using the version in most cases
  latest: "2.263.3", 
  masters: {
    [master.id]: master for master in [
      jiro.newController("2.263.3", "4.5"),
      jiro.newController("2.263.2", "4.5"),
    ]
  },
}
```

* **controllerVersion** the version of the Jenkins controller as published at https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/. Usually, it's the same string as the advertized version on the following pages:
  * [GitHub releases page](https://github.com/jenkinsci/jenkins/releases)
  * [Jenkins download page](https://www.jenkins.io/download/)
  * [LTS changelog](https://www.jenkins.io/changelog-stable/)
  * [Regular changelog](https://www.jenkins.io/changelog/)
* **remotingVersion** the version of the remoting code the controller embeds. Usually, it’s mentioned in the changelogs (e.g., search for *Update Remoting from 3.36 to 4.2*). But sometimes, it’s not obvious. You have to download the proper `jenkins.war` file from http://mirrors.jenkins.io/war-stable/ and check for the manifest entry `Remoting-Embedded-Version`, e.g.:

```bash
$ curl -SJOL http://mirrors.jenkins.io/war-stable/2.222.1/jenkins.war
$ unzip -p jenkins.war META-INF/MANIFEST.MF | grep "Remoting-Embedded-Version"
Remoting-Embedded-Version: 4.2
```


## How to add custom controller?

All fields in `jiro.libsonnet` can be overriden in the `masters` array elements, e.g. to define a jdk11 based master:

```jsonnet
local jiro = import "jiro.libsonnet";

{
  latest: "2.235.3-jdk11", 
  masters: {
    [master.id]: master for master in [
      jiro.newController("2.235.3", "4.3") {
        id: "%s-jdk11" % self.version,
        docker+: {
          from: "eclipsecbi/adoptopenjdk-coreutils:openjdk11-openj9-alpine-slim",
        },
        pubkey: importstr 'jenkins-2.235.3-onward.war.pub.asc',
        key_fingerprint: 'FCEF32E745F2C3D5',
      },
    ]
  }
}
```

## Building

To build all controllers as defined in masters.jsonnet, run

```bash
make all
```

To build a single controller, run

```bash
make <id>
```

where `<id>` is the controller's ID as specified in `masters.jsonnet`

## Dependencies

* [docker](https://www.docker.com)
* [bash 4](https://www.gnu.org/software/bash/)
* [jq](https://stedolan.github.io/jq/)
* [jsonnet](https://jsonnet.org)