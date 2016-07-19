Set of minigames.
Tested targets:
  - iOS (OK)
  - Android arm7 (OK)
  - Mac (OK)
  - Windows 7 (rare issue with window activation)
  - Ubuntu (issue with deb package)

Not tested targets:
  - Android x86
  - Windows 8
  - Windows 10

Building:

  1. Install FKTools (check https://github.com/FajraKatviro/FKTools for details)
  2. Clone with --recursive option
  3. Configure project (src/Minigames.pro)
    1. Add 'make imagesets' buid step before 'make' step
    2. **(iOS/android only)** In build environment variables add QTDIR and set path to Qt installation, i.e. C:\Qt\5.7\android_armv7 (I do not know why it missed for iOS and android by default)
    3. **(iOS only)** Assign provisioning profile with Xcode, trust developer with device, etc.
    4. **(desktop only, optional)** Add 'make deploy' build step after 'make' step to create distributable package
  4. Build, run and be happy ;)
