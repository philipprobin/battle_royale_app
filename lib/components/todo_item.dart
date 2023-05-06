import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_life_battle_royale/components/widgets.dart';

import '../realm/realm_services.dart';
import '../realm/schemas.dart';
import 'modify_item.dart';

enum MenuOption { edit, delete }

class TodoItem extends StatelessWidget {
  final Item item;

  const TodoItem(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context);
    bool isMine = (item.ownerId == realmServices.currentUser?.id);
    return item.isValid
        ? ListTile(
            leading: Checkbox(
              value: item.isComplete,
              onChanged: (bool? value) async {
                if (isMine) {
                  await realmServices.updateItem(item,
                      isComplete: value ?? false);
                } else {
                  errorMessageSnackBar(context, "Change not allowed!",
                          "You are not allowed to change the status of \n tasks that don't belog to you.")
                      .show(context);
                }
              },
            ),
            title: Row(
              children: [
                _PriorityIndicator(item.priority),
                SizedBox(width: 160, child: Text(item.summary)),
              ],
            ),
            subtitle: Text(
              isMine ? '(mine) ' : '',
              style: boldTextStyle(),
            ),
            trailing: SizedBox(
              width: 25,
              child: PopupMenuButton<MenuOption>(
                onSelected: (menuItem) =>
                    handleMenuClick(context, menuItem, item, realmServices),
                itemBuilder: (context) => [
                  const PopupMenuItem<MenuOption>(
                    value: MenuOption.edit,
                    child: ListTile(
                        leading: Icon(Icons.edit), title: Text("Edit item")),
                  ),
                  const PopupMenuItem<MenuOption>(
                    value: MenuOption.delete,
                    child: ListTile(
                        leading: Icon(Icons.delete),
                        title: Text("Delete item")),
                  ),
                ],
              ),
            ),
            shape: const Border(bottom: BorderSide()),
          )
        : Container();
  }

  void handleMenuClick(BuildContext context, MenuOption menuItem, Item item,
      RealmServices realmServices) {
    bool isMine = (item.ownerId == realmServices.currentUser?.id);
    switch (menuItem) {
      case MenuOption.edit:
        if (isMine) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => Wrap(children: [ModifyItemForm(item)]),
          );
        } else {
          errorMessageSnackBar(context, "Edit not allowed!",
                  "You are not allowed to edit tasks \nthat don't belog to you.")
              .show(context);
        }
        break;
      case MenuOption.delete:
        if (isMine) {
          realmServices.deleteItem(item);
        } else {
          errorMessageSnackBar(context, "Delete not allowed!",
                  "You are not allowed to delete tasks \n that don't belog to you.")
              .show(context);
        }
        break;
    }
  }

  boldTextStyle() {}
}

class _PriorityIndicator extends StatelessWidget {
  final int? priority;

  const _PriorityIndicator(this.priority, {Key? key}) : super(key: key);

  Widget getIconForPriority(int? priority) {
    if (priority == PriorityLevel.low) {
      return const Icon(Icons.keyboard_arrow_down, color: Colors.blue);
    } else if (priority == PriorityLevel.medium) {
      return const Icon(Icons.circle, color: Colors.grey);
    } else if (priority == PriorityLevel.high) {
      return const Icon(Icons.keyboard_arrow_up, color: Colors.orange);
    } else if (priority == PriorityLevel.severe) {
      return const Icon(
        Icons.block,
        color: Colors.red,
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return getIconForPriority(priority);
  }
}
