import 'package:realm/realm.dart';

part 'schemas.g.dart';

@RealmModel()
class _Item {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;
  bool isComplete = false;
  late String summary;
  @MapTo('owner_id')
  late String ownerId;
  late int? priority;
}

@RealmModel()
class _Game {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;
  late List<String> players;
}

@RealmModel()
class _Guest {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;
  late String username;
  late bool isOnline = false;
}

@RealmModel()
class _Location {
  @MapTo('_id')
  @PrimaryKey()
  late ObjectId id;
  late double latitude;
  late double longitude;
  @MapTo('owner_id')
  late String ownerId;
}
