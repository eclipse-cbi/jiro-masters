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
  # Latest references an ID, not the version that is used
  # but as the default id=version so it looks like we're using the version in most cases
  latest: "2.426.3",
  masters: {
    [master.id]: master for master in [
      jiro.newController("2.426.3", "3160.vd76b_9ddd10cc"),
      jiro.newController("2.440.1", "3206.vb_15dcf73f6a_9") {
        id: "%s-jdk17" % self.version,
        docker+: {
          from: "eclipsecbi/semeru-ubuntu-coreutils:openjdk17-jammy"
        }
      },
      jiro.newController("2.440.2", "3206.vb_15dcf73f6a_9") {
        id: "%s-jdk17" % self.version,
        docker+: {
          from: "eclipsecbi/semeru-ubuntu-coreutils:openjdk17-jammy"
        }
      },
    ]
  },
}
