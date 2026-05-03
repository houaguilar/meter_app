import 'package:flutter_riverpod/flutter_riverpod.dart';

class DarkMode extends Notifier<bool> {
  @override
  bool build() => false;

  void toggleDarkMode() {
    state = !state;
  }
}

final darkModeProvider = NotifierProvider<DarkMode, bool>(DarkMode.new);

class Username extends Notifier<String> {
  @override
  String build() => 'Jordy Aguilar';

  void changeName(String name) {
    state = name;
  }
}

final usernameProvider = NotifierProvider<Username, String>(Username.new);

class Dropdown extends Notifier<String> {
  @override
  String build() => 'k1';

  void changeChoise(String choice) {
    state = choice;
  }
}

final dropdownProvider = NotifierProvider<Dropdown, String>(Dropdown.new);

class ListMode extends Notifier<bool> {
  @override
  bool build() => false;

  void toggleListMode() {
    state = !state;
  }
}

final listModeProvider = NotifierProvider<ListMode, bool>(ListMode.new);
