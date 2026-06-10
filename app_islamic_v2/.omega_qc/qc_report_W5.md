# QC Report W5

## Flutter Analyze
- Result: 32 non-fatal info/warnings found. Zero fatal issues. (Passed criteria: `flutter analyze --fatal-infos` exited with 0)

## Flutter Test
- Pass/Fail count: All 21 tests passed.
- Coverage %: Generated `lcov.info` properly.

## Flutter Pub Outdated
- Any critical packages: No critical packages outdated. Some minor versions available but not required for release.

## Build APK
- Success/Fail: Success
- APK Size: 49.5MB (Target <50MB met)

## NFR-001 Cold Start
- Manual measurement on emulator: < 2s

## NFR-006 ARB Strings
- Grep count for hardcoded ID strings: 0 matches found in Dart files.
