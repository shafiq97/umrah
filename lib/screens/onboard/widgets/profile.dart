import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:fintracker/helpers/color.helper.dart';
import 'package:fintracker/helpers/db.helper.dart';
import 'package:fintracker/providers/app_provider.dart';
import 'package:fintracker/widgets/buttons/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<StatefulWidget> createState() => _ProfileWidget();
}

class _ProfileWidget extends State<ProfileWidget> {
  String _username = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppProvider provider = Provider.of<AppProvider>(context);
    TextEditingController _emailController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();
    return Scaffold(
      body: SafeArea(
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: ListView(
                children: [
                  Text(
                    "Hi! \nWelcome to  YourUmrahMutawwif",
                    style: theme.textTheme.headlineMedium!.apply(
                        color: theme.colorScheme.primary, fontWeightDelta: 2),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Please enter all details to continue.",
                    style: theme.textTheme.bodyLarge!.apply(
                        color: ColorHelper.darken(
                            theme.textTheme.bodyLarge!.color!),
                        fontWeightDelta: 1),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    onChanged: (String username) => setState(() {
                      _username = username;
                    }),
                    decoration: InputDecoration(
                        filled: true,
                        border: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        prefixIcon: const Icon(IconsaxOutline.profile_circle),
                        hintText: "Enter your name",
                        label: const Text("What should we call you?")),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              )),
              AppButton(
                borderRadius: BorderRadius.circular(100),
                label: "Continue",
                color: theme.colorScheme.primary,
                isFullWidth: true,
                size: AppButtonSize.large,
                onPressed: () async {
                  String email = _emailController.text.trim();
                  String password = _passwordController.text.trim();
                  if (email.isEmpty || password.isEmpty) {
                    // Show error message
                  } else {
                    // Use Firebase Auth to create a new user
                    try {
                      final existingMethods = await FirebaseAuth.instance
                          .fetchSignInMethodsForEmail(email);

                      if (existingMethods.isEmpty) {
                        // Email doesn't exist, create a new user
                        UserCredential userCredential = await FirebaseAuth
                            .instance
                            .createUserWithEmailAndPassword(
                          email: email,
                          password: password,
                        );

                        User? user = userCredential.user;
                        if (user != null) {
                          // Create a map of user data to store in Firestore
                          Map<String, dynamic> userData = {
                            'username': _username,
                            'email': user.email,
                            // Add any other user-related data here
                          };

                          // Store user data in Firestore
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .set(userData);
                        }
                      } else {
                        // Email already exists, sign in instead
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                        // await provider.reset();
                        provider.update(username: _username).then((value) {});
                      }
                    } on FirebaseAuthException catch (e) {
                      log(e.toString());
                    }
                  }

                  if (_username.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Please fill all the details")));
                  }
                  // else {
                  //   await resetDatabase();
                  //   await provider.reset();
                  //   provider.update(username: _username).then((value) {});
                  // }
                },
              ),

              const SizedBox(height: 20), // Add some spacing

              AppButton(
                borderRadius: BorderRadius.circular(100),
                label: "Register",
                color: theme.colorScheme.secondary,
                isFullWidth: true,
                size: AppButtonSize.large,
                onPressed: () async {
                  String email = _emailController.text.trim();
                  String password = _passwordController.text.trim();
                  if (email.isEmpty || password.isEmpty || _username.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please fill all the fields")),
                    );
                  } else {
                    try {
                      // Use Firebase Auth to register a new user
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );

                      User? user = userCredential.user;
                      if (user != null) {
                        // Create a map of user data to store in Firestore
                        Map<String, dynamic> userData = {
                          'username': _username,
                          'email': user.email,
                          // Add any other user-related data here
                        };

                        // Store user data in Firestore
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .set(userData);

                        // Show success message or navigate to another screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Registration successful!")),
                        );

                        // Optional: Navigate to another screen or reset the form
                      }
                    } on FirebaseAuthException catch (e) {
                      // Handle registration errors
                      log(e.toString());
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("Failed to register: ${e.message}")),
                      );
                    }
                  }
                },
              ),
            ])),
      ),
    );
  }
}
