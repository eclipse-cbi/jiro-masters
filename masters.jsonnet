#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************
{

  # Latest reference an ID, not the version that is used
  # but as the default id=version so it looks like we're using the version in most cases
  latest: "2.222.1", 
  masters: [
    $.default + {
      version: "2.229",
      remoting+: {
        version: "4.3",
      },
    },
    $.default + {
      version: "2.222.1",
      remoting+: {
        version: "4.2",
      },
    },
    $.default + {
      version: "2.204.6",
      remoting+: {
        version: "3.36.1",
      },
    },
  ],

  default:: {
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
      "ant",
      "antisamy-markup-formatter",
      "authorize-project",
      "bouncycastle-api",
      "build-timeout",
      "cloudbees-folder",
      "command-launcher",
      "config-file-provider",
      "configuration-as-code",
      "configuration-as-code-support",
      "credentials-binding",
      "email-ext",
      "extended-read-permission",
      "extra-columns",
      "findbugs",
      "gerrit-trigger",
      "ghprb",
      "git",
      "git-parameter",
      "github",
      "github-branch-source",
      "greenballs",
      "jdk-tool",
      "jobConfigHistory",
      "kubernetes",
      "ldap",
      "mailer",
      "matrix-auth",
      "parameterized-trigger",
      "pipeline-maven",
      "pipeline-stage-view",
      "promoted-builds",
      "rebuild",
      "simple-theme-plugin",
      "sonar:2.6.1",
      "ssh-agent",
      "ssh-slaves",
      "timestamper",
      "windows-slaves",
      "workflow-aggregator",
      "ws-cleanup",
      "xvnc",
    ],
    dockerfile: (importstr "Dockerfile") % ( self + { docker_from: jenkins.docker.from } ),
    key_fingerprint: "9B7D32F2D50582E6",
    pubkey: importstr "jenkins.war.pub.asc",
  }
}
