import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:global_ios/models/user_model.dart';
import 'package:global_ios/screens/create_account.dart';
import 'package:global_ios/utilities/bottom_navigation.dart';
import 'package:global_ios/utilities/preferances.dart';
import 'package:global_ios/widgets/app_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:url_launcher/url_launcher.dart';
final GoogleSignIn googleSignIn = GoogleSignIn();
final SignInWithApple appleSignIn = SignInWithApple();
FirebaseStorage storageRef = FirebaseStorage.instance;
final usersRef = FirebaseFirestore.instance.collection('users');
final postsRef = FirebaseFirestore.instance.collection('posts');
final commentsRef = FirebaseFirestore.instance.collection('comments');
final activityFeedRef = FirebaseFirestore.instance.collection('feed');
final followersRef = FirebaseFirestore.instance.collection('followers');
final followingRef = FirebaseFirestore.instance.collection('following');
final timelineRef = FirebaseFirestore.instance.collection('timeline');
final blockedRef = FirebaseFirestore.instance.collection('blocked');
final licenceRef = FirebaseFirestore.instance.collection('licence');
final DateTime timestamp = DateTime.now();
User? currentUser;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final prefs = SharedPreferences.getInstance();

  bool isGoogleReady = false;
  bool isAuth = false;
  int pageIndex = 0;
  bool checked = false;

  var userId;
  var email;
  var username;

  final DateTime timestamp = DateTime.now();

  final usersRef = FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    googleSignIn.isSignedIn().then((isSignedIn) async {
      if (isSignedIn) {
        googleSignIn.onCurrentUserChanged.listen((account) {
          handleSignIn(account);
        }, onError: (err) {
          isGoogleReady = true;
          setState(() {
            isGoogleReady = true;
          });
        });
        // Reauthenticate user when app is opened
        googleSignIn
            .signInSilently(suppressErrors: false)
            .then((account) async {
          await handleSignIn(account);
          setState(() {
            isGoogleReady = true;
          });
        }).catchError((err) {
          setState(() {
            isGoogleReady = true;
          });
          print('Error signing in: $err');
        });
      }
    });
  }
  handleSignIn(account) async {
    print(account);
    if (account != null) {
      await createUserInFirebaseFirestore();
      setState(() {
        isAuth = true;
      });
      // configurePushNotifications();s
    } else {
      setState(() {
        isAuth = false;
      });
    }

    // print('MUR HOME INIT END');
  }

