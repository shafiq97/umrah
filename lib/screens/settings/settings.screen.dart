import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:fintracker/extension.dart';
import 'package:fintracker/helpers/db.helper.dart';
import 'package:fintracker/providers/app_provider.dart';
import 'package:fintracker/screens/onboard/widgets/profile.dart';
import 'package:fintracker/widgets/dialog/confirm.modal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? phoneNumber;

  @override
  void initState() {
    super.initState();
    _fetchPhoneNumber();
  }

  Future<void> _fetchPhoneNumber() async {
    var userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      setState(() {
        phoneNumber = doc.data()?['phoneNumber'] as String?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppProvider provider = Provider.of<AppProvider>(context);
    return Scaffold(
        body: Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: context.theme.primaryColor,
          ),
          height: MediaQuery.of(context).viewPadding.top + 60,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).viewPadding.top,
          ),
          alignment: Alignment.center,
          child: Row(
            children: [
              IconButton(
                onPressed: Navigator.of(context).pop,
                icon: const Icon(
                  IconsaxOutline.arrow_left_2,
                  size: 26,
                ),
                color: Colors.white,
              ),
              const SizedBox(
                width: 15,
              ),
              const Text(
                "Settings",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20),
              )
            ],
          ),
        ),
        Expanded(
            child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              onTap: () => _editNameDialog(provider),
              visualDensity: const VisualDensity(vertical: -2),
              title: const Text(
                "Name",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              subtitle: Selector<AppProvider, String?>(
                  selector: (_, provider) => provider.username,
                  builder: (context, state, _) {
                    return Text(
                      state ?? "",
                      style: context.theme.textTheme.bodySmall,
                    );
                  }),
            ),
            ListTile(
              onTap: _editPhoneDialog,
              visualDensity: const VisualDensity(vertical: -2),
              title: const Text(
                "Phone Number",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              subtitle: Text(
                phoneNumber ?? "Not set",
                style: context.theme.textTheme.bodySmall,
              ),
            ),
            ListTile(
              onTap: () async {
                ConfirmModal.showConfirmDialog(context,
                    title: "Are you sure?",
                    content:
                        const Text("After deleting data can't be recovered"),
                    onConfirm: () async {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  await provider.reset();
                  await resetDatabase();
                }, onCancel: () {
                  Navigator.of(context).pop();
                });
              },
              visualDensity: const VisualDensity(vertical: -2),
              title: const Text(
                "Reset",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              subtitle: Text(
                "Delete all the data",
                style: context.theme.textTheme.bodySmall,
              ),
            ),
            ListTile(
              onTap: () async {
                await provider.reset();
                _logout(); // Replace with your profile screen route
              },
              visualDensity: const VisualDensity(vertical: -2),
              title: const Text(
                "Logout",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              subtitle: const Text(
                "Logout your account",
              ),
            ),
          ],
        ))
      ],
    ));
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to the login or home screen after successful logout
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileWidget(),
        ),
      ); // Replace with your login screen route
    } catch (e) {
      // Handle any errors that may occur during logout
      print("Error during logout: $e");
    }
  }

  void _editNameDialog(AppProvider provider) {
    TextEditingController nameController =
        TextEditingController(text: provider.username);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Enter your name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                provider.updateUsername(nameController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _editPhoneDialog() {
    TextEditingController phoneController =
        TextEditingController(text: phoneNumber);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Phone Number'),
          content: TextField(
            controller: phoneController,
            decoration:
                const InputDecoration(hintText: 'Enter your phone number'),
            keyboardType: TextInputType.phone,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                // This line is where _updatePhoneNumber is effectively called
                await _updatePhoneNumber(phoneController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePhoneNumber(String newPhoneNumber) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null && newPhoneNumber.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'phoneNumber': newPhoneNumber});
      setState(() {
        phoneNumber = newPhoneNumber;
      });
    }
  }
}
