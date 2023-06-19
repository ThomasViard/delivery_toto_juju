import 'package:flutter/material.dart';
import '../../services/authentication.dart';
import '../views/home.dart';
import '../views/settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  final pageController = PageController();
  final auth = AuthenticationService();

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var signOutButton = TextButton.icon(
        icon: const Icon(
          Icons.person,
          color: Colors.white,
        ),
        label: const Text('Logout', style: TextStyle(color: Colors.white)),
        onPressed: () async {
          await auth.signOut();
        });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text.rich(TextSpan(text: 'Hello, ', children: [
          TextSpan(
            text: auth.auth.currentUser?.email,
          )
        ])),
        actions: [signOutButton],
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: const [
          HomeView(),
          SettingsView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
            pageController.jumpToPage(index);
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Settings'),
          ]),
    );
  }
}
