import 'dart:async';
import 'dart:convert';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:global_ios/models/user_model.dart';
import 'package:global_ios/screens/activity_feeds.dart';
import 'package:global_ios/screens/comments.dart';
import 'package:global_ios/screens/edit_blog.dart';
import 'package:global_ios/screens/login.dart';
import 'package:global_ios/screens/podcastview.dart';
import 'package:global_ios/screens/video_screen.dart';
import 'package:global_ios/utilities/bottom_navigation.dart';
import 'package:global_ios/utilities/custom_image.dart';
import 'package:global_ios/utilities/progress.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class Post extends StatefulWidget {
  String postId;
  String ownerId;
  String username;
  String location;
  String description;
  String mediaUrl;
  String title;
  String content;
  String type;
  dynamic likes;

  Post({
    this.postId = "",
    this.ownerId = "",
    this.username = "",
    this.location = "",
    this.description = "",
    this.mediaUrl = "",
    this.likes,
    this.title = "",
    this.content = "",
    this.type = "",
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    var description = '';
    // Map map = doc.data();
    Map? map = doc.data() as Map?;
    print('homemap : $map');

    print(map);
    try {
      (doc.get('description') != null)
          ? description = doc['description']
          : description = '';

      String title = '', content = '';
      if (map!.containsKey('content')) {
        content = map['content'];
      }

      if (map.containsKey('title')) {
        title = map['title'];
      }

      Post post = Post(
        postId: doc.get('postId') ?? "",
        ownerId: doc.get('ownerId') ?? "",
        username: doc.get('username') ?? "",
        location: '',
        title: title,
        description: description,
        mediaUrl: doc.get('mediaUrl'),
        likes: doc.get('likes'),
        content: content,
        type: doc.get('type') ?? "",
      );
      return post;
    } catch (e) {
      //   return null;
      throw (e) {
        print(e);
      };
    }
  }

  int getLikeCount(likes) {
    // if no likes, return 0
    if (likes == null) {
      return 0;
    }

    int count = 0;
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        username: this.username,
        location: this.location,
        description: this.description,
        mediaUrl: this.mediaUrl,
        likes: this.likes,
        likeCount: getLikeCount(this.likes),
        title: this.title,
        content: this.content,
        type: this.type,
      );
}

class _PostState extends State<Post> {
  String? currentUserId = currentUser!.id;

  // String currentUserId = "";
  String postId;
  String ownerId;
  String username;
  String location;
  String description;
  String mediaUrl;
  String title;
  String content;
  String type;
  int likeCount;
  Map likes;
  bool isLiked;
  bool showHeart = false;
  bool isUserBlocked = false;
  List<String> blockedUser = [];

  _PostState(
      {this.postId = "",
      this.ownerId = "",
      this.username = "",
      this.location = "",
      this.description = "",
      this.mediaUrl = "",
      required this.likes,
      this.likeCount = 0,
      this.title = "",
      this.content = "",
      this.type = "",
      this.isLiked = false});

