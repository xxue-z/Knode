
Flutterプロジェクトのモジュラーモノリス構造をサポートするプロジェクト管理ライブラリである。
`monolith.yaml`設定ファイルを用いて、Flutterアプリケーションの開発環境構築やタスク実行を自動化する。

## Features

* **Dart Define管理**: フレーバー別の環境定数定義とコード生成
* **多言語化サポート**: アプリケーションおよびパッケージの国際化リソース管理
* **Xcodeプロジェクト生成**: iOS開発用のプロジェクト設定自動生成
* **シークレットファイル管理**: 機密情報を含むファイルの安全な配布とインストール

## Getting started

プロジェクトルートに`monolith.yaml`設定ファイルを作成し、必要な設定を記述する。
1Password CLIやその他のシークレット管理ツールとの連携も可能である。

## Usage

`monolith.yaml`の基本設定例:

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

このパッケージはFlutterのモジュラーモノリス構造を採用するプロジェクトに最適化されている。
複数のパッケージを含む大規模なFlutterプロジェクトの管理を効率化し、
開発チーム間での設定共有や環境構築の自動化を実現する。

詳細な設定項目や使用方法については、プロジェクトのドキュメントを参照すること。

**FVMサポート**: プロジェクトルートに`.fvm`ディレクトリがあるかを確認してFlutter Version Management (FVM)を自動検出する。FVMが検出された場合は、すべてのFlutterとDartコマンドをFVM経由で実行し、バージョンの一貫性を保証する。

**エラーハンドリング**: Shell実行エラーハンドリングを改善 - プロセス失敗時にエラー結果を返すのではなく、適切にエラーコード127で終了するよう修正し、CI/CDパイプラインでの適切な失敗検知を実現する。
