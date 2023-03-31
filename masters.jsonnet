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
  latest: "2.346.3",
  masters: {
    [master.id]: master for master in [
      jiro.newController("2.387.1", "3107.v665000b_51092"),
      jiro.newController("2.375.3", "3077.vd69cf116da_6f"),
      jiro.newController("2.361.4", "3044.vb_940a_a_e4f72e"),
      jiro.newController("2.346.3", "4.13.3"),
    ]
  },
}
