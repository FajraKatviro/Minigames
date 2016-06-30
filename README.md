Set of minigames.
Targets:
  - iOS 
  - Android (not runnable now) 

Building (iOS only):

  1. clone with —recursive option
  2. build ImagesetManager
  3. add ‘make imagesets’ build step before ‘make’ step
  4. in build environment variables add path to Qt binary to PATH (I do not know why it missed for iOS by default)
  5. assign provisioning profile with Xcode, trust developer with device, etc.
  6. build, run and be happy ;)