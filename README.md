[![Build Status](https://ci.eclipse.org/cbi/buildStatus/icon?job=jiro-masters%2Fmaster)](https://ci.eclipse.org/cbi/job/jiro-masters/job/master/)

# JIRO Masters

Defines the base container images for JIRO masters.

## How to add custom master?

All fields in `default::` can be overriden in the supported array elements, e.g. to define a jdk11 based master:

```jsonnet
{
  releases: {
    supported: [
      {
        id: "%s-jdk11" % self.version,
        version: "2.222.1",
        remoting+: {
          version: "4.2",
        },
        docker+: {
          from: "eclipsecbi/adoptopenjdk-coreutils:openjdk11-openj9-alpine-slim",
        },
      },
    ]
  }
}
```

## Dependencies

* [docker](https://www.docker.com)
* [bash 4](https://www.gnu.org/software/bash/)
* [jq](https://stedolan.github.io/jq/)
* [jsonnet](https://jsonnet.org)