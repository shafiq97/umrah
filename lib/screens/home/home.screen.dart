import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:events_emitter/events_emitter.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:fintracker/events.dart';
import 'package:fintracker/providers/app_provider.dart';
import 'package:fintracker/screens/onboard/widgets/profile.dart';
import 'package:fintracker/screens/settings/settings.screen.dart';
import 'package:fintracker/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:pdftron_flutter/pdftron_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

String greeting() {
  var hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Morning';
  }
  if (hour < 17) {
    return 'Afternoon';
  }
  return 'Evening';
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  EventListener? _accountEventListener;
  EventListener? _categoryEventListener;
  EventListener? _paymentEventListener;

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw 'Could not launch $url';
    }
  }

  void _openPdfViewer() async {
    String documentPath =
        "https://firebasestorage.googleapis.com/v0/b/fypdatabase-c8728.appspot.com/o/guides.pdf?alt=media&token=533ae84e-cffb-4689-8442-a0ec0dcd9b9a"; // Replace with your file path or URL

    if (Platform.isAndroid) {
      // Request storage permission for Android
      var status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        return; // Exit if permission not granted
      }
    }

    try {
      PdftronFlutter.openDocument(documentPath);
    } catch (e) {
      print("Error opening document: $e");
    }
  }

  void _openPdfViewerTahalul() async {
    String documentPath =
        "https://firebasestorage.googleapis.com/v0/b/fypdatabase-c8728.appspot.com/o/TAHALUL.pdf?alt=media&token=37c40340-54af-4d4a-936c-11730b3d8a7c"; // Replace with your file path or URL

    if (Platform.isAndroid) {
      // Request storage permission for Android
      var status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        return; // Exit if permission not granted
      }
    }

    try {
      PdftronFlutter.openDocument(documentPath);
    } catch (e) {
      print("Error opening document: $e");
    }
  }

  //double _savings = 0;
  DateTimeRange _range = DateTimeRange(
      start: DateTime.now().subtract(Duration(days: DateTime.now().day - 1)),
      end: DateTime.now());

  void handleChooseDateRange() async {
    final selected = await showDateRangePicker(
      context: context,
      initialDateRange: _range,
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    );
    if (selected != null) {
      setState(() {
        _range = selected;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _accountEventListener = globalEvent.on("account_update", (data) {
      debugPrint("accounts are changed");
    });

    _categoryEventListener = globalEvent.on("category_update", (data) {
      debugPrint("categories are changed");
    });

    _paymentEventListener = globalEvent.on("payment_update", (data) {
      debugPrint("payments are changed");
    });
  }

  @override
  void dispose() {
    _accountEventListener?.cancel();
    _categoryEventListener?.cancel();
    _paymentEventListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
              "assets/images/background.jpeg"), // Replace with your image path
          fit: BoxFit.cover, // This will cover the entire container
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Container(
              margin: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Hi! Good ${greeting()}"),
                      Selector<AppProvider, String?>(
                          selector: (_, provider) => provider.username,
                          builder: (context, state, _) => Text(
                                state ?? "Guest",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ))
                    ],
                  )),
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => SettingsScreen()));
                      },
                      icon: const Icon(IconsaxOutline.user_octagon))
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: const Row(children: [
                Text("Your counters",
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                Expanded(child: SizedBox()),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: ThemeColors.success.withOpacity(0.2),
                      ),
                      child: Consumer<AppProvider>(
                        builder: (context, counterProvider, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          "Tawaf Counter: ${counterProvider.tawafCount} ",
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: ThemeColors.error.withOpacity(0.2),
                      ),
                      child: Consumer<AppProvider>(
                        builder: (context, counterProvider, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          "Sa'i Counter: ${counterProvider.saiCount} ",
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _openPdfViewer,
                    child: const Text('View Prohibitions Guide'),
                  ),
                  ElevatedButton(
                    onPressed: _openPdfViewerTahalul,
                    child: const Text('View Tahalul Guide'),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('duas')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      return ListView(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(), // to disable scrolling within the ListView
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;
                          return ListTile(
                            title: Text(data['title']),
                            subtitle: Text(data['text']),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  // AnyLinkPreview(
                  //   link:
                  //       "https://shafiqolbu.wordpress.com/2013/10/06/zikir-dan-doa-ketika-tawaf/",
                  //   displayDirection: UIDirection.uiDirectionHorizontal,
                  //   showMultimedia: true,
                  //   bodyMaxLines: 5,
                  //   bodyTextOverflow: TextOverflow.ellipsis,
                  //   titleStyle: const TextStyle(
                  //     color: Colors.black,
                  //     fontWeight: FontWeight.bold,
                  //     fontSize: 15,
                  //   ),
                  //   bodyStyle:
                  //       const TextStyle(color: Colors.grey, fontSize: 12),
                  //   errorBody: 'Show my custom error body',
                  //   errorTitle: 'Show my custom error title',
                  //   errorWidget: Container(
                  //     color: Colors.grey[300],
                  //     child: const Text('Oops!'),
                  //   ),
                  //   errorImage: "https://google.com/",
                  //   cache: const Duration(days: 7),
                  //   backgroundColor: Colors.grey[300],
                  //   borderRadius: 12,
                  //   removeElevation: false,
                  //   boxShadow: const [
                  //     BoxShadow(blurRadius: 3, color: Colors.grey)
                  //   ],
                  //   onTap: () => _launchUrl(
                  //       "https://shafiqolbu.wordpress.com/2013/10/06/zikir-dan-doa-ketika-tawaf/"),
                  // ),
                  // const SizedBox(
                  //   height: 20,
                  // ),
                  // AnyLinkPreview(
                  //   link:
                  //       "https://akuislam.com/panduan/niat-cara-tawaf-umrah-haji/",
                  //   displayDirection: UIDirection.uiDirectionHorizontal,
                  //   showMultimedia: true,
                  //   bodyMaxLines: 5,
                  //   bodyTextOverflow: TextOverflow.ellipsis,
                  //   titleStyle: const TextStyle(
                  //     color: Colors.black,
                  //     fontWeight: FontWeight.bold,
                  //     fontSize: 15,
                  //   ),
                  //   bodyStyle:
                  //       const TextStyle(color: Colors.grey, fontSize: 12),
                  //   errorBody: 'Show my custom error body',
                  //   errorTitle: 'Show my custom error title',
                  //   errorWidget: Container(
                  //     color: Colors.grey[300],
                  //     child: const Text('Oops!'),
                  //   ),
                  //   errorImage: "https://google.com/",
                  //   cache: const Duration(days: 7),
                  //   backgroundColor: Colors.grey[300],
                  //   borderRadius: 12,
                  //   removeElevation: false,
                  //   boxShadow: const [
                  //     BoxShadow(blurRadius: 3, color: Colors.grey)
                  //   ],
                  //   onTap: () => _launchUrl(
                  //       "https://akuislam.com/panduan/niat-cara-tawaf-umrah-haji/"),
                  // ),
                  // const SizedBox(
                  //   height: 20,
                  // ),
                  // AnyLinkPreview(
                  //   link:
                  //       "https://www.detik.com/hikmah/haji-dan-umrah/d-6528606/zikir-dan-doa-sai-haji-dibaca-saat-berada-di-bukit-shafa-marwah",
                  //   displayDirection: UIDirection.uiDirectionHorizontal,
                  //   showMultimedia: true,
                  //   bodyMaxLines: 5,
                  //   bodyTextOverflow: TextOverflow.ellipsis,
                  //   titleStyle: const TextStyle(
                  //     color: Colors.black,
                  //     fontWeight: FontWeight.bold,
                  //     fontSize: 15,
                  //   ),
                  //   bodyStyle:
                  //       const TextStyle(color: Colors.grey, fontSize: 12),
                  //   errorBody: 'Show my custom error body',
                  //   errorTitle: 'Show my custom error title',
                  //   errorWidget: Container(
                  //     color: Colors.grey[300],
                  //     child: const Text('Oops!'),
                  //   ),
                  //   errorImage: "https://google.com/",
                  //   cache: const Duration(days: 7),
                  //   backgroundColor: Colors.grey[300],
                  //   borderRadius: 12,
                  //   removeElevation: false,
                  //   boxShadow: const [
                  //     BoxShadow(blurRadius: 3, color: Colors.grey)
                  //   ],
                  //   onTap: () => _launchUrl(
                  //       "https://www.detik.com/hikmah/haji-dan-umrah/d-6528606/zikir-dan-doa-sai-haji-dibaca-saat-berada-di-bukit-shafa-marwah"),
                  // ),
                  // const SizedBox(
                  //   height: 20,
                  // ),
                  // AnyLinkPreview(
                  //   link: "https://www.youtube.com/watch?v=_ek1ABD47xA",
                  //   displayDirection: UIDirection.uiDirectionHorizontal,
                  //   showMultimedia: true,
                  //   bodyMaxLines: 5,
                  //   bodyTextOverflow: TextOverflow.ellipsis,
                  //   titleStyle: const TextStyle(
                  //     color: Colors.black,
                  //     fontWeight: FontWeight.bold,
                  //     fontSize: 15,
                  //   ),
                  //   bodyStyle:
                  //       const TextStyle(color: Colors.grey, fontSize: 12),
                  //   errorBody: 'Show my custom error body',
                  //   errorTitle: 'Show my custom error title',
                  //   errorWidget: Container(
                  //     color: Colors.grey[300],
                  //     child: const Text('Oops!'),
                  //   ),
                  //   errorImage: "https://google.com/",
                  //   cache: const Duration(days: 7),
                  //   backgroundColor: Colors.grey[300],
                  //   borderRadius: 12,
                  //   removeElevation: false,
                  //   boxShadow: const [
                  //     BoxShadow(blurRadius: 3, color: Colors.grey)
                  //   ],
                  //   onTap: () => _launchUrl(
                  //       "https://www.youtube.com/watch?v=_ek1ABD47xA"),
                  // ),
                  // const SizedBox(
                  //   height: 20,
                  // ),
                  // AnyLinkPreview(
                  //   link:
                  //       "https://muftiwp.gov.my/en/artikel/bayan-li-al-haj/2747-bayan-li-al-haj-series-37-what-is-permissible-after-tawaf-wada",
                  //   displayDirection: UIDirection.uiDirectionHorizontal,
                  //   showMultimedia: true,
                  //   bodyMaxLines: 5,
                  //   bodyTextOverflow: TextOverflow.ellipsis,
                  //   titleStyle: const TextStyle(
                  //     color: Colors.black,
                  //     fontWeight: FontWeight.bold,
                  //     fontSize: 15,
                  //   ),
                  //   bodyStyle:
                  //       const TextStyle(color: Colors.grey, fontSize: 12),
                  //   errorBody: 'Show my custom error body',
                  //   errorTitle: 'Show my custom error title',
                  //   errorWidget: Container(
                  //     color: Colors.grey[300],
                  //     child: const Text('Oops!'),
                  //   ),
                  //   errorImage: "https://google.com/",
                  //   cache: const Duration(days: 7),
                  //   backgroundColor: Colors.grey[300],
                  //   borderRadius: 12,
                  //   removeElevation: false,
                  //   boxShadow: const [
                  //     BoxShadow(blurRadius: 3, color: Colors.grey)
                  //   ],
                  //   onTap: () => _launchUrl(
                  //       "https://muftiwp.gov.my/en/artikel/bayan-li-al-haj/2747-bayan-li-al-haj-series-37-what-is-permissible-after-tawaf-wada"),
                  // ),
                ],
              ),
            ),
          ],
        )),
      ),
    ));
  }
}
