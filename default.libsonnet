#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************
{
    id: self.version,
    version: error "Must provide Jenkins master version",
    remoting: {
      version: error "Must provide remoting version",
    },
    warBaseUrl: "https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/%s" % self.version,
    local jenkins = self,
    docker: {
      registry: "docker.io",
      repository: "eclipsecbi",
      image: "jiro-master",
      tag: jenkins.id,
      from: "eclipsecbi/adoptopenjdk-coreutils:openjdk8-openj9-alpine-slim",
    },
    username: "jenkins",
    home: "/var/jenkins",
    ref: "/usr/share/jenkins/ref",
    webroot: "/var/cache/jenkins/war",
    pluginroot: "/var/cache/jenkins/plugins",
    war: "/usr/share/jenkins/jenkins.war",
    scripts: {
      base_url::"https://github.com/jenkinsci/docker/raw/master",
      install_plugins: "%s/install-plugins.sh" % self.base_url,
      jenkins_support: "%s/jenkins-support" % self.base_url,
      jenkins: "%s/jenkins.sh" % self.base_url,
    },
    # update center from which the plugins will be download. 
    # Does not set the plugin center to be used by the running instance.
    updateCenter: "https://updates.jenkins.io",
    plugins: [
      "analysis-core", 
      "ant", # Ant support (global tools, pipleine, freestype job build step)
      "antisamy-markup-formatter", # Provides "Safe HTML" option
      "authorize-project", #security
      "bouncycastle-api", # IMPLIED by many, maybe not required
      "build-timeout", # automatically abort a build if it’s taking too long
      "cloudbees-folder", # Organize jobs into folder
      "command-launcher", # Launch permanent agents via a command on the master
      "config-file-provider", # TO_REMOVE, direct dependency of "pipeline-maven"
      "configuration-as-code", # ESSENTIAL Jenkins configuration as code (JCasC)
      "configuration-as-code-support", # TO_REMOVE, deprecated
      "credentials-binding", # withCredentials
      "email-ext", # mailer plugin with a lot more options than 'mailer'
      "extended-read-permission", # allows to show job configuration in read-only mode
      "external-monitor-job", #required for upgrade of core installed version
      "extra-columns", # view customization
      "findbugs", #TO_REMOVE, deprecated (all feature in warnings-ng and analysis-model)
      "gerrit-trigger", # ESSENTIAL
      "ghprb", # TO_REMOVE (use GH branch source)
      "git", # ESSENTIAL, direct dependency of other plugins (github..)
      "git-parameter", # lookup for usage
      "github",
      "github-branch-source",
      "greenballs", # ESSENTIAL, no one likes blue balls
      "jdk-tool", # TO_REMOVE, not used (depends on ORacle)
      "jobConfigHistory",
      "kubernetes:1.25.7", # ESSENTIAL
      "ldap", # ESSENTIAL
      "mailer", # ex-core plugin
      "matrix-auth",
      "pam-auth", # required for upgrade of core installed version
      "parameterized-trigger",
      "pipeline-maven",
      "pipeline-stage-view", # blueocean lite
      "promoted-builds",
      "rebuild", # Provides shortcuts to rebuild the last build
      "simple-theme-plugin", # Theme
      "sonar:2.6.1",
      "ssh-agent", # ESSENTIAL
      "ssh-slaves",
      "timestamper", # See time stamps in console log
      "windows-slaves", # TO_REMOVE, useless (only useful when master runs ON windows)
      "workflow-aggregator", # base pipeline
      "ws-cleanup", # Clean-up workspace, useful for all builds that do not run on dynamic build agents
      "xvnc",
    ],
    dockerfile: (importstr "Dockerfile") % ( self + { docker_from: jenkins.docker.from } ),
    key_fingerprint: "9B7D32F2D50582E6",
    pubkey: importstr "jenkins.war.pub.asc",
  }