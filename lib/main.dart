import 'package:flutter/material.dart';

import 'ui/demo_app_state.dart';
import 'ui/screens/today_screen.dart';
import 'ui/screens/tasks_screen.dart';

void main() {
  runApp(const MyTimeApp());
}

class MyTimeApp extends StatelessWidget {
  const MyTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyTime (E.1A)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const Shell(),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _index = 0;
  final DemoAppState _state = DemoAppState.initial();

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      TodayScreen(
        state: _state,
        onStateChanged: (s) => setState(() => _state.copyFrom(s)),
      ),
      TasksScreen(
        state: _state,
        onStateChanged: (s) => setState(() => _state.copyFrom(s)),
      ),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today),
            label: 'DZIŚ',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist),
            label: 'ZADANIA',
          ),
        ],
      ),
    );
  }
}
