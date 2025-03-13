import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:global_ios/models/user_model.dart';
import 'package:global_ios/screens/edit_profile.dart';
import 'package:global_ios/screens/following_list.dart';
import 'package:global_ios/screens/login.dart';
import 'package:global_ios/screens/post_tile.dart';
import 'package:global_ios/screens/posts.dart';
import 'package:global_ios/utilities/appbar.dart';
import 'package:global_ios/utilities/progress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import 'follower_list.dart';

class Profile extends StatefulWidget {
  final String profileId;
  Profile(
    this.profileId,
    // { String ?profileId}
  );

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // final String profileId;
  // _ProfileState(this.profileId);

  bool isFollowing = false;
  final String currentUserId = currentUser!.id;
  String postOrientation = 'grid';
  bool isLoading = false;
  int postCount = 0;
  int followersCount = 0;
  int followingCount = 0;
  List<Post> posts = [];
  String postId = Uuid().v4();
  bool isProfileOwner = false;

  final usersRef = FirebaseFirestore.instance.collection('users');
  bool process = false;

  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
    checkUserIsAlreadyBlocked();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .get();
    setState(() {
      followersCount = snapshot.docs.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.profileId)
        .collection('userFollowing')
        .get();
    setState(() {
      followingCount = snapshot.docs.length;
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .doc(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();

      print(posts);
      print("posts");
    });
  }

  Widget buildCountColumn(String label, int count) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            count.toString(),
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          ),
          Container(
              margin: EdgeInsets.only(top: 4.0),
              child: Text(label,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400,
                  )))
        ]);
  }

  editProfile() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => EditProfile(widget.profileId)));
  }

  Container buildButton({text, function}) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: MediaQuery.of(context).size.width / 1.8,
          height: 27.0,
          child: Text(
            text,
            style: TextStyle(
              color: isFollowing ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFollowing ? Colors.white : Colors.blue,
            border: Border.all(color: isFollowing ? Colors.grey : Colors.blue),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  buildProfileButton() {
    // if we are veiwing our own profile we should show edit proifile button
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(text: 'Edit Profile', function: editProfile);
    } else if (isFollowing) {
      return buildButton(text: 'Unfollow', function: handleUnfollowUser);
    } else if (!isFollowing) {
      return buildButton(text: 'Follow', function: handleFollowUser);
    }
  }

  handleUnfollowUser() {
    setState(() {
      isLoading = false;
    });
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    //make auth user follower or another user(update their followers collection)
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .set({});

    // put that user on your following collection updating your following collection
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});
    // add activityfeed item for that user to notify about new follower
    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .set({
      'type': 'follow',
      'ownerId': widget.profileId,
      'username': currentUser!.username,
      'userId': currentUserId,
      'userProfileImg': currentUser!.photoUrl,
      'timestamp': timestamp,
    });
  }

  buildProfileHeader(context) {
    File _image = new File("");
    final picker = ImagePicker();
    String profileUrl = "";

    buildPickImage() async {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      setState(() {
        _image = File(pickedFile!.path);
        print(_image);
        print("_image");
      });
    }

    Future<String> uploadProfile(profile) async {
      print(profile);
      print("profile");

      var downloadUrl;

      if (profile != null) {
        //Upload to Firebase
        var snapshot = await storageRef
            .ref()
            .child('profile_$postId.aac')
            .putFile(profile);
        downloadUrl = await snapshot.ref.getDownloadURL();
        setState(() {
          print(downloadUrl);
          print("downloadUrl");
          // imageUrl = downloadUrl;
        });
      } else {
        print('No Image Path Received');
      }

      await usersRef
          .doc(widget.profileId)
          .update({"photoUrl": downloadUrl.toString()});

      return downloadUrl;
    }

    return FutureBuilder(
        // future:
        future: usersRef.doc(widget.profileId).get(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const SpinKitThreeBounce(
              color: Colors.grey,
              size: 35,
            );
            // CircularProgressIndicator();
          }

          User user = User.fromDocument(snapshot.data);
          bool isProfileOwner = currentUserId == widget.profileId;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    process
                        ? const Center(
                            child: SpinKitThreeBounce(
                            color: Colors.grey,
                            size: 35,
                          )
                            // CircularProgressIndicator(),
                            )
                        : Stack(
                            alignment: Alignment.bottomRight,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.blue, width: 2.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 5,
                                        blurRadius: 20,
                                      )
                                    ]),
                                child: CircleAvatar(
                                  radius: 40.0,
                                  backgroundColor: Colors.grey,
                                  backgroundImage:
                                      CachedNetworkImageProvider(user.photoUrl),
                                ),
                              ),
                              isProfileOwner == true
                                  ? GestureDetector(
                                      onTap: () async {
                                        await buildPickImage();
                                        setState(() {
                                          process = true;
                                        });
                                        await uploadProfile(_image);
                                        setState(() {
                                          process = false;
                                        });
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white),
                                        child: const Icon(
                                          Icons.add_circle,
                                          size: 25,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              buildCountColumn('posts', postCount),
                              GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => FollowersList(
                                                  userId: currentUserId,
                                                  profileID: widget.profileId,
                                                )));
                                  },
                                  child: buildCountColumn(
                                      'followers', followersCount)),
                              GestureDetector(
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return FollowingList(
                                        userId: currentUserId,
                                        profileID: widget.profileId,
                                      );
                                    }));
                                  },
                                  child: buildCountColumn(
                                      'following', followingCount)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              buildProfileButton(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          child: Text(user.username,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ))),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (widget.profileId != currentUserId)
                            Container(
                              child: Center(
                                child: IconButton(
                                    icon: Icon(
                                      userBlocked
                                          ? Icons.lock
                                          : Icons.lock_open_rounded,
                                      size: 28,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    onPressed: () {
                                      showAlert();
                                    }),
                              ),
                            ),
                          Container(
                            child: Center(
                              child: IconButton(
                                  icon: Icon(
                                    Icons.share,
                                    size: 28,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () {
                                    createDynamicLink(widget.profileId);
                                  }),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    user.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(user.bio),
                ),
              ],
            ),
          );
        });
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else if (isLoading) {
      return Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
            Image.asset('assets/images/no_content.png', height: 260.0),
            const Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text('No Posts Yet',
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold)))
          ]));
    } else if (postOrientation == 'grid') {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(child: PostTile(post)));
      });
      return GridView.count(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          mainAxisSpacing: 1.5,
          crossAxisSpacing: 1.5,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: gridTiles);
    } else if (postOrientation == 'list') {
      return Column(
        children: posts,
      );
    }
  }

  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: () => setPostOrientation('grid'),
          icon: Icon(Icons.view_column),
          color: postOrientation == 'grid'
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
        IconButton(
            onPressed: () => setPostOrientation('list'),
            icon: Icon(Icons.list),
            color: postOrientation == 'list'
                ? Theme.of(context).primaryColor
                : Colors.grey),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.profileId);
    // print("widget.profileId");
    return Scaffold(
      appBar: header(context, false, 'Profile', false),
      body: ListView(children: <Widget>[
        buildProfileHeader(context),
        Divider(),
        userBlocked ? Container() : buildTogglePostOrientation(),
        userBlocked ? Container() : Divider(height: 0.0),
        userBlocked ? getView() : buildProfilePosts(),
      ]),
      //   bottomNavigationBar: bottomNavigationBar(context),
    );
  }

  createDynamicLink(var profileid) async {
    print('app share is working');
    // String likesInStrin = jsonEncode({});
    // String ownerId = currentUserId;
    // String postId = widget.profileId;
    // String type = 'PROFILE';
    // String title = user.displayName;
    // String description = '';
    // String mediaUrl = '';
    // String content = '';
    String profileId = profileid;

    var parameters = DynamicLinkParameters(
      link: Uri.parse(
          'https://globshare.page.link/profiles?profileId=$profileid'),
      uriPrefix: "https://globshare.page.link",
      socialMetaTagParameters: SocialMetaTagParameters(
        title: '',
        description: '',
      ),
      androidParameters: const AndroidParameters(
          packageName: 'com.gaurav.fluttershare', minimumVersion: 2),
      iosParameters: const IOSParameters(
        appStoreId: 'com.gaurav.fluttershare',
        minimumVersion: '1',
        bundleId: 'com.gaurav.fluttershare',
      ),
    );
    // var shortLink =await  parameters.
    var shortLink =
        await FirebaseDynamicLinks.instance.buildShortLink(parameters);
    final Uri uri = shortLink.shortUrl;

    Share.share('Check out this Profile from Globe app ${uri.toString()}');
  }

  var reportRef;
  bool userBlocked = false;
  checkUserIsAlreadyBlocked() async {
    usersRef
        .doc(currentUserId)
        .collection('blocked')
        .doc(widget.profileId)
        .get()
        .then((value) {
      if (value.exists) {
        setState(() {
          userBlocked = true;
        });
      }
    });
  }

  blockUser() async {
    if (userBlocked) {
      await usersRef
          .doc(currentUserId)
          .collection('blocked')
          .doc(widget.profileId)
          .get()
          .then((value) {
        if (value.exists) value.reference.delete();
      });
      await usersRef
          .doc(widget.profileId)
          .collection('blockedBy')
          .doc(currentUserId)
          .get()
          .then((value) {
        if (value.exists) value.reference.delete();
      });
      setState(() {
        userBlocked = false;
      });
    } else {
      await usersRef
          .doc(currentUserId)
          .collection('blocked')
          .doc(widget.profileId)
          .set({'userId': widget.profileId});

      await usersRef
          .doc(widget.profileId)
          .collection('blockedBy')
          .doc(currentUserId)
          .set({'userId': currentUserId});

      setState(() {
        userBlocked = true;
      });
    }

    blockbyUser();
  }

  void blockbyUser() {}
  // ---------------------

  showAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Are You Sure ?"),
          content: userBlocked
              ? const Text("You Want To unblock this User ?")
              : const Text("You Want To block this User ?"),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("NO"),
            ),
            FlatButton(
              onPressed: () {
                blockUser();
                Navigator.of(context).pop();
                // // deletePost();
                // Navigator.pop(context);
              },
              child: const Text("Yes"),
            )
          ],
        );
      },
    );
  }

  getView() {
    return Container(
      child: Text(
        "User is Blocked Kindly UnBlock to view posts",
        textAlign: TextAlign.center,
      ),
    );
  }
}
