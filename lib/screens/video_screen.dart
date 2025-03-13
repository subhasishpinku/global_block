import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:global_ios/models/user_model.dart';
import 'package:global_ios/screens/full_screen_video.dart';
import 'package:global_ios/screens/login.dart';
import 'package:global_ios/screens/profile.dart';
import 'package:global_ios/utilities/bottom_navigation.dart';
import 'package:video_player/video_player.dart';
import 'home.dart';

class VideoScreenTimeline extends StatefulWidget {
  final content;
  final title;
  final mediaUrl;
  var description;
  String postId;
  String ownerId;
  String type;
  var likes;

  VideoScreenTimeline(
      {this.type = "",
      this.ownerId = "",
      this.postId = "",
      this.content,
      this.title,
      this.mediaUrl,
      this.description,
      this.likes});
  @override
  _VideoScreenTimelineState createState() => _VideoScreenTimelineState();
}

class _VideoScreenTimelineState extends State<VideoScreenTimeline> {
  String currentUserId = currentUser!.id;
  bool isLiked = false;
  bool showHeart = false;

  bool _videoPlayingInProgress = false;
  bool _videoReady = false, videoUploadinProgress = false;

  late VideoPlayerController _videoPlayerController;
  double screenWidth = 0;

  String videoUrl = "";

  bool showPlayButton = false;

