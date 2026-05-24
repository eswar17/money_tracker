// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:dio/dio.dart';

// import 'package:flutter/material.dart';

// import 'package:install_plugin_v2/install_plugin_v2.dart';

// import 'package:package_info_plus/package_info_plus.dart';

// import 'package:path_provider/path_provider.dart';

// class AppUpdateService {
//   static Future<void> checkForUpdate(BuildContext context) async {
//     try {
//       // =====================
//       // CURRENT VERSION
//       // =====================

//       final packageInfo = await PackageInfo.fromPlatform();

//       final currentVersion = int.parse(packageInfo.buildNumber);

//       // =====================
//       // FIREBASE VERSION
//       // =====================

//       final document = await FirebaseFirestore.instance
//           .collection('app_config')
//           .doc('android')
//           .get();

//       final data = document.data();

//       if (data == null) {
//         return;
//       }

//       final latestVersion = data['latestVersion'];

//       final apkUrl = data['apkUrl'];

//       // =====================
//       // UPDATE AVAILABLE
//       // =====================

//       if (latestVersion > currentVersion) {
//         if (!context.mounted) {
//           return;
//         }

//         showDialog(
//           context: context,

//           builder: (context) {
//             return AlertDialog(
//               title: const Text('Update Available'),

//               content: const Text('A new version of the app is available.'),

//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },

//                   child: const Text('Later'),
//                 ),

//                 ElevatedButton(
//                   onPressed: () async {
//                     Navigator.pop(context);

//                     await downloadAndInstall(apkUrl);
//                   },

//                   child: const Text('Update'),
//                 ),
//               ],
//             );
//           },
//         );
//       }
//     } catch (e) {
//       debugPrint('UPDATE ERROR: $e');
//     }
//   }

//   // =========================
//   // DOWNLOAD APK
//   // =========================

//   static Future<void> downloadAndInstall(String apkUrl) async {
//     try {
//       final directory = await getExternalStorageDirectory();

//       if (directory == null) {
//         return;
//       }

//       final filePath = '${directory.path}/update.apk';

//       // DOWNLOAD APK
//       await Dio().download(apkUrl, filePath);

//       // INSTALL APK
//       await InstallPlugin.installApk(filePath);
//     } catch (e) {
//       debugPrint('INSTALL ERROR: $e');
//     }
//   }
// }
