A project management library that supports modular monolith structures for Flutter projects.
It automates Flutter application development environment setup and task execution using `monolith.yaml` configuration files.

## Features

* **Dart Define Management**: Environment constant definition and code generation per flavor
* **Multi-language Support**: Internationalization resource management for applications and packages
* **Xcode Project Generation**: Automatic generation of project settings for iOS development
* **Secret File Management**: Safe distribution and installation of files containing confidential information

## Getting started

Create a `monolith.yaml` configuration file in the project root and describe the necessary settings.
Integration with 1Password CLI and other secret management tools is also possible.

## Usage

Basic configuration example for `monolith.yaml`:

```yaml
includes:
  - secrets/monolith.yaml

define:
  output_path: secrets/dart-define/
  generate:
    package_name: foundation_metadata
    helper_path: lib/gen/defines.dart
    # optional, default: `test`
    test_flavor: test
  # required
  flavors:
    development:
      FLAVOR: development
    production:
      FLAVOR: production
    test:
      FLAVOR: development

localization:
  # required
  languages:
    - ja
    - en
  app:
    # required, module name
    package_name: app
    # optional, default: `lib/l10n/`
    arb_path: lib/l10n/
    # optional, default: `intl_app_`
    arb_file_prefix: intl_app_
    # optional, default: `L10nHelper`
    l10n_helper_class_name: L10nHelper
    # optional, default: `lib/l10n/l10n_helper.dart`
    l10n_helper_path: lib/l10n/l10n_helper.dart
  package:
    # required, path to packages(relative to root)
    path_prefixes:
      - app/
      - packages/
    # optional, default: `res/`
    resources_path: res/
    # optional, default: `L10nStringsMixin`
    module_helper_class_name: L10nStringsMixin
    # optional, default: `lib/gen/strings.dart`
    module_helper_path: lib/gen/strings.dart


xcodegen:
  package_name: app
  touch_files:
    - ios/GoogleService-Info.plist

install:
  - path: secrets/config.json
    text_file: |
      {"environment": "production"}
```

## Additional information

This package is optimized for projects that adopt Flutter's modular monolith structure.
It streamlines the management of large-scale Flutter projects containing multiple packages,
and realizes automation of configuration sharing and environment setup among development teams.

For detailed configuration items and usage methods, please refer to the project documentation.

**FVM Support**: Automatically detects Flutter Version Management (FVM) by checking for the presence of a `.fvm` directory in the project root. When FVM is detected, all Flutter and Dart commands are executed through FVM to ensure version consistency.

**Error Handling**: Improved shell execution error handling - modified to properly exit with error code 127 when process fails instead of returning error results, enabling proper failure detection in CI/CD pipelines. 