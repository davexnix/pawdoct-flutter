import 'package:flutter/material.dart';
import 'package:pawdoct/screens/home/riwayat_screen.dart';
import 'package:pawdoct/screens/home/beranda_screen.dart';
import 'package:pawdoct/screens/home/diagnosa_screen.dart';
import 'package:pawdoct/screens/home/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static final ValueNotifier<int> navIndex = ValueNotifier<int>(0);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> _screens = [
    const BerandaScreen(),
    const DiagnosaScreen(),
    const RiwayatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HomeScreen.navIndex,
      builder: (context, index, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: _screens[index],
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            currentIndex: index,
            onTap: (newIndex) {
              HomeScreen.navIndex.value = newIndex;
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
              BottomNavigationBarItem(
                icon: Icon(Icons.medical_services),
                label: 'Diagnosa',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
            ],
          ),
        );
      },
    );
  }
}
