import re
import subprocess

VERSION = '0.1.5'
FLUTTER_VERSION_CODE = '9'

PROJECT_ROOT = "../"

def modFile(path, regex, replace):
    file = open(PROJECT_ROOT + path, "r+")
    modifiedFile = re.sub(regex, replace, file.read())
    file.seek(0)
    file.write(modifiedFile)
    file.truncate()

# Modify build.gradle -> bump version code
modFile("android/app/build.gradle", "flutterVersionCode\s[=]\s[']\d[']", "flutterVersionCode = '{}'".format(FLUTTER_VERSION_CODE))


# Modify settings_controller.dart -> bump version
modFile("lib/screens/settings/settings_controller.dart", 'VERSION\s[=]\s".*";', 'VERSION = "{}";'.format(VERSION))

#Modify pubspec.yaml -> bump version
modFile("pubspec.yaml", 'version:\s.*\s', 'version: {}\n'.format(VERSION))


# git tag 
if subprocess.call(["git", "tag", "v{}".format(VERSION)]) == 0:
    print("Tag v{} created".format(VERSION))
    
print("Please update CHANGELOG.md and push tag")
