import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wally_app/pages/account_screen.dart';
import 'package:wally_app/pages/explore_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedPageIndex = 0;
  var _pages = [
    ExploreScreen(),
    // FavouritesScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wally App',
          style: GoogleFonts.getFont(
            'Merriweather',
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
      ),
      body: _pages[_selectedPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search_rounded),
            label: 'Explore',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.favorite_border_rounded),
          //   activeIcon: Icon(Icons.favorite_rounded),
          //   label: 'Favourites',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'My Account',
          ),
        ],
        currentIndex: _selectedPageIndex,
        onTap: (index) {
          setState(() {
            _selectedPageIndex = index;
          });
        },
        elevation: 8.0,
        backgroundColor: Theme.of(context).canvasColor,
        unselectedItemColor: Theme.of(context).accentColor,
        selectedItemColor: Colors.cyanAccent,
        type: BottomNavigationBarType.shifting,
      ),
    );
  }
}
