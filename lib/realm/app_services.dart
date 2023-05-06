import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_life_battle_royale/realm/realm_services.dart';
import 'package:realm/realm.dart';

class AppServices with ChangeNotifier {
  String id;
  Uri baseUrl;
  App app;
  User? currentUser;
  AppServices(this.id, this.baseUrl)
      : app = App(AppConfiguration(id, baseUrl: baseUrl));

  Future<User> logInUserEmailPassword(String email, String password) async {
    User loggedInUser =
        await app.logIn(Credentials.emailPassword(email, password));
    currentUser = loggedInUser;
    notifyListeners();
    return loggedInUser;
  }

  // Unhandled Exception: Realm error : Object type Position not configured in the current Realm's schema. Add type Position to your config before opening the Realm

  Future<User> registerUserEmailPassword(String email, String password) async {
    EmailPasswordAuthProvider authProvider = EmailPasswordAuthProvider(app);
    await authProvider.registerUser(email, password);
    User loggedInUser =
    await app.logIn(Credentials.emailPassword(email, password));
    currentUser = loggedInUser;
    // doesnt work, because status of realmServices changes after login
    //realmServices.createGuest(username);
    notifyListeners();
    return loggedInUser;
  }

  Future<void> logOut() async {
    await currentUser?.logOut();
    currentUser = null;
  }
}
