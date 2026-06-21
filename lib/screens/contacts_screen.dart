// lib/screens/contacts_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:youth_safety_app/providers/auth_provider.dart';
import 'package:youth_safety_app/providers/contact_provider.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  // Controllers for the input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Defer until after first frame so we can safely use context/Provider.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadContacts());
  }

  String? _currentUid(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.currentUser?.uid;
  }

  Future<void> _loadContacts() async {
    final uid = _currentUid(context);
    if (uid == null) return;

    final contactProvider =
        Provider.of<ContactProvider>(context, listen: false);
    await contactProvider.loadContacts(uid);
  }

  // Add a new contact
  void _addContact() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Add Emergency Contact',
          style: TextStyle(
            color: Color(0xFFE53935),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Name Field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Contact Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Phone Field
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Phone Number',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () {
              _nameController.clear();
              _phoneController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),

          // Save Button
          ElevatedButton(
            onPressed: () async {
              final uid = _currentUid(context);
              if (uid == null) return;

              if (_nameController.text.isNotEmpty &&
                  _phoneController.text.isNotEmpty) {
                final contactProvider =
                    Provider.of<ContactProvider>(context, listen: false);

                final name = _nameController.text.trim();
                final phone = _phoneController.text.trim();

                Navigator.pop(context);
                _nameController.clear();
                _phoneController.clear();

                final success = await contactProvider.addContact(
                  uid: uid,
                  name: name,
                  phone: phone,
                );

                if (!mounted) return;
                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        contactProvider.errorMessage ?? 'Failed to add contact',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
            ),
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Delete a contact
  Future<void> _deleteContact(String contactId) async {
    final uid = _currentUid(context);
    if (uid == null) return;

    final contactProvider =
        Provider.of<ContactProvider>(context, listen: false);

    final success =
        await contactProvider.deleteContact(uid: uid, contactId: contactId);

    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(contactProvider.errorMessage ?? 'Failed to delete contact'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      // Top Bar
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        title: const Text(
          'Emergency Contacts',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      // Add Contact Button
      floatingActionButton: FloatingActionButton(
        onPressed: _addContact,
        backgroundColor: const Color(0xFFE53935),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Consumer<ContactProvider>(
        builder: (context, contactProvider, _) {
          if (contactProvider.isLoading && contactProvider.contacts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final contacts = contactProvider.contacts;

          if (contacts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.contacts,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Emergency Contacts Yet!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap + to add a contact',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),

                  // Contact Avatar
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFE53935),
                    child: Text(
                      contact.name.isNotEmpty
                          ? contact.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Contact Name
                  title: Text(
                    contact.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  // Contact Phone
                  subtitle: Text(
                    contact.phone,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),

                  // Delete Button
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () => _deleteContact(contact.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}