#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

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
    from: "eclipsecbi/semeru-ubuntu-coreutils:openjdk11-jammy",
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
    version: "2.12.13",
    jar:"https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/%s/jenkins-plugin-manager-%s.jar" % [self.version, self.version],
  },
  # update center from which the plugins will be download.
  # Does not set the plugin center to be used by the running instance.
  updateCenter: "https://updates.jenkins.io",
  plugins: [
    "ant", # Ant support (global tools, pipeline, freestyle job build step)
    "antisamy-markup-formatter", # Provides "Safe HTML" option
    "authorize-project", #security
    "bouncycastle-api", # IMPLIED by many, maybe not required
    "build-timeout", # automatically abort a build if it’s taking too long
    "cloudbees-folder", # Organize jobs into folder
    "command-launcher", # Launch permanent agents via a command on the controller
    "config-file-provider", # TO_REMOVE, direct dependency of "pipeline-maven"
    "configuration-as-code", # ESSENTIAL Jenkins configuration as code (JCasC)
    "credentials-binding", # withCredentials
    "email-ext", # mailer plugin with a lot more options than 'mailer'
    "extended-read-permission", # allows to show job configuration in read-only mode
    "external-monitor-job", #required for upgrade of core installed version
    "extra-columns", # view customization
    "ghprb", # TO_REMOVE (use GH branch source)
    "git", # ESSENTIAL, direct dependency of other plugins (github..)
    "git-parameter", # lookup for usage
    "github",
    "github-branch-source",
    "gitlab-plugin",
    "gitlab-branch-source",
    "jdk-tool", # TO_REMOVE, not used (depends on ORacle)
    "jobConfigHistory",
    "kubernetes", # ESSENTIAL
    "ldap", # ESSENTIAL
    "mailer", # ex-core plugin
    "matrix-auth",
    "maven-plugin",
    "pam-auth", # required for upgrade of core installed version
    "parameterized-trigger",
    "pipeline-maven",
    "pipeline-stage-view", # blueocean lite
    "promoted-builds",
    "rebuild", # Provides shortcuts to rebuild the last build
    "simple-theme-plugin", # Theme
    "sonar", # Using latest plugin version after SonarQube server has been turned off
    "ssh-agent", # ESSENTIAL
    "ssh-slaves",
    "timestamper", # See time stamps in console log
    "warnings-ng", # ESSENTIAL: static code analysis, replaces findbugs plugin, etc
    "workflow-aggregator", # base pipeline
    "ws-cleanup", # Clean-up workspace, useful for all builds that do not run on dynamic build agents
    "xvnc",
  ],
  dockerfile: (importstr "Dockerfile") % ( self + { docker_from: jenkins.docker.from } ),
  key_fingerprint: "5BA31D57EF5975CA",
  pubkey: importstr "jenkins-keyring-2023.asc",
};
{
  newController:: newController,
}