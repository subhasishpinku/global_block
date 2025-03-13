// @dart = 2.9
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:global_ios/screens/login.dart';
import 'package:global_ios/utilities/bottom_navigation.dart';
import 'package:global_ios/utilities/preferances.dart';

import 'firebase_options.dart';

// void main() async
// {
// 	WidgetsFlutterBinding.ensureInitialized();
// 	await Firebase.initializeApp();
// 	FirebaseAppCheck appCheck = FirebaseAppCheck.instance;
// 	String token = await FirebaseAppCheck.instance.getToken();
// 	print(token);
// 	runApp( MyApp());
// }
var userID = "";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await getUserID();
  // final PendingDynamicLinkData initialLink =
  //     await FirebaseDynamicLinks.instance.getInitialLink();
  runApp(MyApp());
}

Future<String> getUserID() async {
  userID = await Preferances().read("userID");
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("UserID " + userID);
    //final String userID = prefs.getString('userID');
    //String userID = Preferances().getStringValue("userID");

    return MaterialApp(
        title: 'Globe',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.blueGrey,
          accentColor: Colors.blue[900],
        ),
        home:
            // StreamBuilder(
            //     stream: auth.FirebaseAuth.instance.authStateChanges(),
            //     builder: (context, snapshot) {
            //       if (snapshot.hasData) {
            //         return BottomBarScreen(currentUser.id);
            //       }
            // return
            userID == null || userID.isEmpty ? Login() : BottomBarScreen(userID)
        //BottomBarScreen("test")
        //    ;
        // }),

        // Login()
        );
  }
}
