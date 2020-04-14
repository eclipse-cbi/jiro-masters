#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************
FROM %(docker_from)s

# These environment variables will be used in the uid_entrypoint script from the parent image
ENV USER_NAME="%(username)s"
ENV HOME="%(home)s"

# jenkins version being bundled in this docker image
ENV JENKINS_HOME="%(home)s"
ENV JENKINS_VERSION="%(version)s"
ENV JENKINS_WAR="%(war)s"
ENV REF="%(ref)s"

ENV COPY_REFERENCE_FILE_LOG="%(home)s/copy_reference_file.log"

VOLUME [ "%(home)s", "%(webroot)s", "%(pluginroot)s" ]
WORKDIR "%(home)s"

ENTRYPOINT ["uid_entrypoint", "/usr/bin/dumb-init", "--", "/usr/local/bin/jenkins.sh"]

RUN mkdir -p $(dirname "%(war)s") && mkdir -p "%(ref)s"

COPY scripts/* /usr/local/bin/
COPY war/jenkins.war "%(war)s"
COPY ref/ "%(ref)s/"
