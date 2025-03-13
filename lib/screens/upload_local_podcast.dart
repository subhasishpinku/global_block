import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:global_ios/screens/create_podcast.dart';
import 'package:global_ios/screens/login.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:uuid/uuid.dart';

class LocalPodcast extends StatefulWidget {
  final assetPath;
  final currentUser;

  LocalPodcast({this.assetPath, this.currentUser});
  @override
  _LocalPodcastState createState() => _LocalPodcastState();
}

class _LocalPodcastState extends State<LocalPodcast> {
  String albumArtUrl = "";
  bool artFlag = false;
  late Fluttertoast flutterToast;
  TextEditingController blogTitleController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // flutterToast = Fluttertoast(context);
  }

  final player = AudioPlayer();
  bool isPlaying = false;
  bool process = false;

  fnLoadPlayer() async {
    var duration = await player.setFilePath(widget.assetPath);

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

  getlist(state, buffering) {
    if (state == AudioState.isPlaying || buffering == true) {
      return Container(
          margin: EdgeInsets.all(8.0),
          width: 64.0,
          height: 64.0,
          child: const SpinKitThreeBounce(
            color: Colors.grey,
            size: 35,
          )
          //  CircularProgressIndicator(),
          );
    } else if (state == AudioState.isPlaying) {
      return IconButton(
        icon: Icon(Icons.pause),
        iconSize: 64.0,
        onPressed: player.pause,
      );
    } else {
      return IconButton(
        icon: Icon(Icons.play_arrow),
        iconSize: 64.0,
        onPressed: fnLoadPlayer,
      );
    }
  }

  String postId = Uuid().v4();
  String podCastUrl = "";
  Future<String> uploadPodcast(podCast) async {
    String downloadUrl = "";
    // StorageUploadTask uploadTask =
    //     storageRef.child('post_$postId.aac').putFile(podCast);
    // StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    // String downloadUrl = await storageSnap.ref.getDownloadURL();
    // podCastUrl = downloadUrl;
    return downloadUrl;
  }

  Future createPodcastInFireStore({title, description, content}) async {
    try {
      await postsRef
          .doc(widget.currentUser.id)
          .collection('userPosts')
          .doc(postId)
          .set({
        'postId': postId,
        'ownerId': widget.currentUser.id,
        'username': widget.currentUser.username,
        'title': title,
        'type': 'PODCAST',
        'description': description,
        'content': content,
        'timestamp': timestamp,
        'likes': {},
        'mediaUrl': albumArtUrl,
        // '${widget.currentUser.photoUrl}'
      });
    } catch (e) {
      print(e);
    }
  }

  File _image = File("");
  final picker = ImagePicker();

  buildPickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  Future<String> uploadAlbumArt(profile) async {
    String postId = Uuid().v4();
    String downloadUrl = "";
    // StorageUploadTask uploadTask =
    //     storageRef.child('profile_$postId.png').putFile(profile);
    // StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    // String downloadUrl = await storageSnap.ref.getDownloadURL();

    // setState(() {
    //   albumArtUrl = downloadUrl;
    // });
    // print("done");

    return downloadUrl;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(File(widget.assetPath).lengthSync());
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Local Podcast"),
        actions: <Widget>[
          FlatButton(
            child: Text(
              process ? "Uploading" : "POST",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              setState(() {
                player.dispose();
                process = true;
              });
              await uploadPodcast(File(widget.assetPath))
                  .then((value) => createPodcastInFireStore(
                      title: blogTitleController.text,
                      description: "",
                      content: podCastUrl))
                  .whenComplete(() => Navigator.of(context).pop());
              _showToast();
            },
          )
        ],
      ),
      body: Center(
          child: Stack(
        children: <Widget>[
          Container(
              child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                padding: EdgeInsets.only(top: 10),
                child: TextField(
                  controller: blogTitleController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: "Title"),
                ),
              ),
              artFlag
                  ? LinearProgressIndicator()
                  : Container(
                      margin: EdgeInsets.symmetric(horizontal: 50),
                      child: RaisedButton(
                        onPressed: () async {
                          if (albumArtUrl == null) {
                            await buildPickImage();
                            setState(() {
                              artFlag = true;
                            });
                            await uploadAlbumArt(_image);
                            setState(() {
                              artFlag = false;
                            });
                          } else {
                            setState(() {
                              albumArtUrl = "";
                            });
                          }
                        },
                        color: albumArtUrl != null
                            ? Colors.red
                            : Colors.deepPurple,
                        child: Text(
                          albumArtUrl != null
                              ? "Remove Album Art"
                              : "Upload Album Art",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
              albumArtUrl != null
                  ? Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      height: 200,
                      width: 150,
                      child: Image.network(
                        albumArtUrl,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(),
              StreamBuilder(
                // stream: player.fullPlaybackStateStream,
                stream: player.playerStateStream,
                builder: (context, snapshot) {
                  final fullState = snapshot.data;
                  //   final state = fullState?.state;
                  final state = fullState.toString();
                  //   final buffering = fullState?.buffering;
                  final buffering = player.playerState.processingState;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      getlist(state, buffering),
                      IconButton(
                        icon: Icon(Icons.stop),
                        iconSize: 64.0,
                        onPressed: () => null,
                        // onPressed: state == AudioPlaybackState.stopped ||
                        //         state == AudioPlaybackState.none
                        //     ? null
                        //     : player.stop,
                      )
                    ],
                  );
                },
              ),
              StreamBuilder(
                // stream: player.durationStream,
                stream: player.durationStream,
                builder: (context, snapshot) {
                  final duration = snapshot.data ?? Duration.zero;
                  return StreamBuilder<Duration>(
                    stream: player.positionStream,
                    builder: (context, AsyncSnapshot snapshot) {
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
                            duration: duration as Duration,
                            position: position,
                            onChanged: (value) => null,
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
            ],
          )),
          process
              ? Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                      child: SpinKitThreeBounce(
                    color: Colors.grey,
                    size: 35,
                  )
                      //     CircularProgressIndicator(
                      //   valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                      ))
              // )
              : Container(),
        ],
      )),
    );
  }

  _showToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.green,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check,
            color: Colors.white,
          ),
          SizedBox(
            width: 12.0,
          ),
          Text(
            "PodCast is Uploaded",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    // return flutterToast.showToast(
    //   child: toast,
    //   gravity: ToastGravity.BOTTOM,
    //   toastDuration: Duration(seconds: 2),
    // );
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
      value: _dragValue == null
          ? _dragValue
          : widget.position.inMilliseconds.toDouble(),
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
