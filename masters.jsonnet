#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************
local default = import "default.libsonnet";
{
  # Latest reference an ID, not the version that is used
  # but as the default id=version so it looks like we're using the version in most cases
  latest: "2.222.3", 
  masters: {
    [master.id]: master for master in [
      default + {
        version: "2.229",
        remoting+: {
          version: "4.3",
        },
      },
      default + {
        version: "2.222.3",
        remoting+: {
          version: "4.2",
        },
      },
      default + {
        version: "2.222.1",
        remoting+: {
          version: "4.2",
        },
      },
      default + {
        version: "2.204.6",
        remoting+: {
          version: "3.36.1",
        },
      },
    ]
  },
}
