# Android signing and recovery

Keep upload keys and passwords outside the repository, public artifacts, chat and logs. Pass the private signing directory explicitly to tools/Build-AndroidRelease.ps1. That script expects upload-keystore.p12 and a Windows current-user DPAPI encrypted upload-password.dpapi file. It does not create credentials or publish a release.

DPAPI protection is tied to the Windows user/profile. Copying its encrypted file alone is not a portable backup. The studio should retain its keystore and portable password in an authorized encrypted backup, with the backup password held separately. This source integration did not inspect, export, change or back up signing credentials.

The release script passes signing information through a process environment to the Gradle init script and clears the temporary password buffer afterward. Signing remains an explicitly authorized release operation, separate from source validation.

For a Play-installed build, link the Play App Signing certificate shown in Play Console to the Android OAuth credential. That certificate can differ from the upload certificate. A separately linked debug certificate is needed for sideloaded debug testing. Verify current certificate linkage and tester access before interpreting authentication failures.
