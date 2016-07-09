Set of minigames.
Tested targets:
  - iOS (OK)
  - Android x86 emulator (not runnable now)
  - Mac (rare issure with startup geometry)
  - Windows 7 (OK)

Building:

  1. Install FKTools (check https://github.com/FajraKatviro/FKTools for details)
  2. Clone with --recursive option
  3. Configure project (src/Minigames.pro)
    1. Add 'make imagesets' buid step before 'make' step
    2. **(iOS only)** In build environment variables add path to Qt binary to PATH (I do not know why it missed for iOS by default)
    3. **(iOS only)** Assign provisioning profile with Xcode, trust developer with device, etc.
    4. **(mac/win desktop only, optional)** Add 'make deploy' build step after 'make' step
  4. Build, run and be happy ;)
