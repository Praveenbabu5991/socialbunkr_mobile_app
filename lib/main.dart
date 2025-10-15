import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/about_page.dart';
import 'pages/contact_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "My Flutter App",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainTabs(), // use TabBar as main screen
    );
  }
}

class MainTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // 5 tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text("My Flutter App"),
          bottom: TabBar(
            isScrollable: true, // allows scrolling if tabs are many
            tabs: [
              Tab(text: "Home", icon: Icon(Icons.home)),
              Tab(text: "About", icon: Icon(Icons.info)),
              Tab(text: "Contact", icon: Icon(Icons.contact_mail)),
              Tab(text: "Login", icon: Icon(Icons.login)),
              Tab(text: "Register", icon: Icon(Icons.person_add)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            HomePage(),    // Stateful
            AboutPage(),   // Stateless
            ContactPage(), // Stateful
            LoginPage(),   // Stateful
            RegisterPage() // Stateful
          ],
        ),
      ),
    );
  }
}
