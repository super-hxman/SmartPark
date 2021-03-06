import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:smartpark/Screen/PageVehicleList.dart';

import '../Screen/PageHome.dart';
import '../Screen/PageProfile.dart';

class WidgetBottomNavigation extends StatefulWidget {
  static String tag = 'bottomNavigation-widget';

  _WidgetBottomNavigation createState() => new _WidgetBottomNavigation();
}

class _WidgetBottomNavigation extends State<WidgetBottomNavigation>{
  int _currentIndex=0;

  final List<Widget> _children = [
    PageHome(),
    PageVehicleList(),
    PageProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _currentIndex,
        backgroundColor: Colors.white,
        elevation: 3.0,
        items:[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home')  
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            title: Text('Vehicles')
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text('Account')
          ),
        ],
        fixedColor:hex("#5680e9"),
        onTap: (index){
          setState((){
            _currentIndex=index;
          });
        },
      ),
    );
  }
}