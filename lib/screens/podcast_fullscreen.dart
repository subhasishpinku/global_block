import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:global_ios/models/user_model.dart';
import 'package:global_ios/screens/create_podcast.dart';
import 'package:global_ios/screens/login.dart';
import 'package:global_ios/screens/profile.dart';
import 'package:just_audio/just_audio.dart';

class PodCastFullScreen extends StatefulWidget {
  final content;
  final title;
  final mediaUrl;
  var description;
  String postId;
  String ownerId;

  PodCastFullScreen({
    this.ownerId = "",
    this.postId = "",
    this.content,
    this.title,
    this.mediaUrl,
    this.description,
  });

  @override
  _PodCastFullScreenState createState() => _PodCastFullScreenState();
}

class _PodCastFullScreenState extends State<PodCastFullScreen> {
  String? currentUserId = currentUser!.id;

  @override
  void initState() {
    super.initState();
  }

  final player = AudioPlayer();
  bool isPlaying = false;

  fnLoadPlayer() async {
    var duration = await player.setUrl(this.widget.content);

    player.play();
    setState(() {
      isPlaying = true;
    });
  }

  fnPause() {
    player.pause();
    setState(() {
      isPlaying = false;
    });
  }

  getlist(playing, state, buffering) {
    if (state == ProcessingState.loading || buffering == true) {
      return Container(
          margin: const EdgeInsets.all(8.0),
          width: 64.0,
          height: 64.0,
          child: SpinKitCircle(
            color: Colors.grey,
          )
          // CircularProgressIndicator(),
          );
    } else if (playing == true) {
      return IconButton(
        icon: Icon(Icons.pause),
        iconSize: 64.0,
        onPressed: () {
          player.pause();
        },
      );
    } else {
      return IconButton(
        icon: Icon(Icons.play_arrow),
        iconSize: 64.0,
        onPressed: fnLoadPlayer,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PodCast"),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
              child: Column(
            children: <Widget>[
              buildPostHeader(),
              Container(
                margin: const EdgeInsets.only(top: 50),
                height: 300,
                width: 300,
                child: FancyShimmerImage(
                  boxFit: BoxFit.contain,
                  imageUrl: '${widget.mediaUrl}',
                  shimmerBaseColor: Colors.white,
                  shimmerHighlightColor: Colors.blueGrey,
                  shimmerBackColor: Colors.black,
                ),
              ),
              Text(
                widget.title ?? "",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.blueGrey),
              ),
              StreamBuilder<PlayerState>(
                  stream: player.playerStateStream,
                  builder: (context, AsyncSnapshot snapshot) {
                    final fullState = snapshot.data;
                    // final state = fullState?.state;
                    final state = fullState?.processingState;
                    // final buffering = fullState?.buffering;
                    // final buffering = fullState?.buffering;
                    final playing = fullState?.playing;

                    return Row(mainAxisSize: MainAxisSize.min, children: [
                      getlist(playing, state, ProcessingState.buffering),
                      IconButton(
                        icon: Icon(Icons.stop),
                        iconSize: 64.0,
                        onPressed: state == AudioState.isStopped
                            // || state == AudioState.none
                            ? null
                            : player.stop,
                      )
                    ]);
                  }),
              StreamBuilder<Duration?>(
                stream: player.durationStream,
                builder: (context, snapshot) {
                  final duration = snapshot.data ?? Duration.zero;
                  return StreamBuilder<Duration>(
                    stream: player.positionStream,
                    builder: (context, snapshot) {
                      var position = snapshot.data ?? Duration.zero;
                      if (position > duration) {
                        position = duration;
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          IconButton(
                              icon: Icon(Icons.replay_10),
                              iconSize: 40.0,
                              onPressed: () {
                                player.seek(position - position ~/ 5);
                              }),
                          SeekBar(
                            onChanged: (value) {},
                            duration: duration,
                            position: position,
                            onChangeEnd: (newPosition) {
                              player.seek(newPosition);
                            },
                          ),
                          IconButton(
                              icon: Icon(Icons.forward_10),
                              iconSize: 40.0,
                              onPressed: () {
                                player.seek(position + position ~/ 5);
                              }),
                        ],
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 20),
              Container(
                  padding: EdgeInsets.all(15),
                  child:
                      Text(widget.description, style: TextStyle(fontSize: 16))),
            ],
          )),
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
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
      child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.teal)),
    );
  }

  showProfile(BuildContext context, {profileId}) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Profile(profileId)));
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
              //type == "BLOG"
              //? SimpleDialogOption(
              //onPressed: () async {
              //this.fnEditBlog();
              //},
              //child: Text('Edit'),
              //)
              //: Container(),
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
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context)
          // {
          // return Home();
          // }));
          print('MUR POST DELETED');
        });
      }
    });
    // delete uploaded image for the post
    // storageRef.child('post_${widget.postId}.jpg').delete();
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
}

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration> onChanged;
  final ValueChanged<Duration> onChangeEnd;

  SeekBar({
    required this.duration,
    required this.position,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double _dragValue = 0;

  @override
  Widget build(BuildContext context) {
    return Slider(
      min: 0.0,
      max: widget.duration.inMilliseconds.toDouble(),
      value: widget.position.inMilliseconds.toDouble(),
      onChanged: (value) {
        setState(() {
          _dragValue = value;
        });
        if (widget.onChanged != null) {
          widget.onChanged(Duration(milliseconds: value.round()));
        }
      },
      onChangeEnd: (value) {
        _dragValue = 0;
        if (widget.onChangeEnd != null) {
          widget.onChangeEnd(Duration(milliseconds: value.round()));
        }
      },
    );
  }
}
