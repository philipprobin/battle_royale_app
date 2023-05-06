import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_life_battle_royale/resources/socket_methods.dart';
import 'package:real_life_battle_royale/responsive/responsive.dart';
import 'package:real_life_battle_royale/widgets/custom_button.dart';
import 'package:real_life_battle_royale/widgets/custom_text.dart';
import 'package:real_life_battle_royale/widgets/custom_textfield.dart';

import '../realm/realm_services.dart';

class CreateRoomScreen extends StatefulWidget {
  static String routeName = '/create-room';

  const CreateRoomScreen({Key? key}) : super(key: key);

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _nameController = TextEditingController();
  RealmServices? _realmServices;

  @override
  void initState() {
    super.initState();
    _realmServices = Provider.of<RealmServices>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Responsive(
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CustomText(
                shadows: [
                  Shadow(
                    blurRadius: 40,
                    color: Colors.blue,
                  ),
                ],
                text: 'Create Room',
                fontSize: 70,
              ),
              SizedBox(height: size.height * 0.08),
              CustomTextField(
                controller: _nameController,
                hintText: 'Enter your nickname',
              ),
              SizedBox(height: size.height * 0.045),
              CustomButton(
                onTap: () {
                  if (_realmServices != null) {
                    createRoom(_realmServices!, context, _nameController.text);
                  } else {
                    debugPrint("_realmServices is null");
                  }
                },
                text: 'Lobby erstellen',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void createRoom(
      RealmServices realmServices, BuildContext context, String name) {
    realmServices.createRoom(name);
  }
}
