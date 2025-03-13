import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:uuid/uuid.dart';

import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';

import 'login.dart';

typedef Fn = void Function();

class CreatePod extends StatefulWidget {
  final currentUser;
  CreatePod({this.currentUser});

  @override
  _CreatePodState createState() => _CreatePodState();
}

class _CreatePodState extends State<CreatePod> {
  final blogTitleController = TextEditingController();
  final blogDescriptionController = TextEditingController();

  FilePickerResult? file;
  AudioPlayer? audioPlayer;
  bool process = false;

  // -------------------------------------------------------------
  var pickedImage;
  final _pickr = ImagePicker();
  buidImage() async {
    final pick = await _pickr.pickImage(source: ImageSource.gallery);

    setState(() {
      pickedImage = File(pick!.path);
    });
  }
//--------------------------------------------------------------------

  var playerModule = FlutterSoundPlayer();

  void playSound(var song) {
    playerModule.startPlayer(fromURI: song);
  }

  void playaudio(song) async {
    await audioPlayer!.setFilePath(song);
    await audioPlayer!.play();
  }

  //-----------------------------------------------------------

  void addtofirebase() {
    // final ref = FirebaseStorage.instance.ref().child(path);
  }

  bool artFlag = false;
  var albumArtUrl;

  Future<String> uploadAlbumArt(File profile) async {
    String postId = Uuid().v4();
    final uploadtask =
        FirebaseStorage.instance.ref().child('profile_$postId.png');

    await uploadtask.putFile(profile);
    String downloadUrl = await uploadtask.getDownloadURL();

    setState(() {
      albumArtUrl = downloadUrl;
    });
    print('done');

    return downloadUrl;
  }

  // -----------------------------------------------------------------

  // --------------------------------------------------------------------
  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   init();
  // }

  // init() async {
  //   await playerModule.openAudioSession();
  // }

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   super.dispose();
  //   playerModule.closeAudioSession();
  // }

  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  bool _mPlayerIsInited = false;

  @override
  void initState() {
    super.initState();
    _mPlayer!.openAudioSession().then((value) {
      setState(() {
        _mPlayerIsInited = true;
        print('-------------------------');
        print(Uuid().v4());
        print(currentUser!.id);
        print('-------------------------');
      });
    });
  }

  @override
  void dispose() {
    stopPlayer();
    // Be careful : you must `close` the audio session when you have finished with it.
    _mPlayer!.closeAudioSession();
    _mPlayer = null;

    super.dispose();
  }

  void play() async {
    await _mPlayer!.startPlayer(
        fromURI: file!.paths[0]
        // _exampleAudioFilePathMP3
        ,
        // codec: Codec.mp3,
        whenFinished: () {
          setState(() {});
        });
    setState(() {});
  }

  Future<void> stopPlayer() async {
    if (_mPlayer != null) {
      await _mPlayer!.stopPlayer();
    }
  }

  Fn? getPlaybackFn() {
    if (!_mPlayerIsInited) {
      return null;
    }
    return _mPlayer!.isStopped
        ? play
        : () {
            stopPlayer().then((value) => setState(() {}));
          };
  }

  // ---------------------------------------

  var podCastUrl;

  Future<String> uploadPodcast(File podCast) async {
    String postId = Uuid().v4();
    var uploadTask = storageRef.ref().child('post_$postId.aac');
    var storageSnap = await uploadTask.putFile(podCast);
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    setState(() {
      podCastUrl = downloadUrl;
    });

    return downloadUrl;
  }

  // ------------------------------------------------