// ----------------apple hadle----------------------
  handleSignIn2(account) async {
    print(account);
    if (account != null) {
      await createUserInFirebaseFirestoreApple();
      setState(() {
        isAuth = true;
      });
      // configurePushNotifications();s
    } else {
      setState(() {
        isAuth = false;
      });
    }

    // print('MUR HOME INIT END');
  }

  createUserInFirebaseFirestore() async {
    final GoogleSignInAccount? user = googleSignIn.currentUser;
    appService.CurrentUSer = user!.id;
    DocumentSnapshot doc = await usersRef.doc(user.id).get();
    if (checked) {
      await licenceRef.doc(user.email).set(
          {'email': user.email, 'username': user.displayName, 'id': user.id});
    }
    if (!doc.exists) {
      var data = await usersRef.doc(user.id).set({
        "id": user.id,
        "username": "",
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timestamp,
        "blocked": false
      });
      DocumentSnapshot d = await usersRef.doc(user.id).get();
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CreateAccount(User.fromDocument(d))));

      doc = await usersRef.doc(user.id).get();
    }
    if (doc.get('username') == null || doc.get('username').trim() == "") {
      print("ITS THE OTHER");
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CreateAccount(User.fromDocument(doc))));
      doc = await usersRef.doc(user.id).get();
    }
    currentUser = User.fromDocument(doc);
    // Preferances().setStringValue("userID", currentUser!.id);
    Preferances().save("userID", currentUser!.id);
    //Navigator.
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => BottomBarScreen(currentUser!.id)));
  }
  createUserInFirebaseFirestoreApple() async {
    DocumentSnapshot doc = await usersRef.doc(userId).get();
    if (!doc.exists) {
      var data = await usersRef.doc(userId).set({
        "id": userId,
        "username": "",
        "photoUrl": "",
        "email": email,
        "displayName": username,
        "bio": "",
        "timestamp": timestamp
      });
      DocumentSnapshot d = await usersRef.doc(userId).get();
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateAccount(
            User.fromDocument(d),
          ),
        ),
      );
      doc = await usersRef.doc(userId).get();
    }
    if (doc.get('username') == null || doc.get('username').trim() == "") {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CreateAccount(
            User.fromDocument(doc),
          ),
        ),
      );
      doc = await usersRef.doc(userId).get();
    }
    currentUser = User.fromDocument(doc);
    //Preferances().setStringValue("userID", currentUser!.id);
    Preferances().save("userID", currentUser!.id);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => BottomBarScreen(currentUser!.id)));
  }

  logout() {
    googleSignIn.signOut();
  }

  // ------------- terms and conditions -----------------------
  void _termsUrl() async {
    try {
      await launch(
          'https://www.termsfeed.com/live/59729d43-c626-4957-90d5-19042c472b78');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Oops! somethings went wrong')));
    }
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Globe',
              style: TextStyle(
                fontFamily: "Signatra",
                fontSize: 90.0,
                color: Colors.white,
              ),
            ),

            // --------- googleLogin ----------------------------
            //if (!Platform.isAndroid)
            //  if (Platform.isAndroid)
            
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/google_signin_button.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            // --------------applelogin---------------------------
            if (Platform.isIOS)
              GestureDetector(
                onTap: () {
                  appleLogin();
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => BottomBarScreen()));
                  // await fblogin();
                },
                child: Container(
                  padding: const EdgeInsets.only(
                      right: 10, left: 2, top: 2, bottom: 2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  width: 250.0,
                  height: 60.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(5),
                        width: 51,
                        height: 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.black),
                        child: Image.asset(
                          "assets/images/apple_logo.png",
                          height: 30,
                          width: 30,
                        ),
                      ),
                      const Text(
                        "Sign in with Apple",
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            SizedBox(
              height: 20,
            ),
            // Divider(
            //   color: Colors.white,
            // ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                    activeColor: Colors.white,
                    checkColor: Colors.blue,
                    shape: const CircleBorder(),
                    value: checked,
                    onChanged: (value) async {
                      setState(() {
                        checked = value!;
                      });
                    }),
                Row(
                  children: [
                    const Text(
                      'I Agree to the ',
                      style: TextStyle(color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: _termsUrl,
                      child: const Text(
                        'End User License Agreement',
                        style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return buildUnAuthScreen();
    //

    // StreamBuilder(
    //     stream: auth.FirebaseAuth.instance.authStateChanges(),
    //     builder: (context, snapshot) {
    //       if (snapshot.hasData) {
    //         return BottomBarScreen(currentUser!.id);
    //       }
    //       return buildUnAuthScreen();
    //     });

    // isGoogleReady
    //     ? isAuth
    //         ? BottomBarScreen(
    //             currentUser!.id,
    //           )
    //         : buildUnAuthScreen()
    //     : Container(
    //         child: const SpinKitThreeBounce(
    //           color: Colors.grey,
    //           size: 35,
    //         ),
    //         //  CircularProgressIndicator(),
    //         alignment: Alignment.center,
    //         color: Colors.white,
    //       );
  }

  login() async {
    try {
      if (!checked) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please agree to the terms & conditions')));
        return;
      }
      var response = await googleSignIn.signIn();
      handleSignIn(response);
    } catch (e) {
      print(e);
    }
  }

  appleLogin() async {
    if (!checked) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please agree to the terms & conditions')));
      return;
    }
    final credentials = await SignInWithApple.getAppleIDCredential(scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName
    ]);
    print('------------------------');
    print(credentials);
    print('------------------------');

    setState(() {
      userId = credentials.userIdentifier;
      email = credentials.email ?? '';
      username = credentials.givenName ?? '';
    });
    handleSignIn2(credentials);
  }
}
