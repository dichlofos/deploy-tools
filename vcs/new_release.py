#!/usr/bin/env python

import coloredlogs
import datetime
import sys
import os


def detect_version_file():
    version_files = [
        'version',
        'site/VERSION',
    ]
    for version_file in version_files:
        if os.path.exists(version_file):
            return version_file

    print "Version file was not found at", ", ".join(version_files)
    sys.exit(1)


def detect_vcs():
    if os.path.exists('.hg'):
        return 'hg'
    if os.path.exists('.git'):
        return 'git'

    print "Cannot detect vcsVersion file was not found at", ", ".join(version_files)
    sys.exit(1)


def main():
    coloredlogs.install()
    coloredlogs.set_level(logging.DEBUG)

    vcs = detect_vcs()

    version_file = detect_version_file()

    current_version = open(version_file).read().strip()
    version_components = current_version.split('.')
    version_components[2] = str(int(version_components[2]) + 1)
    new_version = '.'.join(version_components)

    logging.info("New version is %s", new_version)
    with open(version_file, 'w') as vf:
        vf.write(new_version + '\n')
    os.system('{} commit -m "Version updated to {}" {}'.format(vcs, new_version, version_file))
    os.system('{} tag {}-prod-{}'.format(vcs, new_version, datetime.datetime.now().strftime("%Y.%m.%d")))
    os.system('bash ./push-prod.sh')
