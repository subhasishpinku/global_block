import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_ios/models/user_model.dart';
import 'package:global_ios/screens/activity_feeds.dart';
import 'package:global_ios/screens/home.dart';
import 'package:global_ios/screens/login.dart';
import 'package:global_ios/screens/post_screen.dart';
import 'package:global_ios/screens/posts.dart';
import 'package:global_ios/screens/profile.dart';
import 'package:global_ios/screens/search.dart';
import 'package:global_ios/screens/upload.dart';
import 'package:global_ios/utilities/demo.dart';

class BottomBarScreen extends StatefulWidget {
  final String username;
  BottomBarScreen(this.username);

  @override
  _BottomBarScreenState createState() => _BottomBarScreenState(this.username);
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  final String username;
  _BottomBarScreenState(this.username);
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late Map userProfile;
  late PageController pageController;
  int cpageIndex = 0;
  int _selectedPageIndex = 0;
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  Future<void> initDynamicLink(context) async {
    dynamicLinks.onLink.listen((dynamicLinkData) {
      String path = dynamicLinkData.link.path;
      print(dynamicLinkData.link.queryParameters);
      Map data = dynamicLinkData.link.queryParameters;
      // Navigator.pushNamed(context, dynamicLinkData.link.path);
      if (path.contains('/kfxD')) {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return PostScreen(
              userId: data['ownerId'],
              postId: data['postId'],
              type: data['type'],
            );
          },
        ));
      } else if (path.contains('/profiles')) {
        Navigator.push(context, MaterialPageRoute(builder: ((context) {
          return Profile(data['profileId']);
        })));
      }
    }).onError((error) {
      print(error.message);
    });
  }
  // void handleDynamicLinks() async {
  //   final PendingDynamicLinkData? data =
  //       await FirebaseDynamicLinks.instance.getInitialLink();
  //   _handleDeepLink(data!);

  //   FirebaseDynamicLinks.instance.onLink;
  // }

  // void _handleDeepLink(PendingDynamicLinkData data) {
  //   final Uri deepLink = data.link;
  //   if (deepLink != null) {
  //     var receivedGameCode = deepLink.queryParameters['gameCode'];
  //     print('receivedGameCode: $receivedGameCode');
  //     print('_handleDeepLink | deeplink: $deepLink');
  //     // Navigator.pushNamed(context, '/joingGame');

  //   } else {
  //     print('_handleDeepLink | deeplink: NO LINK');
  //   }
  // }

  @override
  void initState() {
    super.initState();
    initDynamicLink(context);
    // handleDynamicLinks();
    pageController = PageController();
  }

  void _selectPage(int index) {
    print(index);
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // print(currentUser.id);

    getCurrentUser();

    return Scaffold(
      key: _scaffoldKey,
      body: currentUser != null
          ? PageView(
              children: <Widget>[
                Home(currentUser!),
                ActivityFeed(),
                Upload(currentUser: currentUser!),
                Search(currentUser: currentUser!),
                Profile(widget.username),
              ],
              controller: pageController,
              onPageChanged: onPageChanged,
              physics: NeverScrollableScrollPhysics(),
            )
          : Container(),
      bottomNavigationBar: CupertinoTabBar(
          currentIndex: cpageIndex,
          onTap: onTap,
          activeColor: Theme.of(context).primaryColor.withBlue(160),
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home)),
            BottomNavigationBarItem(icon: Icon(Icons.notifications)),
            BottomNavigationBarItem(icon: Icon(Icons.add_box, size: 35.0)),
            BottomNavigationBarItem(icon: Icon(Icons.search)),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
          ]),
    );
  }

  onPageChanged(int pageIndex) {
    setState(() {
      cpageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void getCurrentUser() async {
    if (currentUser == null) {
      final usersRef = FirebaseFirestore.instance.collection('users');
      DocumentSnapshot doc = await usersRef.doc(username).get();
      setState(() {
        currentUser = User.fromDocument(doc);
      });
    }

    print("CurrentUser " + currentUser.runtimeType.toString() + " ");
  }
}
