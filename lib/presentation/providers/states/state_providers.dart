import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'state_providers.g.dart';

@riverpod
class DarkMode extends _$DarkMode {
  @override
  bool build() => false;

  void toggleDarkMode() {
    state = !state;
  }
}

@Riverpod(keepAlive: true)
class Username extends _$Username {
  @override
  String build() => 'Jordy Aguilar';

  void changeName(String name) {
    state = name;
  }
}

@riverpod
class Dropdown extends _$Dropdown {
  @override
  String build() => 'k1';

  void changeChoise(String choice) {
    state = choice;
  }
}

@riverpod
class ListMode extends _$ListMode {
  @override
  bool build() => false;

  void toggleListMode() {
    state = !state;
  }
}
