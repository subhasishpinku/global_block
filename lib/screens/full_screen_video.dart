import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:global_ios/models/user_model.dart';
import 'package:global_ios/screens/login.dart';
// import 'package:fluttershare/pages/createPodcast.dart';
import 'package:global_ios/screens/profile.dart';
import 'package:video_player/video_player.dart';

import 'comments.dart';
import 'home.dart';

class FullScreen extends StatefulWidget {
  final content;
  final title;
  final mediaUrl;
  var description;
  String? postId;
  String? ownerId;

  Duration? currentDuration;
  var likes;

  FullScreen(
      {this.currentDuration,
      this.ownerId,
      this.postId,
      this.content,
      this.title,
      this.mediaUrl,
      this.description,
      this.likes});
  @override
  _FullScreenState createState() => _FullScreenState();
}

class _FullScreenState extends State<FullScreen> {
  String? currentUserId = currentUser!.id;
  bool isLiked = false;
  bool showHeart = false;

  bool _videoPlayingInProgress = false;
  bool _videoReady = false, videoUploadinProgress = false;

  VideoPlayerController? _videoPlayerController;
  double? screenWidth;

  String? videoUrl;

  bool showPlayButton = true;

  var likeCount;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

    // likeCount = getLikeCount(widget.likes);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (_videoPlayerController != null) {
      _videoPlayerController!.dispose();
    }
  }

  _buildBackButton() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      height: MediaQuery.of(context).size.height,
      child: Align(
        alignment: Alignment.topLeft,
        child: showPlayButton
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () async {
                  SystemChrome.setEnabledSystemUIOverlays(
                      SystemUiOverlay.values);

                  SystemChrome.setPreferredOrientations(
                      [DeviceOrientation.portraitUp]);

                  if (_videoPlayerController!.value.isInitialized) {
                    // await _videoPlayerController.dispose();
                    Navigator.pop(context);
                  } else {
                    Navigator.pop(context);
                  }
                })
            : Container(),
      ),
    );
  }

  _buildPlayPauseButton() {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: showPlayButton
            ? VideoProgressIndicator(
                _videoPlayerController!,
                allowScrubbing: true,
                padding: EdgeInsets.all(10),
              )
            : Container(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_videoPlayerController != null) {}
        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
        await SystemChrome.setPreferredOrientations(
            [DeviceOrientation.portraitUp]);

        return true;
      },
      child: Scaffold(
        body: Container(
          child: Container(
            child:
                //Add Video

                Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                  // border: Border.all(
                  //     width: 1, color: Theme.of(context).primaryColor)

                  ),
              child: _videoReady
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          showPlayButton = !showPlayButton;
                        });
                      },
                      child: Center(
                        child: AspectRatio(
                          aspectRatio:
                              _videoPlayerController!.value.aspectRatio,
                          child: Stack(children: [
                            VideoPlayer(_videoPlayerController!),

                            _buildPlayPauseButton(),
                            _buildBackButton(), // _ControlsOverlay(controller: _controller),

                            Center(
                              // left: MediaQuery.of(context).size.width / 2,
                              // top: 100,
                              child: showPlayButton
                                  ? GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _videoPlayerController!
                                                  .value.isPlaying
                                              ? _videoPlayerController!.pause()
                                              : _videoPlayerController!.play();
                                        });
                                      },
                                      child: Container(
                                        height: 60,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        child: Icon(
                                          _videoPlayerController!
                                                  .value.isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ),
                          ]),
                        ),
                      ),
                    )
                  : _videoPlayingInProgress
                      ? const Center(
                          child: SpinKitThreeBounce(
                            color: Colors.grey,
                            size: 35,
                          ),
                          // CircularProgressIndicator(),
                        )
                      : Center(
                          child: Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.height,
                            child: Center(
                              child: FloatingActionButton(
                                heroTag: Text('heroTagFullscreenVideo'),
                                onPressed: () {
                                  initialiseVideoController();
                                },
                                child: Icon(
                                  Icons.play_arrow,
                                ),
                              ),
                            ),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(widget.mediaUrl),
                                  fit: BoxFit.cover),
                            ),
                          ),
                        ),
            ),

            // Text(
            //   widget.title ?? "",
            //   style: TextStyle(
            //       fontWeight: FontWeight.bold,
            //       fontSize: 20,
            //       color: Colors.blueGrey),
            // ),

            // Container(
            //     padding: EdgeInsets.all(15),
            //     child: Text(widget.description,
            //         style: TextStyle(
            //           fontSize: 16,
            //         ))),
          ),
        ),
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
                  icon: Icon(Icons.more_vert),
                )
              : Text(''),
        );
      },
    );
  }

  Container circularProgress() {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 10.0),
        child: const SpinKitThreeBounce(
          color: Colors.grey,
          size: 35,
        )
        // CircularProgressIndicator(
        //   valueColor: AlwaysStoppedAnimation(Colors.teal),
        // ),
        );
  }

  showProfile(BuildContext context, {String? profileId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Profile(profileId!),
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
                          title: Text("Are You Sure ?"),
                          content: Text("You Want To Delete ?"),
                          actions: <Widget>[
                            FlatButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text("NO"),
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
            return Home(currentUser!);
          }));
          print('MUR POST DELETED');
        });
      }
    });
    // delete uploaded image for the post
    storageRef.ref().child('post_${widget.postId}.jpg').delete();
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

  double aspectRatio = 3 / 2;
  initialiseVideoController() {
    if (widget.content != null) {
      setState(() {
        _videoPlayingInProgress = true;
      });

      _videoPlayerController =
          VideoPlayerController.network('${widget.content}')
            ..initialize().then((value) {
              setState(() {
                _videoReady = true;
                _videoPlayerController!.seekTo(widget.currentDuration!);
                _videoPlayerController!.play();
                _videoPlayingInProgress = false;
                aspectRatio = _videoPlayerController!.value.aspectRatio;
              });
            });

      print(
          'MUR VIDEO ASPECT RATIO: ${_videoPlayerController!.value.aspectRatio}');
    }
  }

  buildPostFooter() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
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
              Padding(
                padding: EdgeInsets.only(
                  right: 20.0,
                ),
              ),
              GestureDetector(
                onTap: () => showComments(
                  context,
                  postId: widget.postId!,
                  ownerId: widget.ownerId!,
                  mediaUrl: widget.mediaUrl,
                ),
                child: Icon(
                  Icons.chat_bubble,
                  size: 28.0,
                  color: Colors.blue[400],
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 20.0, right: 7),
                child: Text(
                  '$likeCount likes',
                  style: TextStyle(
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
          // put description in a row below
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: <Widget>[
          //     Expanded(child: Text(description),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  showComments(BuildContext context,
      {String? postId, String? ownerId, String? mediaUrl}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Comments(
        postId: postId!,
        postOwnerId: ownerId!,
        postMediaUrl: mediaUrl!,
      );
    }));
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
        ..doc(widget.postId).get().then((doc) {
          if (doc.exists) {
            doc.reference.delete();
          }
        });
    }
  }
}
