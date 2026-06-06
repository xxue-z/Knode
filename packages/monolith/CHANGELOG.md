## 1.1.0

- Changed the merging behavior of the `install` property to be handled per `path`.

## 1.0.2

- Fixed an issue where environment variables were not set when executing shell commands in DartPackage

## 1.0.1

- Fixed shell execution error handling: Process failures now exit with code 127 instead of returning error result
- Changed FVM detection method from `.fvmrc` file to `.fvm` directory

## 1.0.0

- Initial version.
