import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/widgets.dart';
import '../realm/realm_services.dart';
import '../theme.dart';

class CreateUsername extends StatefulWidget {
  const CreateUsername({Key? key}) : super(key: key);

  static String routeName = '/create-username';


  @override
  State<CreateUsername> createState() => _CreateUsernameState();
}

class _CreateUsernameState extends State<CreateUsername> {
  String? _errorMessage;

  late TextEditingController _usernameController;

  @override
  void initState() {
    _usernameController = TextEditingController()..addListener(clearError);

    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.only(top: 30),
        child: Form(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text("Nickname", style: TextStyle(fontSize: 25)),
                loginField(_usernameController,
                    labelText: "Username",
                    hintText: "Enter valid name like Badass420"),
                const Padding(
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                ),
                loginButton(context,
                    child: const Text("Los!"),
                    onPressed: () => _createUsername(
                        context, _usernameController.text.trim())),
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: Text(_errorMessage ?? "",
                      style: errorTextStyle(context),
                      textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void clearError() {
    if (_errorMessage != null) {
      setState(() {
        // Reset error message when user starts typing
        _errorMessage = null;
      });
    }
  }

  void _createUsername(BuildContext context, String? username) async {

      if (username != null) {
        RealmServices realmServices =
            Provider.of<RealmServices>(context, listen: false);
        realmServices.createGuest(username);
      } else {
        setState(() {
          debugPrint("no username");
          _errorMessage = "Gib einen Nickname an";
        });
      }

    Navigator.pushNamed(context, '/');
    /*} catch (err) {
      setState(() {
        debugPrint(err.toString());
        _errorMessage = err.toString();
      });
    }*/
  }
}
