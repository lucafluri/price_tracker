import re
import subprocess

'''
Release Bump Procedure:
Bump versions
Update release_notes.txt
Create version commit
Create tag
Push commit
Push version tag

=> Codemagic build triggered on tag push
'''

VERSION = '0.1.7'
FLUTTER_VERSION_CODE = '12' # increment by 1 after each google play upload!

RELEASE_NOTES = """Bug fixes:
- Fix under target calculations
- Fix setting target price bug
- Fix scraper selecting wrong price
"""

PROJECT_ROOT = "./"

def writeFile(path, text):
    file = open(PROJECT_ROOT + path, "w+")
    file.seek(0)
    file.write(text)

def modFile(path, regex, replace):
    file = open(PROJECT_ROOT + path, "r+")
    modifiedFile = re.sub(regex, replace, file.read())
    file.seek(0)
    file.write(modifiedFile)
    file.truncate()

# Bumping Versions
# Modify build.gradle -> bump version code
modFile("android/app/build.gradle", "flutterVersionCode\s[=]\s[']\d*[']", "flutterVersionCode = '{}'".format(FLUTTER_VERSION_CODE))
subprocess.call(["git", "add", "android/app/build.gradle"])

# Modify settings_controller.dart -> bump version
modFile("lib/screens/settings/settings_controller.dart", 'VERSION\s[=]\s".*";', 'VERSION = "{}";'.format(VERSION))
subprocess.call(["git", "add", "lib/screens/settings/settings_controller.dart"])

#Modify pubspec.yaml -> bump version
modFile("pubspec.yaml", 'version:\s.*\s', 'version: {}\n'.format(VERSION))
subprocess.call(["git", "add", "pubspec.yaml"])

# Writing Release Notes
writeFile("release_notes.txt", RELEASE_NOTES)
subprocess.call(["git", "add", "release_notes.txt"])


# # Create Version Commit
# if subprocess.call(["git", "commit", "-m 'chore: :rocket: version {}'".format(VERSION)]) == 0:
#     print("Version {} commit created".format(VERSION))

# # git tag 
# if subprocess.call(["git", "tag", "v{}".format(VERSION)]) == 0:
#     print("Tag v{} created".format(VERSION))
    
print("\nPlease check and create version commit: git commit -m 'chore: :rocket: version {}'".format(VERSION))
print("Create version tag: git tag v{}".format(VERSION))
print("Push commit: git push")
print("And push tag: git push origin v{}'".format(VERSION))

print("\n\nPlease check that minSDKVersion for Android is high enough!")
