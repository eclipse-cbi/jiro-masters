#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

local controller_def = import "controller_definition.json";
local plugins = import "plugins.json";
/**
 * Creates a new Jenkins controller.
 * @param controllerVersion the version of the controller to be used (as published at https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/)
 * @param remotingVersion the version of the remoting code this controller embeds.
 */
local newController(controllerVersion, remotingVersion) = {
  id: self.version,
  version: controllerVersion,
  remoting: {
    version: remotingVersion,
  },
  warBaseUrl: "https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/%s" % self.version,
  local jenkins = self,
  docker: {
    registry: "docker.io",
    repository: "eclipsecbi",
    image: "jiro-master",
    tag: jenkins.id,
    from: "eclipsecbi/semeru-ubuntu-coreutils:openjdk17-jammy",
  },
  username: "jenkins",
  home: "/var/jenkins",
  ref: "/usr/share/jenkins/ref",
  webroot: "/var/cache/jenkins/war",
  pluginroot: "/var/cache/jenkins/plugins",
  war: "/usr/share/jenkins/jenkins.war",
  scripts: {
    base_url::"https://github.com/jenkinsci/docker/raw/master",
    jenkins_support: "%s/jenkins-support" % self.base_url,
    jenkins: "%s/jenkins.sh" % self.base_url,
  },
  plugin_manager: {
    version: "2.13.2",
    jar:"https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/%s/jenkins-plugin-manager-%s.jar" % [self.version, self.version],
  },
  # update center from which the plugins will be download.
  # Does not set the plugin center to be used by the running instance.
  updateCenter: "https://updates.jenkins.io",
  plugins: [
    plugin.name for plugin in plugins.plugins # imported from plugins.json
  ],
  dockerfile: (importstr "Dockerfile") % ( self + { docker_from: jenkins.docker.from } ),
  key_fingerprint: "5BA31D57EF5975CA",
  pubkey: importstr "jenkins-keyring-2023.asc",
};
{
  # Latest references an ID, not the version that is used
  # but as the default id=version so it looks like we're using the version in most cases
  latest: controller_def.latest,
  controllers: {
    [controller.id]: controller for controller in [
      newController(c_def.jenkinsVersion, c_def.remotingVersion) for c_def in controller_def.controllers
    ]
  },
}

