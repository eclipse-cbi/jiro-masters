#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

SHELL=/usr/bin/env bash
CONTROLLERS=jiro.jsonnet
CONTROLLERS_IDS:=$(shell jq -r '.controllers[].id' <<<$$(jsonnet "$(CONTROLLERS)" 2> /dev/null) || echo 'none')

.PHONY: all clean $(CONTROLLERS_IDS)

.bashtools:
	bash -c "$$(curl -fsSL https://raw.githubusercontent.com/completeworks/bashtools/master/install.sh)"

.dockertools: .bashtools
	.bashtools/gitw sparsecheckout https://github.com/eclipse-cbi/dockertools.git $@

$(CONTROLLERS_IDS): .dockertools
	./build.sh $(CONTROLLERS) $@

all: .dockertools
	./build.sh $(CONTROLLERS)

clean: 
	rm -rf .bashtools .dockertools target
