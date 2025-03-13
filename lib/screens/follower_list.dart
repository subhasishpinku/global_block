import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:global_ios/models/user_model.dart';
import 'package:global_ios/screens/activity_feeds.dart';
import 'package:global_ios/screens/home.dart';

import 'activity_feeds.dart';
import 'login.dart';

class FollowersList extends StatefulWidget {
  var userId;
  var profileID;
  FollowersList({this.userId, this.profileID});
  @override
  _FollowersListState createState() => _FollowersListState();
}

class _FollowersListState extends State<FollowersList> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFollowers();
  }

  List follower = [];
  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .doc(widget.profileID)
        .collection('userFollowers')
        .get();
    getUser();

    return snapshot.docs.forEach((element) {
      follower.insert(0, element.id);
      print(follower);
    });
  }

  List<User> user = [];
  bool isLoading = true;

  getUser() async {
    QuerySnapshot snapshot = await usersRef.get();

    for (var i in snapshot.docs) {
      for (var j in follower) {
        if (i.id == j) {
          var userObj = User.fromDocument(i);
          setState(() {
            user.insert(0, userObj);
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Followers"),
      ),
      body: isLoading
          ? const Center(
              child: SpinKitThreeBounce(
              color: Colors.grey,
              size: 35,
            )
              // CircularProgressIndicator()
              )
          : ListView.builder(
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(user[index].username),
                  subtitle: Text(user[index].displayName),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage("${user[index].photoUrl}"),
                  ),
                  onTap: () {
                    showProfile(context, profileId: user[index].userId);
                  },
                );
              },
              itemCount: user.length,
            ),
    );
  }
}
