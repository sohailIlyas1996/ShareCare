import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_care/screens/home.dart';

class TotalScreen extends StatefulWidget {
  const TotalScreen({Key? key}) : super(key: key);

  @override
  State<TotalScreen> createState() => _TotalScreenState();
}

class _TotalScreenState extends State<TotalScreen> {
  double _totalSpent = 0;
  double _userSpent = 0;
  final DatabaseReference _groupsRef = FirebaseDatabase.instance.ref().child('groups');
  late String userId;
  bool _disposed = false; // Add a boolean variable to track disposal

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  void dispose() {
    _disposed = true; // Set _disposed to true when widget is disposed
    super.dispose();
  }

  Future<void> _getUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        userId = currentUser.uid;
      });
    }

    double total = 0;
    double userTotal = 0;

    _groupsRef.onValue.listen((event) {
      if (_disposed) return; // Check if widget is disposed before updating state
      final groupsData = event.snapshot.value as Map<dynamic, dynamic>?; // Nullable map
      if (groupsData != null) {
        groupsData.forEach((key, value) {
          final totalAmountSpent = double.tryParse(value['totalAmountSpent'] ?? '0') ?? 0;
          final totalPercentShare = double.tryParse(value['totalPercentShare'] ?? '0') ?? 0;
          total += totalAmountSpent;
          if (value['userId'] == userId) {
            userTotal += totalAmountSpent * (totalPercentShare / 100);
          }
        });
      
        if (!_disposed) { // Check if the widget is still mounted before calling setState
          setState(() {
            _totalSpent = total;
            _userSpent = userTotal;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Total Screen'),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total Spend \$$_totalSpent',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[600],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'User Spend \$$_userSpent',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            if (_totalSpent > 0)
              AspectRatio(
                aspectRatio: 1.5,
                child: Container(
                  margin: EdgeInsets.all(20),
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          borderSide: const BorderSide(width: 2, color: Colors.black),
                          radius: 50,
                          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          color: Colors.red,
                          value: _totalSpent,
                          title: _totalSpent.toInt().toString(),
                        ),
                        PieChartSectionData(
                          borderSide: const BorderSide(width: 2, color: Colors.black),
                          radius: 50,
                          color: Colors.green,
                          value: _userSpent,
                          title: _userSpent.toInt().toString(),
                        ),
                      ],
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 150),
                    swapAnimationCurve: Curves.linear,
                  ),
                ),
              ),
            if (_totalSpent <= 0)
              const Text(
                'No groups created yet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
