import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DuaPage extends StatefulWidget {
  const DuaPage({super.key});

  @override
  State<DuaPage> createState() => _DuaPageState();
}

class _DuaPageState extends State<DuaPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _text = '';

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Get the current user's email
      User? user = FirebaseAuth.instance.currentUser;
      String userEmail = user?.email ??
          'anonymous@example.com'; // Default or anonymous email if not logged in

      // Create a reference to the Firestore collection
      CollectionReference duas = FirebaseFirestore.instance.collection('duas');

      // Add the data to Firestore
      duas.add({
        'title': _title,
        'text': _text,
        'userEmail': userEmail, // Include the user's email
        'timestamp': FieldValue.serverTimestamp(), // Optional: add timestamp
      }).then((value) {
        print('Du\'a Added');
        // Optionally, navigate back or provide user feedback
      }).catchError((error) => print('Failed to add du\'a: $error'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Du\'a'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                onSaved: (value) => _title = value!,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Du\'a Text'),
                onSaved: (value) => _text = value!,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the text of the du\'a';
                  }
                  return null;
                },
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