  Future createPodcastInFireStore(
      {required String title,
      required String description,
      required String content,
      required String albumArt}) async {
    String postId = Uuid().v4();
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
        'description': description,
        'type': 'PODCAST',
        'description': description,
        'content': content,
        'timestamp': timestamp,
        'likes': {},
        'mediaUrl': albumArt,
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget makeBody() {
      return Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blue,
            child: Center(
              child: IconButton(
                  iconSize: 60,
                  color: Colors.amber,
                  onPressed: getPlaybackFn(),
                  icon: _mPlayer!.isPlaying
                      ? Icon(
                          Icons.pause,
                        )
                      : Icon(
                          Icons.play_arrow,
                        )),
            ),
          ),
          Text(_mPlayer!.isPlaying
              ? 'Playback in progress'
              : 'Player is stopped'),
          // Container(
          //   margin: const EdgeInsets.all(3),
          //   padding: const EdgeInsets.all(3),
          //   height: 80,
          //   width: double.infinity,
          //   alignment: Alignment.center,
          //   decoration: BoxDecoration(
          //     color: Color(0xFFFAF0E6),
          //     border: Border.all(
          //       color: Colors.indigo,
          //       width: 3,
          //     ),
          //   ),
          //   child: Row(children: [
          //     ElevatedButton(
          //       onPressed: getPlaybackFn(),
          //       //color: Colors.white,
          //       //disabledColor: Colors.grey,
          //       child: Text(_mPlayer!.isPlaying ? 'Stop' : 'Play'),
          //     ),
          //     const SizedBox(
          //       width: 20,
          //     ),
          //     Text(_mPlayer!.isPlaying
          //         ? 'Playback in progress'
          //         : 'Player is stopped'),
          //   ]),
          // ),
        ],
      );
    }

    // --------------------------------------
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create pod'),
        actions: <Widget>[
// ----------------------------------from here ------------------------------------------------------------------
          FlatButton(
            child: Text(
              process ? "Uploading" : "POST",
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () async {
              setState(() {
                process = true;
              });
              print(albumArtUrl);
//

// -------------------------------------to do next -------------------------------------------------------
// File(pick!.path)
              await uploadPodcast(File(file!.paths[0]!))
                  .then(
                    (value) => createPodcastInFireStore(
                      title: blogTitleController.text,
                      description: blogDescriptionController.text,
                      albumArt: albumArtUrl ?? currentUser!.photoUrl,
                      content: podCastUrl!,
                    ),
                  )
                  .whenComplete(
                    () => Navigator.of(context).pop(),
                  );
              // _showToast(
              //   title: "PODCAST is Uploaded",
              //   color: Colors.green,
              //   icon: Icons.check,
              // );

// ------------------------------------till now---------------------------------------------------------------------
            },
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Create your podcast',
                style: TextStyle(fontSize: 24),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.only(top: 10),
                child: TextField(
                  controller: blogTitleController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Title"),
                ),
              ),
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.only(top: 10),
                child: TextField(
                  maxLines: 4,
                  minLines: 3,
                  maxLength: 200,
                  controller: blogDescriptionController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'desciption',
                  ),
                ),
              ),
              albumArtUrl != null
                  ? CircleAvatar(
                      radius: 80,
                      backgroundImage: NetworkImage(albumArtUrl),
                    )
                  : Container(),
              if (albumArtUrl != null)
                const SizedBox(
                  height: 20,
                ),
              artFlag
                  ? const SpinKitThreeBounce(
                      color: Colors.grey,
                      size: 35,
                    )
                  // CircularProgressIndicator()
                  : Container(
                      margin: const EdgeInsets.symmetric(horizontal: 50),
                      child: RaisedButton(
                        onPressed: () async {
                          if (albumArtUrl == null) {
                            await buidImage();
                            setState(() {
                              artFlag = true;
                            });
                            await uploadAlbumArt(pickedImage);
                            setState(() {
                              artFlag = false;
                            });
                          } else {
                            setState(() {
                              albumArtUrl = null;
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
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
              Column(
                children: [
                  // Text(
                  //   playerTxt,
                  //   style: const TextStyle(
                  //     fontSize: 35.0,
                  //     color: Colors.black,
                  //   ),
                  // ),
                  // Row(
                  //   children: [
                  //     Center(
                  //       child: IconButton(
                  //         onPressed: () {
                  //           // playSound(file);
                  //           playaudio(file!);
                  //         },
                  //         icon: Icon(Icons.play_arrow),
                  //       ),
                  //     )
                  //   ],
                  // )
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() async {
                    file = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['mp3', 'aac', 'ogg', 'wav', 'm4a' , 'mp4']);
                  });

                  setState(() {});
                },
                child: const Text('pick podcast'),
              ),

              makeBody()

// -------------------------------------------------------------------
            ],
          ),
        ),
      ),
    );
  }
}