  var likeCount;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.initState();
    likeCount = getLikeCount(widget.likes);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (_videoPlayerController != null) {
      _videoPlayerController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Container(
            child: Column(
          children: <Widget>[
            //Add Video
            Text(
              widget.title ?? "",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.blueGrey),
            ),

            SizedBox(
              height: 20,
            ),

            Center(
              child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 1, color: Theme.of(context).primaryColor)),
                  child: _videoReady
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              showPlayButton = !showPlayButton;
                            });
                          },
                          child: Container(
                            child: AspectRatio(
                              aspectRatio:
                                  _videoPlayerController.value.aspectRatio,
                              child: Stack(children: [
                                VideoPlayer(_videoPlayerController),
                                Center(
                                  child: showPlayButton
                                      ? FloatingActionButton(
                                          heroTag: Text('heroTag1'),
                                          onPressed: () {
                                            setState(() {
                                              _videoPlayerController
                                                      .value.isPlaying
                                                  ? _videoPlayerController
                                                      .pause()
                                                  : _videoPlayerController
                                                      .play();
                                            });
                                          },
                                          child: Icon(
                                            _videoPlayerController
                                                    .value.isPlaying
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                          ),
                                        )
                                      : Container(),
                                ),
                                Container(
                                  alignment: Alignment.bottomCenter,
                                  child: showPlayButton
                                      ? VideoProgressIndicator(
                                          _videoPlayerController,
                                          allowScrubbing: true,
                                          padding: EdgeInsets.all(10),
                                        )
                                      : Container(),
                                ),
                                Positioned(
                                    right: 10,
                                    bottom: 10,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.fullscreen,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        goToFullscreen();
                                      },
                                    ))
                              ]),
                            ),
                          ),
                        )
                      : _videoPlayingInProgress
                          ? Container(
                              height: MediaQuery.of(context).size.width,
                              width: MediaQuery.of(context).size.width,
                              child: const Center(
                                child: SpinKitThreeBounce(
                                  color: Colors.grey,
                                  size: 25,
                                ),
                              ),
                            )
                          : Container(
                              height: MediaQuery.of(context).size.width,
                              width: MediaQuery.of(context).size.width,
                              child: Center(
                                child: FloatingActionButton(
                                  heroTag: const Text('heroTag2'),
                                  onPressed: () {
                                    initialiseVideoController();
                                  },
                                  child: const Icon(
                                    Icons.play_arrow,
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(widget.mediaUrl),
                                    fit: BoxFit.cover),
                              ),
                            )),
            ),

            const SizedBox(
              height: 20,
            ),
          ],
        )),
      ),
    );
  }

  buildPostHeader() {
    print('MUR OWNER ID POD: ${widget.ownerId}');

    return FutureBuilder(
      future: usersRef.doc(widget.ownerId).get(),
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        bool isPostOwner = currentUserId == widget.ownerId;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: Text(
              "${user.username}",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // subtitle: location != null ? Text("${location}") : Text(""),
          trailing: isPostOwner
              ? IconButton(
                  onPressed: () => handleDeletePost(context),
                  icon: const Icon(Icons.more_vert),
                )
              : Text(''),
        );
      },
    );
  }

  Container circularProgress() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 10.0),
      child: const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.teal),
      ),
    );
  }

  showProfile(BuildContext context, {profileId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Profile(profileId),
      ),
    );
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
                          title: const Text("Are You Sure ?"),
                          content: const Text("You Want To Delete ?"),
                          actions: <Widget>[
                            FlatButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("NO"),
                            ),
                            FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                deletePost();
                              },
                              child: Text("Yes"),
                            )
                          ],
                        );
                      });
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
            ],
          );
        });
  }

  // Note: to delete a post, owner id and currentuserid must be equal, so they can be used interchangably
  deletePost() async {
    // delete post itself
    FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.ownerId)
        .collection('userPosts')
        .doc(widget.postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete().then((value) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return BottomBarScreen(currentUser!.username);
          }));
          print('MUR POST DELETED');
        });
      }
    });
    // delete uploaded image for the post
    // storageRef.child('post_${widget.postId}.jpg').delete();
    // then delete all activity feed notifications
    QuerySnapshot activityFeedSnapshot = await activityFeedRef
        .doc(widget.ownerId)
        .collection('feedItems')
        .where('postId', isEqualTo: widget.postId)
        .get();
    activityFeedSnapshot
      ..docs.forEach((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    //  then delete all comments
    commentsRef..doc(widget.postId).collection('comments').get();
    activityFeedSnapshot
      ..docs.forEach((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
  }

  initialiseVideoController() {
    print(widget.content);
    print("widget");
    if (widget.content != null) {
      setState(() {
        _videoPlayingInProgress = true;
      });

      _videoPlayerController =
          VideoPlayerController.network('${widget.content}')
            ..initialize().then((value) {
              setState(() {
                _videoReady = true;
                _videoPlayerController.play();
                _videoPlayingInProgress = false;
              });
            });

      print(
          'MUR VIDEO ASPECT RATIO: ${_videoPlayerController.value.aspectRatio}');
    }
  }

  buildPostFooter() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(
                  top: 40.0,
                  left: 20.0,
                ),
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
                padding: EdgeInsets.only(
                  right: 20.0,
                ),
              ),
              GestureDetector(
                onTap: () => showComments(
                  context,
                  postId: widget.postId,
                  ownerId: widget.ownerId,
                  mediaUrl: widget.mediaUrl,
                ),
                child: Icon(
                  Icons.chat_bubble,
                  size: 28.0,
                  color: Colors.blue[400],
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                height: 70,
                width: 70,
                child: IconButton(
                    icon: Icon(
                      Icons.share,
                      size: 60,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      createDynamicLink();
                    }),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
                  widget.description,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  showComments(BuildContext context, {postId, ownerId, mediaUrl}) {
    // Navigator.push(context, MaterialPageRoute(builder: (context) {
    //   return Comments(
    //     postId: postId,
    //     postOwnerId: ownerId,
    //     postMediaUrl: mediaUrl,
    //   );
    // }));
  }

  handleLikePost() {
    bool _isLiked = widget.likes[currentUserId] == true;

    if (_isLiked) {
      postsRef
        ..doc(widget.ownerId).collection('userPosts')
        ..doc(widget.postId).update({'likes.$currentUserId': false});
      removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        widget.likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      postsRef
        ..doc(widget.ownerId).collection('userPosts')
        ..doc(widget.postId).update({'likes.$currentUserId': true});
      addLikeToActivityFeed();
      setState(() {
        likeCount += 1;
        isLiked = true;
        widget.likes[currentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
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

  addLikeToActivityFeed() {
    // add a notification to the post owner's activity feed only if comment made by other user
    // (to avoid getting notification for our own likes)
    bool isNotPostOwner = currentUserId != widget.ownerId;
    if (isNotPostOwner) {
      activityFeedRef
        ..doc(widget.ownerId).collection('feedItems')
        ..doc(widget.postId).set({
          'type': 'like',
          'username': currentUser!.username,
          'userId': currentUser!.id,
          'userProfileImg': currentUser!.photoUrl,
          'postId': widget.postId,
          'mediaUrl': widget.mediaUrl,
          'timestamp': timestamp,
        });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != widget.ownerId;
    if (isNotPostOwner) {
      activityFeedRef
        ..doc(widget.ownerId).collection('feedItems')
        ..doc(widget.postId).get().then(
          (doc) {
            if (doc.exists) {
              doc.reference.delete();
            }
          },
        );
    }
  }

  goToFullscreen() async {
    Duration? duration;
    duration = await _videoPlayerController.position;
    await _videoPlayerController.pause();

    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return FullScreen(
        currentDuration: duration,
        content: widget.content,
        mediaUrl: widget.mediaUrl,
      );
    }));
  }

  void createDynamicLink() {
    // String postId = widget.postId,
    //     title = widget.title,
    //     description = widget.description,
    //     mediaUrl = widget.mediaUrl,
    //     contentUrl = widget.content,
    //     type = widget.type,
    //     ownerId = widget.ownerId;

    // DynamicLinkParameters parameters = DynamicLinkParameters(
    //   uriPrefix: "https://globshare.page.link",
    //   link: Uri.parse(
    //       'https://globshare.page.link?ownerId=$ownerId&id=$postId,&type=$type&title=$title&description=$description&mediaUrl=$mediaUrl&content=$contentUrl'),
    //   androidParameters: AndroidParameters(
    //       packageName: 'com.gaurav.fluttershare', minimumVersion: 2),
    //   iosParameters: IosParameters(
    //     bundleId: 'com.gaurav.fluttershare',
    //     appStoreId: 'com.gaurav.fluttershare',
    //     minimumVersion: '1',
    //   ),
    // );

    // var shortLink = parameters.buildShortLink();
    // print('MUR DYNAMIC URL: $shortLink');
  }
}
