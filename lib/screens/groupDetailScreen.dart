import 'dart:io';

import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_database/firebase_database.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  final String name;
  final String description;
  final String totalAmountSpent;
  final String totalPercentShare;

  const GroupDetailScreen({
    super.key,
    required this.groupId,
    required this.name,
    required this.description,
    required this.totalAmountSpent,
    required this.totalPercentShare,
  });

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  late Iterable<Contact> _contacts;
  late List<bool> _selectedContacts;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _contacts = [];
    _selectedContacts = [];
    if (Platform.isAndroid) {
      _requestPermissions();
    } else {
      fetchContacts();
    }
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      fetchContacts();
    } else {
      // Handle denied permissions
    }
  }

  Future<void> fetchContacts() async {
    try {
      final contacts = await ContactsService.getContacts();
      setState(() {
        _contacts = contacts;
        _selectedContacts = List<bool>.filled(contacts.length, false);
      });
    } catch (e) {
      // Handle error
      print('Error fetching contacts: $e');
    }
  }

  Stream<List<Map<String, String>>> _groupMembersStream() {
    return _database
        .child('groups')
        .child(widget.groupId)
        .child('groupMembers')
        .onValue
        .map((event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value is List) {
        List<dynamic>? values = snapshot.value as List<dynamic>?;
        if (values != null) {
          return values
              .where((value) => value is Map<dynamic, dynamic>)
              .map((value) => Map<String, String>.from(value as Map<dynamic, dynamic>))
              .toList();
        }
      }
      return [];
    });
  }

  void _showContactsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Copy the current state of _selectedContacts for the dialog
        List<bool> dialogSelectedContacts = List.from(_selectedContacts);

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Contact'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: _contacts.isNotEmpty
                    ? ListView.builder(
                        itemCount: _contacts.length,
                        itemBuilder: (context, index) {
                          final contact = _contacts.elementAt(index);
                          return Column(
                            children: <Widget>[
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    contact.displayName![0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(contact.displayName ?? ''),
                                subtitle: Text(
                                  contact.phones!.isNotEmpty
                                      ? contact.phones!.first.value ?? ''
                                      : '',
                                ),
                                trailing: Checkbox(
                                  value: dialogSelectedContacts[index],
                                  onChanged: (value) {
                                    setState(() {
                                      dialogSelectedContacts[index] = value ?? false;
                                    });
                                  },
                                ),
                              ),
                              const Divider(),
                            ],
                          );
                        },
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Update the main state with the selected contacts from the dialog
                    setState(() {
                      _selectedContacts = dialogSelectedContacts;
                    });

                    // Update Firebase with selected contacts
                    _updateGroupMembersInFirebase(dialogSelectedContacts);

                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateGroupMembersInFirebase(List<bool> selectedContacts) async {
    final selectedContactsData = _contacts
        .toList()
        .asMap()
        .entries
        .where((entry) => selectedContacts[entry.key])
        .map((entry) => {
              'name': entry.value.displayName ?? '',
              'phone': entry.value.phones!.isNotEmpty ? entry.value.phones!.first.value ?? '' : '',
            })
        .toList();

    DatabaseReference groupMembersRef = _database.child('groups').child(widget.groupId).child('groupMembers');

    DataSnapshot snapshot = await groupMembersRef.get();

    List<Map<String, String>> existingMembers = [];
    if (snapshot.value is List) {
      List<dynamic>? values = snapshot.value as List<dynamic>?;
      if (values != null) {
        existingMembers = values
            .where((value) => value is Map<dynamic, dynamic>)
            .map((value) => Map<String, String>.from(value as Map<dynamic, dynamic>))
            .toList();
      }
    }

    existingMembers.addAll(selectedContactsData);

    await groupMembersRef.set(existingMembers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: () => _showContactsDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem(
                  context,
                  title: 'Description',
                  content: widget.description,
                  icon: Icons.description,
                ),
                const SizedBox(height: 20),
                _buildDetailItem(
                  context,
                  title: 'Total Amount Spent',
                  content: '\$${widget.totalAmountSpent}',
                  icon: Icons.attach_money,
                ),
                const SizedBox(height: 20),
                _buildDetailItem(
                  context,
                  title: 'Total Percent Share',
                  content: '${widget.totalPercentShare}%',
                  icon: Icons.pie_chart,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Members:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<List<Map<String, String>>>(
                    stream: _groupMembersStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'No members added yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      } else {
                        List<Map<String, String>> groupMembers = snapshot.data!;
                        return ListView.builder(
                          itemCount: groupMembers.length,
                          itemBuilder: (context, index) {
                            var member = groupMembers[index];
                            return ListTile(
                              title: Text("${member['name']}"),
                              subtitle: Text("${member['phone']}"),
                              leading: const Icon(Icons.person),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
              ),
              Divider(color: Colors.grey[300]),
            ],
          ),
        ),
      ],
    );
  }
}
