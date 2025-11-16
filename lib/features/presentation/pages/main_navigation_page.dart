import 'package:flutter/material.dart';

import 'recent_movies_page.dart';
import 'top_rated_page.dart';
import 'watchlist_page.dart';
import 'favorites_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  _MainNavigationPageState createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  // Screens in order
  final List<Widget> _screens = const [
    RecentMoviesPage(),
    //TopRatedPage(),
    //WatchlistPage(),
    //FavoritesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),

      body: _screens[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        backgroundColor: const Color(0xFF161B22),
        selectedItemColor: const Color(0xFF1F6FEB), // Blue
        unselectedItemColor: Colors.grey,

        type: BottomNavigationBarType.fixed,
        elevation: 8,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: "Recent",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: "Top Rated",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.visibility),
            label: "Watchlist",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorites",
          ),
        ],
      ),
    );
  }
}
