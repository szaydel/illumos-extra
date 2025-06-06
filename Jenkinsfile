/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

/*
 * Copyright 2021 Joyent, Inc.
 * Copyright 2025 MNX Cloud, Inc.
 */

@Library('jenkins-joylib@v1.0.8') _

pipeline {

    agent {
        label 'platform:true && image_ver:24.4.1 && pkgsrc_arch:x86_64 && ' +
            '( dram:16gb || dram:32gb ) && !virt:kvm && fs:pcfs && fs:ufs && ' +
            'jenkins_agent:3'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '30'))
        timestamps()
        parallelsAlwaysFailFast()
    }

    stages {
        stage('trigger smartos-live') {
            when {
                anyOf {
                    branch 'master'
                    triggeredBy cause: 'UserIdCause'
                }
                // Release builds should only be done on smartos-live.git
                // so that our build(..) statement below does not trigger
                // the 'master' branch of smartos-live.
                not {
                    branch pattern: 'release-\\d+', comparator: 'REGEXP'
                }
            }
            steps {
                build(job:'TritonDataCenter/smartos-live/master',
                    wait: false,
                    parameters: [
                        text(name: 'CONFIGURE_PROJECTS',
                            value:
                            "illumos-extra: $BRANCH_NAME: origin\n" +
                            'illumos: master: origin\n' +
                            'local/kbmd: master: origin\n' +
                            'local/kvm-cmd: master: origin\n' +
                            'local/kvm: master: origin\n' +
                            'local/mdata-client: master: origin\n' +
                            'local/ur-agent: master: origin'),
                        booleanParam(name: 'BUILD_STRAP_CACHE', value: true)
                    ])
            }
        }
    }
    post {
        always {
            joySlackNotifications()
        }
    }
}
