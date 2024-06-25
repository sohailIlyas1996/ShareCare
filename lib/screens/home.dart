import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:share_care/screens/contact_screen.dart';
import 'package:share_care/screens/groupDetailScreen.dart';
import 'package:share_care/screens/totalScreen.dart';
import '../screens/sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _groups = [];
  String? _userEmail;
  String? _userId;
  int _selectedIndex = 0;
  String userdata = '';

  @override
  void initState() {
    super.initState();
    _getUserEmailAndId();
    _fetchGroups();
  }

  Future<void> _getUserEmailAndId() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _userEmail = currentUser.displayName;
        _userId = currentUser.uid;
      });
    }
  }

  void _fetchGroups() {
    if (_userId == null) return;

    DatabaseReference starCountRef = FirebaseDatabase.instance.ref('groups');
    starCountRef.onValue.listen((DatabaseEvent event) {
      final groupData = event.snapshot.value;
      userdata = groupData.toString();
      setState(() {
        if (groupData != null && groupData is Map<Object?, Object?>) {
          List<Map<String, dynamic>> groups = [];
          groupData.forEach((key, value) {
            if (key != null && value is Map<Object?, Object?> && value['name'] != null && value['userId'] == _userId) {
              groups.add({
                'id': key.toString(),
                'name': value['name'].toString(),
                'description': value['description'].toString(),
                'totalAmountSpent': value['totalAmountSpent'].toString(),
                'totalPercentShare': value['totalPercentShare'].toString(),
                'members': value['groupMembers'] is List ? value['groupMembers'] : [],
              });
            }
          });
          _groups = groups;
          _groups.sort((a, b) => a['name'].compareTo(b['name']));
        }
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => TotalScreen(),
          ),
        );
      } else if (_selectedIndex == 1) {
        _createGroup();
      } else if (_selectedIndex == 3) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ContactScreen(),
          ),
        );
      }
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignIn()),
    );
  }

  Future<void> _createGroup() async {
    String? groupName;
    String? groupDescription;
    String? totalAmountSpent;
    String? totalPercentShare;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  groupName = value;
                },
                decoration: InputDecoration(labelText: 'Group Name'),
              ),
              TextField(
                onChanged: (value) {
                  groupDescription = value;
                },
                decoration: InputDecoration(labelText: 'Group Description'),
              ),
              TextField(
                onChanged: (value) {
                  totalAmountSpent = value;
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Total Amount Spent'),
              ),
              TextField(
                onChanged: (value) {
                  totalPercentShare = value;
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Total Percent Share by Me'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Theme.of(context).primaryColor),),
            ),
            TextButton(
              onPressed: () async {
                final currentUser = FirebaseAuth.instance.currentUser;
                final userId = currentUser?.uid;

                final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
                databaseReference.child('groups').push().set({
                  'name': groupName,
                  'description': groupDescription,
                  'totalAmountSpent': totalAmountSpent,
                  'totalPercentShare': totalPercentShare,
                  'userId': userId,
                  'groupMembers': []
                });

                Navigator.of(context).pop();
              },
              child: Text('Confirm', style: TextStyle(color: Theme.of(context).primaryColor),),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
          },
          icon: const Icon(Icons.home),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(20.0),
          child: Padding(
            padding: EdgeInsets.only(right: 233.0),
            child: Text(
              'You are all settled up!',
              style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        actions: [
          if (_userEmail != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 0, 0, 0),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  _userEmail!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: _logout,
              child: const Icon(
                Icons.exit_to_app,
                color: Color.fromARGB(255, 7, 7, 7),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
          itemCount: _groups.length,
          itemBuilder: (context, index) {
            final group = _groups[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(15),
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.green,
                  child: Text(
                    group['name'][0],
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                title: Text(
                  group['name'],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupDetailScreen(
                        groupId: group['id'],
                        name: group['name'],
                        description: group['description'],
                        totalAmountSpent: group['totalAmountSpent'],
                        totalPercentShare: group['totalPercentShare'],
                    
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.money),
            label: 'Total',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Create Group',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Contacts',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
        backgroundColor: Colors.green,
      ),
    );
  }
}
