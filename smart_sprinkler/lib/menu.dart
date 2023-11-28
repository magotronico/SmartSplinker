import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      const UserAccountsDrawerHeader(
        accountName: Text(
          "user1",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        accountEmail: Text("user1@tec.mx"),
        currentAccountPicture: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(
            Icons.person,
            color: Color.fromARGB(173, 42, 181, 246),
            size: 55,
          ),
        ),
        decoration: BoxDecoration(
          color: Color.fromARGB(194, 55, 173, 228),
        ),
      ),
      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text("Log out"),
        onTap: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', false);
          Navigator.of(context).pushReplacementNamed('/');
        },
      ),
    ];

    return Drawer(
      child: ListView(
        children: children,
      ),
    );
  }
}
