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
  latest: "2.452.4",
  controllers: {
    [controller.id]: controller for controller in [
      jiro.newController("2.462.3", "3248.3250.v3277a_8e88c9b_"),
      jiro.newController("2.462.1", "3248.3250.v3277a_8e88c9b_"),
      jiro.newController("2.452.4", "3206.3208.v409508a_675ff"),
      jiro.newController("2.452.1", "3206.vb_15dcf73f6a_9"),
    ]
  },
}
