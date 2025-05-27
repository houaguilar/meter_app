import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/widgets.dart';

/// Pantalla principal que actúa como contenedor para las vistas secundarias
class HomeScreen extends StatefulWidget {
  static const String name = 'home-screen';
  final Widget childView;

  const HomeScreen({
    super.key,
    required this.childView,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setScreenOrientation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _setScreenOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Log solo en debug
    assert(() {
      debugPrint('App lifecycle state: $state');
      return true;
    }());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: widget.childView,
      ),
      bottomNavigationBar: const CustomBottomNavigation(),
      extendBody: false,
    );
  }
}