import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../realm/schemas.dart';
import '../realm/realm_services.dart';

class LocationItem extends StatelessWidget {
  final Location item;

  const LocationItem(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context);
    bool isMine = (item.ownerId == realmServices.currentUser?.id);

    return isMine
        ? Container(
            color: Colors.green,
            child: Text(item.longitude.toString()),
          )
        : Container(
            color: Colors.red,
          );
  }
}
