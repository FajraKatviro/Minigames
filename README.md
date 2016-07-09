Set of minigames.
Tested targets:
  - iOS (OK)
  - Android x86 emulator (not runnable now)
  - Mac (rare issure with startup geometry)
  - Windows 7 (OK)

Building:

  1. Install FKTools (check https://github.com/FajraKatviro/FKTools for details)
  2. clone with --recursive option
  3. add 'make imagesets' buid step before 'make' step
  3.1 **(iOS only)** in build environment variables add path to Qt binary to PATH (I do not know why it missed for iOS by default)
  3.2 **(iOS only)** assign provisioning profile with Xcode, trust developer with device, etc.
  3.3 **(mac/win desktop only, optional)** add 'make deploy' build step after 'make' step
  4. build, run and be happy ;)