  createDynamicLink(
      displayName, postid, ownerid, typ, descri, mediaurl, conTent) async {
    print('app share is working');
    String likesInStrin = jsonEncode({});
    String ownerId = ownerid;
    String postId = postid;
    String type = typ;
    String title = displayName;
    String description = descri;
    String mediaUrl = mediaurl;
    String content = conTent;

    var parameters = DynamicLinkParameters(
      link: Uri.parse(
          'https://globshare.page.link/kfxD?ownerId=$ownerId&postId=$postId&type=$type&title=$title&description=$description&mediaUrl=$mediaUrl&content=$content&likes=$likesInStrin'),
      uriPrefix: "https://globshare.page.link",
      socialMetaTagParameters: SocialMetaTagParameters(
        title: title,
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

    Share.share('Check out this Post from Globe app ${uri.toString()}');
  }

  buildPostHeader() {
    return FutureBuilder(
      future: usersRef.doc(ownerId).get(),
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        bool isPostOwner = currentUserId == ownerId;
        bool isAppOwner = currentUserId == appOwnerId;
        bool isSecondAdmin = currentUserId == secondAdminId;

        bool isBlocked = false;
        for (var blocked in blockedUser) {
          if (blocked == user.id) {
            isBlocked = true;
          }
        }
        return isBlocked
            ? Container()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                CachedNetworkImageProvider(user.photoUrl),
                            backgroundColor: Colors.grey,
                          ),
                          title: GestureDetector(
                            onTap: () =>
                                showProfile(context, profileId: user.id),
                            child: Text(
                              "${user.username}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          subtitle: location != null
                              ? Text("${location}")
                              : const Text(""),
                          trailing:
                              // ----------------------
                              isPostOwner || isAppOwner || isSecondAdmin
                                  ? IconButton(
                                      onPressed: () =>
                                          handleDeletePost(context),
                                      icon: Icon(Icons.more_vert),
                                    )
                                  : Text(''),
                        ),
                      ),
                    ],
                  ),
                  type == "POST" ? buildPostImage() : Container(),
                  type == "BLOG" ? buildBlogView() : Container(),
                  type == "PODCAST"
                      ? GestureDetector(
                          onDoubleTap: handleLikePost,
                          child: PodcastView(
                            mediaUrl: this.mediaUrl,
                            title: this.title,
                            content: this.content,
                            description: this.description,
                          ),
                        )
                      : Container(),
                  type == 'VIDEO'
                      ? GestureDetector(
                          onDoubleTap: handleLikePost,
                          child: VideoScreenTimeline(
                            type: type,
                            ownerId: ownerId,
                            postId: postId,
                            content: content,
                            likes: likes,
                            title: title,
                            mediaUrl: mediaUrl,
                            description: description,
                          ))
                      : Container(),
                  buildPostFooter(),
                  Divider(),
                ],
              );
      },
    );
  }

  bool editFlag = false;

  fnEditBlog() async {
    Navigator.pop(context);
    var data = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => EditBlog(
              content: content,
              currentUser: currentUser,
              title: title,
              ownerid: ownerId,
              postId: postId,
            )));
    print(data);
    if (data != null) {
      setState(() {
        this.content = data["content"];
        this.title = data["title"];
      });
    }
  }

  handleDeletePost(BuildContext parentCotnext) {
    return showDialog(
        context: parentCotnext,
        builder: (context) {
          return SimpleDialog(
            title: Text('Remove this Post'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                            title: Text("Are You Sure ?"),
                            content: Text("You Want To Delete ?"),
                            actions: <Widget>[
                              FlatButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text("NO"),
                              ),
                              FlatButton(
                                onPressed: () {
                                  deletePost();
                                },
                                child: Text("Yes"),
                              )
                            ]);
                      });
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              //              type == "BLOG"
              //                  ? SimpleDialogOption(
              //                      onPressed: () async {
              //                        this.fnEditBlog();
              //                      },
              //                      child: Text('Edit'),
              //                    )
              //                  : Container(),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
            ],
          );
        });
  }

  buildPostImage() {
    return GestureDetector(
      //   onDoubleTap: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(mediaUrl),
          showHeart
              // ?Text("Animator")
              ? Animator(
                  duration: Duration(milliseconds: 300),
                  tween: Tween(begin: 0.8, end: 1.4),
                  curve: Curves.elasticOut,
                  cycles: 0,
                  builder: (context, animatorState, child) {
                    return Transform.scale(
                      scale: 1.5,
                      child: Icon(Icons.favorite,
                          size: 80.0, color: Colors.red[300]),
                    );
                  },
                )
              : Text(''),
          showHeart
              ? Icon(
                  Icons.favorite,
                  size: 80.0,
                  color: Colors.red[300],
                )
              : Text(''),
        ],
      ),
    );
  }

  buildBlogView() {
    return GestureDetector(
        //   onDoubleTap: handleLikePost,
        child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "$title",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.blueGrey[700]),
                  ),
                  //              Text(
                  //                "$description",
                  //                style: TextStyle(fontSize: 15, color: Colors.blueGrey),
                  //              ),
                  Container(
                      child: Html(
                    onLinkTap: (url, context, attributes, element) async {
                      await launch(
                        url!,
                        universalLinksOnly: true,
                      );
                    },
                    data: content,
                  ))
                ])));
  }

  buildPostFooter() {
    return Container(
        child: Column(children: <Widget>[
      Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 40.0, left: 20.0),
            ),
            GestureDetector(
              onTap: () => handleLikePost(),
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28.0,
                color: Colors.pink,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 20.0),
            ),
            GestureDetector(
              onTap: () => showComments(
                context,
                postId: postId,
                ownerId: ownerId,
                mediaUrl: mediaUrl,
              ),
              child: Icon(
                Icons.chat_bubble,
                size: 28.0,
                color: Colors.blue[400],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              child: Center(
                child: IconButton(
                  icon: Icon(
                    Icons.share,
                    size: 28,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    createDynamicLink(username, postId, ownerId, type,
                        description, mediaUrl, content);
                  },
                ),
              ),
            ),

            // -------------------------------------------
            ReportOption(
              postId: postId,
              content: content,
              description: description,
              mediaUrl: mediaUrl,
              ownerId: ownerId,
              title: title,
              type: type,
              username: username,
            ),
          ]),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Container(
          margin: const EdgeInsets.only(left: 20.0, right: 7),
          child: Text(
            '$likeCount likes',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
            child: Text(
          description,
        ))
      ]),
      // put description in a row below
      // Row(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: <Widget>[
      //     Expanded(child: Text(description),
      //     ),
      //   ],
      // ),
    ]));
  }

  String appOwnerId = '102335314950657734812';
  String secondAdminId = '000143.dc00bb832a3e44adb981c340a8d7fb14.1305';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);

    // print(this.type);
    // print(this.content);

    if (this.content == null) {
      return Container();
    }
    isPostUserBlocked();

    return isUserBlocked ? Container() : buildPostHeader();
  }

  showComments(BuildContext context, {postId, ownerId, mediaUrl}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Comments(
        postId: postId,
        postOwnerId: ownerId,
        postMediaUrl: mediaUrl,
      );
    }));
  }

  deletePost() async {
    // delete post itself
    FirebaseFirestore.instance
        .collection('posts')
        .doc(ownerId)
        .collection('userPosts')
        .doc(postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete().then((value) {
          // Navigator.of(context).pop();
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return BottomBarScreen(currentUserId!);
          }));

          setState(() {});
          print('MUR POST DELETED');
        });
      }
    });
    // delete uploaded image for the post
    try {
      storageRef.ref().child('post_$postId.jpg').delete();
    } catch (e) {}
    // then delete all activity feed notifications
    QuerySnapshot activityFeedSnapshot = await activityFeedRef
        .doc(ownerId)
        .collection('feedItems')
        .where('postId', isEqualTo: postId)
        .get();
    activityFeedSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //  then delete all comments
    commentsRef.doc(postId).collection('comments').get();
    activityFeedSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleLikePost() {
    print('MUR POSTID: $postId  OWNDERID: $ownerId');
    bool _isLiked = likes[currentUserId] == true;

    if (_isLiked) {
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': false});

      removeLikeFromActivityFeed();

      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': true});
      addLikeToActivityFeed();

      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });

      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  addLikeToActivityFeed() {
    // add a notification to the post owner's activity feed only if comment made by other user
    // (to avoid getting notification for our own likes)
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef.doc(ownerId).collection('feedItems').doc(postId).set({
        'type': 'like',
        'username': currentUser!.username,
        'userId': currentUser!.id,
        'userProfileImg': currentUser!.photoUrl,
        'postId': postId,
        'mediaUrl': mediaUrl,
        'timestamp': timestamp,
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .doc(ownerId)
          .collection('feedItems')
          .doc(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  _showDialog(context, onDelete) {}

  isPostUserBlocked() async {
    await usersRef
        .doc(currentUserId)
        .collection("blocked")
        .doc(ownerId)
        .get()
        .then((value) => {
              if (value.exists)
                if (mounted)
                  {
                    setState(() {
                      //print(object)
                      isUserBlocked = true;
                    })
                  }
                else if (mounted)
                  {
                    setState(() {
                      isUserBlocked = false;
                    })
                  }
            });

    await usersRef
        .doc(currentUser!.id)
        .collection("blockedBy")
        .get()
        .then((value) => {
              for (var docData in value.docs) {blockedUser.add(docData.id)}
            });
  }
}

// ------------------report--------------------------------------

enum changingOption {
  violent,
  hateful_and_abusive,
  spam_or_misleading,
  Sexual_content,
}

class ReportOption extends StatefulWidget {
  final String postId;

  String ownerId;
  String username;
  String description;
  String mediaUrl;
  String title;
  String content;
  String type;

  ReportOption({
    required this.content,
    required this.description,
    required this.mediaUrl,
    required this.ownerId,
    required this.title,
    required this.type,
    required this.username,
    required this.postId,
  });

  @override
  _ReportOptionState createState() => _ReportOptionState();
}

class _ReportOptionState extends State<ReportOption> {
  changingOption? optionValue = changingOption.violent;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (content) {
              return SimpleDialog(children: [
                // ----------add stateful builder---------------------
                StatefulBuilder(builder: (context, setState) {
                  return Column(
                    children: [
                      const Center(
                        child: Text(
                          'Report the post',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      RadioListTile(
                          title: const Text('Violent content'),
                          value: changingOption.violent,
                          groupValue: optionValue,
                          onChanged: (changingOption? value) {
                            setState(() {
                              optionValue = value!;
                            });
                          }),
                      RadioListTile(
                          title: const Text('Hateful and abusive content'),
                          value: changingOption.hateful_and_abusive,
                          groupValue: optionValue,
                          onChanged: (changingOption? value) {
                            setState(() {
                              optionValue = value!;
                            });
                          }),
                      RadioListTile(
                          title: const Text('spam or misleading'),
                          value: changingOption.spam_or_misleading,
                          groupValue: optionValue,
                          onChanged: (changingOption? value) {
                            setState(() {
                              optionValue = value!;
                            });
                          }),
                      RadioListTile(
                          title: const Text('Sexual content'),
                          value: changingOption.Sexual_content,
                          groupValue: optionValue,
                          onChanged: (changingOption? value) {
                            setState(() {
                              optionValue = value!;
                            });
                          }),
                      SizedBox(
                        child: TextButton(
                          child: const Text('Report'),
                          onPressed: () async {
// ------------------------------add report firebase----------------------------------

                            await FirebaseFirestore.instance
                                .collection('report')
                                .doc(widget.postId)
                                .set({
                              'Report type':
                                  optionValue.toString().split('.').last,
                              'content': widget.content,
                              'description': widget.description,
                              'mediaUrl': widget.mediaUrl,
                              'ownerId': widget.ownerId,
                              'postId': widget.postId,
                              'title': widget.title,
                              'type': widget.type,
                              'username': widget.username
                            });

                            print(optionValue.toString().split(".").last);
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Thanks for reporting')));
                          },
                        ),
                      ),
                    ],
                  );
                }),
              ]);
            });
      },
      icon: const Icon(
        Icons.flag,
        size: 29,
        color: Colors.deepPurpleAccent,
      ),
    );
  }
}
