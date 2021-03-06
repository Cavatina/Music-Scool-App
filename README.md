# Music'scool App
[![Codemagic build status for master branch](https://api.codemagic.io/apps/5fc5305a253cd4a4babce97d/deploy-master/status_badge.svg)](https://codemagic.io/app/5fc5305a253cd4a4babce97d/) <sup>[master]</sup> [![Codemagic build status for feature branches](https://api.codemagic.io/apps/5fc5305a253cd4a4babce97d/development/status_badge.svg)](https://codemagic.io/app/5fc5305a253cd4a4babce97d/) <sup>[development]</sup>

Mobile app for Music'scool students. Developed for Music'scool, Denmark.

## Copyright

Copyright (C) 2020 Music'scool, Denmark.

All artwork, including the Music'scool logo, is (C) Music'scool, Denmark.
All rights reserved. Any use or redistribution without explicit permission
is prohibited.

The remainder of the assets in this repository, including all source code,
is licensed under GPLv3. See LICENSE in this directory.


## Development Requirements

- [Flutter](https://flutter.dev)

To initialize the project, either load it using an IDE (Android Studio) with the
Flutter/Flutter Intl plugins, or run:

```shell script
flutter pub get
```

### Generating i18n files
These are not committed to git. If not using an IDE with Flutter Intl, run:

```shell script
flutter pub global activate intl_utils
flutter pub global run intl_utils:generate
```

### Generating JSON model boilerplate

Model from/to JSON boilerplate is generated by json_serializable.  
Since the models are not updated often, and the generation is slow, these
files are committed to git.

In order to regenerate these models (`lib/*.g.dart`), run:

```shell script
flutter pub run build_runner build --delete-conflicting-outputs
```

Until the fix for https://github.com/dart-lang/build/issues/2835 is merged into master,
this may result in an "Unhandled Exception" about a missing `.dart_tool/flutter_gen/pubspec.yaml`.

As a workaround, manually create this file:
```shell script
mkdir -p .dart_tool/flutter_gen
echo "dependencies:" > .dart_tool/flutter_gen/pubspec.yaml
```

If any other issues remain, try:
```shell script
flutter pub cache repair
```

