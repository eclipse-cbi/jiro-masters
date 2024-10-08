#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************
local jiro = import "jiro.libsonnet";
local controller_def = import "controller_definition.json";
{
  # Latest references an ID, not the version that is used
  # but as the default id=version so it looks like we're using the version in most cases
  latest: controller_def.latest,
  controllers: {
    [controller.id]: controller for controller in [
      jiro.newController(c_def.jenkinsVersion, c_def.remotingVersion) for c_def in controller_def.controllers
    ]
  },
}
