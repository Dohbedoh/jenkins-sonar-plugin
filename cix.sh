#!/bin/bash
set -euo pipefail
echo "Running with SQ=$SQ_VERSION"

JENKINS_VERSION=1.580.3
 
#deploy the version built by travis
CURRENT_VERSION=`mvn help:evaluate -Dexpression="project.version" | grep -v '^\[\|Download\w\+\:'`
RELEASE_VERSION=`echo $CURRENT_VERSION | sed "s/-.*//g"`
NEW_VERSION="$RELEASE_VERSION-build$CI_BUILD_NUMBER"
echo $NEW_VERSION
mkdir -p target
cd target
curl --user $ARTIFACTORY_QA_READER_USERNAME:$ARTIFACTORY_QA_READER_PASSWORD -sSLO https://repox.sonarsource.com/sonarsource-public-qa/org/jenkins-ci/plugins/sonar/$NEW_VERSION/sonar-$NEW_VERSION.hpi
mv sonar-$NEW_VERSION.hpi sonar.hpi
cd ..

cd its
mvn -Djenkins.runtimeVersion="$JENKINS_VERSION" -Dsonar.runtimeVersion="$SQ_VERSION" -Dmaven.test.redirectTestOutputToFile=false verify 
