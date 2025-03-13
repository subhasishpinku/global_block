import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:global_ios/models/user_model.dart';
import 'package:global_ios/screens/login.dart';
import 'package:global_ios/screens/posts.dart';
import 'package:global_ios/screens/search.dart';
import 'package:global_ios/utilities/appbar.dart';
import 'package:global_ios/utilities/progress.dart';

class Home extends StatefulWidget {
  User currentUser;

  Home(this.currentUser);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //  List<Post> posts;
  List<String> followingList = [];
  List<DocumentSnapshot> rowPosts = [];
  @override
  void initState() {
    // print(currentUser);
    // print("currentUser");
    super.initState();
    // retrieveDynamicLink(context);
    getTimeline();
    getFollowing();
  }

  getTimeline() async {
    try {
      FirebaseFirestore db =
          FirebaseFirestore.instance.collection("posts").firestore;
      rowPosts = (await db
              .collectionGroup("userPosts")
              .orderBy('timestamp', descending: true)
              .get())
          .docs;

      setState(() {});
    } catch (e) {
      print('MUR TIMELINE FB ERROR: ${e.toString()}');
    }

    setState(() {});
  }

  getFollowing() async {
    print("currentUser.id");
    // print(currentUser.id);
    print("currentUser.id");
    QuerySnapshot snapshot = await followingRef
        .doc(currentUser!.id)
        .collection('userFollowing')
        .get();
    setState(() {
      followingList = snapshot.docs.map((doc) => doc.id).toList();
    });
  }
  buildTimeline() {
    if (rowPosts == null || rowPosts.isEmpty) {
      return const SpinKitThreeBounce(
        color: Colors.grey,
        size: 25,
      );
      // }
      //  else if (rowPosts.isEmpty) {
      //   return buildUsersToFollow();
    } else {
      return ListView.builder(
          itemCount: rowPosts.length,
          itemBuilder: (BuildContext context, int i) {
            return Container(
              child: Post.fromDocument(rowPosts[i]),

            );
          });
    }
  }
  buildUsersToFollow() {
    return StreamBuilder(
        stream: usersRef
            .orderBy('timestamp', descending: true)
            .limit(30)
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<UserResult> userResults = [];
          print("printing : " + snapshot.data.docs.toString());
          snapshot.data.docs.forEach((doc) {
            User user = User.fromDocument(doc);
            final bool isAuthUser = currentUser!.id == user.id;
            final bool isFollowingUser = followingList.contains(user.id);
            // remove auth user from recommended list
            if (isAuthUser) {
              return;
            } else if (isFollowingUser) {
              return;
            } else {
              UserResult userResult = UserResult(user);
              userResults.add(userResult);
            }
          });
          return SingleChildScrollView(
              child: Container(
                  color: Colors.white,
                  // Theme.of(context).accentColor.withOpacity(0.2),
                  child: Column(children: <Widget>[
                    Container(
                        padding: EdgeInsets.all(12.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.person_add,
                                color: Theme.of(context).primaryColor,
                                size: 30.0,
                              ),
                              SizedBox(width: 8.0),
                              Text("Users to Follow",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 30.0,
                                  ))
                            ])),
                    Column(children: userResults),
                  ])));
        });
  }
  @override
  Widget build(context) {
    return Scaffold(
        appBar: header(context, true, "", true),
        body: RefreshIndicator(
            onRefresh: () => getTimeline(),
            child: Container(
              child: buildTimeline(),
              height: MediaQuery.of(context).size.height,
            )));
  }
  String ownerId = "",
      postId = "",
      type = "",
      title = "",
      description = "",
      content = "",
      mediaUrl = "";
}
