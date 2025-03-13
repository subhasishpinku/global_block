import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:global_ios/screens/login.dart';
import 'package:global_ios/screens/profile.dart';
import '../models/user_model.dart';

class FollowingList extends StatefulWidget {
  var userId;
  var profileID;

  FollowingList({this.userId, this.profileID});
  @override
  _FollowingListState createState() => _FollowingListState();
}

class _FollowingListState extends State<FollowingList> {
  List follower = [];
  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.profileID)
        .collection('userFollowing')
        .get();
    getUser();
    snapshot.docs.forEach((element) {
      follower.insert(0, element.id);
    });
  }

  List<User> user = [];
  bool isLoading = true;

  getUser() async {
    QuerySnapshot snapshot = await usersRef.get();
    for (var i in snapshot.docs) {
      for (var j in follower) {
        if (i.id == j) {
          var userObj = User(
            displayName: i.get('displayName'),
            photoUrl: i.get('photoUrl'),
            username: i.get('username'),
            id: i.get('id'),
          );
          setState(() {
            user.insert(0, userObj);
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFollowing();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Following'),
        ),
        body: isLoading
            ? const SpinKitThreeBounce(
                color: Colors.grey,
                size: 35,
              )
            // CircularProgressIndicator()
            : ListView.builder(
                itemCount: user.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      gotoUserProfile(index);
                    },
                    child: ListTile(
                      title: Text(user[index].username),
                      subtitle: Text(user[index].displayName),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          "${user[index].photoUrl}",
                        ),
                      ),
                    ),
                  );
                }));
  }

  gotoUserProfile(int index) {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return Profile(user[index].id);
    }));
  }
}
