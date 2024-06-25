import 'dart:io';

import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:share_care/screens/home.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  late Iterable<Contact> _contacts;
  late List<bool> _selectedContacts;

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

  void _onContactSelected(int index, bool value) {
    setState(() {
      _selectedContacts[index] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,

          child: _contacts.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: ListView.builder(
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) {
                      final contact = _contacts.elementAt(index);
                      return Column(
                        children: <Widget>[
                          ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                contact.displayName![0].toUpperCase(),
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.blue,
                            ),
                            title: Text(contact.displayName ?? ''),
                            subtitle: Text(
                              contact.phones!.isNotEmpty
                                  ? contact.phones!.first.value ?? ''
                                  : '',
                            ),
                            trailing: Checkbox(
                              value: _selectedContacts[index],
                              onChanged: (value) {
                                _onContactSelected(index, value ?? false);
                              },
                            ),
                          ),
                          Divider(), // Add a Divider after each contact
                        ],
                      );
                    },
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
    );
  }
}
