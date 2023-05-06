import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:real_life_battle_royale/provider/room_data_provider.dart';
import 'package:real_life_battle_royale/realm/app_services.dart';
import 'package:real_life_battle_royale/realm/realm_services.dart';
import 'package:real_life_battle_royale/screens/create_room_screen.dart';
import 'package:real_life_battle_royale/screens/create_username.dart';
import 'package:real_life_battle_royale/screens/game_screen.dart';
import 'package:real_life_battle_royale/screens/homepage.dart';
import 'package:real_life_battle_royale/screens/join_room_screen.dart';
import 'package:real_life_battle_royale/screens/log_in.dart';
import 'package:real_life_battle_royale/screens/main_menu_screen.dart';
import 'package:real_life_battle_royale/screens/map_screen.dart';
import 'package:real_life_battle_royale/theme.dart';
import 'package:real_life_battle_royale/utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final realmConfig = json
      .decode(await rootBundle.loadString('assets/config/atlasConfig.json'));
  String appId = realmConfig['appId'];
  Uri baseUrl = Uri.parse(realmConfig['baseUrl']);

  return runApp(MultiProvider(providers: [
    ChangeNotifierProvider<AppServices>(
        create: (_) => AppServices(appId, baseUrl)),
    ChangeNotifierProxyProvider<AppServices, RealmServices?>(
        // RealmServices can only be initialized only if the user is logged in.
        create: (context) => null,
        update: (BuildContext context, AppServices appServices,
            RealmServices? realmServices) {
          return appServices.app.currentUser != null
              ? RealmServices(appServices.app)
              : null;
        }),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser =
        Provider.of<RealmServices?>(context, listen: false)?.currentUser;

    return WillPopScope(
      onWillPop: () async => false,
      child: MaterialApp(
        title: 'Realm Flutter Todo',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: bgColor,
        ),
        initialRoute: currentUser != null ? '/' : '/login',
        routes: {
          '/': (context) => const HomePage(),
          '/login': (context) => LogIn(),
          '/create-username': (context) => const CreateUsername(),
          MapScreen.routeName: (context) => const MapScreen(),
          CreateRoomScreen.routeName: (context) => const CreateRoomScreen(),
        },
      ),
    );
  }
}

//
