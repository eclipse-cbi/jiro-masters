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
  latest: "2.263.3", 
  masters: {
    [master.id]: master for master in [
      jiro.newController("2.277.1", "4.6"),
      jiro.newController("2.263.3", "4.5"),
      jiro.newController("2.263.2", "4.5"),
    ]
  },
}
