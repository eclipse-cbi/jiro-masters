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
  latest: "2.414.2",
  masters: {
    [master.id]: master for master in [
      jiro.newController("2.414.3", "3131.vf2b_b_798b_ce99") + { key_fingerprint: "5BA31D57EF5975CA", pubkey: importstr "jenkins-keyring-2023.asc" },
      jiro.newController("2.414.2", "3131.vf2b_b_798b_ce99") + { key_fingerprint: "5BA31D57EF5975CA", pubkey: importstr "jenkins-keyring-2023.asc" },
    ]
  },
}
