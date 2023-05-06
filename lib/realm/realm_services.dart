import 'package:real_life_battle_royale/realm/schemas.dart';
import 'package:realm/realm.dart';
import 'package:flutter/material.dart';

class RealmServices with ChangeNotifier {
  static const String queryAllName = "getAllItemsSubscription";
  static const String queryMyItemsName = "getMyItemsSubscription";
  static const String queryMyPostitionsName = "getMyLocationsSubscription";

  static const String queryAllGames = "getAllGamesSubscription";


  static const String queryAllGuests = "getAllGuestsSubscription";

  static const String queryMyHighPriorityItemsName =
      "getMyHighPriorityItemsSubscription";

  bool showAll = false;
  bool offlineModeOn = false;
  bool isWaiting = false;
  late Realm realm;
  User? currentUser;
  App app;

  RealmServices(this.app) {
    if (app.currentUser != null || currentUser != app.currentUser) {
      currentUser ??= app.currentUser;
      realm = Realm(Configuration.flexibleSync(currentUser!,
          [Item.schema, Location.schema, Game.schema, Guest.schema]));
      showAll = (realm.subscriptions.findByName(queryAllName) != null);

      final subscriptionDoesNotExists =
          (realm.subscriptions.findByName(queryMyHighPriorityItemsName) ==
              null);
      final gameSubscriptionDoesNotExists =
          (realm.subscriptions.findByName(queryAllGames) == null);
      final posSubscriptionDoesNotExists =
          (realm.subscriptions.findByName(queryMyPostitionsName) == null);

      final guestSubscriptionDoesNotExists =
      (realm.subscriptions.findByName(queryAllGuests) == null);

      if (realm.subscriptions.isEmpty ||
          gameSubscriptionDoesNotExists ||
          guestSubscriptionDoesNotExists ||
          subscriptionDoesNotExists ||
          posSubscriptionDoesNotExists) {
        updateSubscriptions();
      }
    }
  }

  Future<void> updateSubscriptions() async {
    realm.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.clear();
      mutableSubscriptions.add(realm.all<Game>(), name: queryAllGames);
      // here query execution
      mutableSubscriptions.add(realm.all<Location>(),
          name: queryMyPostitionsName);
      mutableSubscriptions.add(realm.all<Guest>(), name: queryAllGuests);
      mutableSubscriptions.add(
          realm.query<Item>(
            r'owner_id == $0 AND priority <= $1',
            [currentUser?.id, PriorityLevel.high],
          ),
          name: queryMyHighPriorityItemsName);
    });
    await realm.subscriptions.waitForSynchronization();
  }

  Future<void> sessionSwitch() async {
    offlineModeOn = !offlineModeOn;
    if (offlineModeOn) {
      realm.syncSession.pause();
    } else {
      try {
        isWaiting = true;
        notifyListeners();
        realm.syncSession.resume();
        await updateSubscriptions();
      } finally {
        isWaiting = false;
      }
    }
    notifyListeners();
  }

  Future<void> switchSubscription(bool value) async {
    showAll = value;
    if (!offlineModeOn) {
      try {
        isWaiting = true;
        notifyListeners();
        await updateSubscriptions();
      } finally {
        isWaiting = false;
      }
    }
    notifyListeners();
  }

  void createRoom(String name) {
    List<String> players = [];
    players.add(name);
    final newGame = Game(ObjectId(), players: players);
    realm.write<Game>(() => realm.add<Game>(newGame));
    notifyListeners();
  }

  void createGuest(String username) {
    final newGuest = Guest(ObjectId(), username);
    realm.write<Guest>(() => realm.add<Guest>(newGuest));
    notifyListeners();
  }

  void createItem(String summary, bool isComplete, int? priority) {
    final newItem = Item(ObjectId(), summary, currentUser!.id,
        isComplete: isComplete, priority: priority);
    realm.write<Item>(() => realm.add<Item>(newItem));
    notifyListeners();
  }

  Location createLocation(double latitude, double longitude) {
    Location newLocation =
        Location(ObjectId(), latitude, longitude, currentUser!.id);
    debugPrint("Location create $newLocation $latitude $longitude");
    realm.write<Location>(() => realm.add<Location>(newLocation));
    notifyListeners();
    return newLocation;
  }

  Future<void> updateLocation(
      Location location, double latitude, double longitude) async {
    debugPrint("Location update $Location $latitude $longitude");
    if (location.isValid) {
      realm.write(() {
        location.latitude = latitude;
        location.longitude = longitude;
      });
      notifyListeners();
    } else {
      debugPrint("location unvalid");
    }
  }

  void deleteItem(Item item) {
    realm.write(() => realm.delete(item));
    notifyListeners();
  }

  Future<void> updateItem(Item item,
      {String? summary, bool? isComplete, int? priority}) async {
    realm.write(() {
      if (summary != null) {
        item.summary = summary;
      }
      if (isComplete != null) {
        item.isComplete = isComplete;
      }
      if (priority != null) {
        item.priority = priority;
      }
    });
    notifyListeners();
  }

  Future<void> close() async {
    if (currentUser != null) {
      await currentUser?.logOut();
      currentUser = null;
    }
    realm.close();
  }

  @override
  void dispose() {
    realm.close();
    super.dispose();
  }
}

abstract class PriorityLevel {
  static int severe = 0;
  static int high = 1;
  static int medium = 2;
  static int low = 3;
}
