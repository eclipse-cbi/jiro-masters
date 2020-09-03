#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************
local jiro = import "jiro.libsonnet";
{
  # Latest reference an ID, not the version that is used
  # but as the default id=version so it looks like we're using the version in most cases
  latest: "2.222.4", 
  masters: {
    [master.id]: master for master in [
      jiro.newController("2.235.3", "4.3") + {
        id: "%s-jdk11" % self.version,
        docker+: {
          from: "eclipsecbi/adoptopenjdk-coreutils:openjdk11-openj9-alpine-slim",
        },
        pubkey: importstr 'jenkins-2.235.3-onward.war.pub.asc',
        key_fingerprint: 'FCEF32E745F2C3D5',
      },
      jiro.newController("2.235.3", "4.3") + {
        pubkey: importstr 'jenkins-2.235.3-onward.war.pub.asc',
        key_fingerprint: 'FCEF32E745F2C3D5',
      },
      jiro.newController("2.229", "4.3"),
      jiro.newController("2.222.4", "4.2.1"),
    ]
  },
}
