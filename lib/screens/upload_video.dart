import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:global_ios/models/user_model.dart';
import 'package:global_ios/screens/login.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'home.dart';

class UploadVideo extends StatefulWidget {
  @override
  _UploadVideoState createState() => _UploadVideoState();

  User? currentUser;
  UploadVideo({this.currentUser});
}

class _UploadVideoState extends State<UploadVideo> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  bool _videoAdded = false;
  File? _videoFile, _thumbnail;
  bool _videoReady = false, videoUploadinProgress = false;
  final FirebaseStorage storageRef = FirebaseStorage.instance;
  String uploadText = 'Upload Video';

  late VideoPlayerController _videoPlayerController;

  String? videoUrl;

  String? albumArtUrl;

  late Fluttertoast flutterToast;

  double? _progess;

  @override
  void initState() {
    super.initState();
  }

  Widget _buildUploadForm() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(top: 10),
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "Title"),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            _videoAdded
                ? Container(
                    height: 400,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    child: _videoReady
                        ? Container(
                            child: AspectRatio(
                              aspectRatio:
                                  _videoPlayerController.value.aspectRatio,
                              child: Stack(children: [
                                VideoPlayer(_videoPlayerController),
                                // _ControlsOverlay(controller: _controller),

                                Center(
                                  // left: MediaQuery.of(context).size.width / 2,
                                  // top: 100,
                                  child: FloatingActionButton(
                                    onPressed: () {
                                      setState(() {
                                        _videoPlayerController.value.isPlaying
                                            ? _videoPlayerController.pause()
                                            : _videoPlayerController.play();
                                      });
                                    },
                                    child: Icon(
                                      _videoPlayerController.value.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  child: VideoProgressIndicator(
                                    _videoPlayerController,
                                    allowScrubbing: true,
                                    padding: EdgeInsets.all(10),
                                  ),
                                ),
                              ]),
                            ),
                          )
                        : Container(
                            child: Center(
                              child: Text('Playing Video..'),
                            ),
                          ))
                : GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 1, color: Theme.of(context).primaryColor)),
                      height: 200,
                      width: double.infinity,
                      child: Center(
                          child: Container(
                        child: Text('click to Add Video',
                            style: TextStyle(
                              color: Colors.white,
                            )),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Theme.of(context).primaryColor),
                      )),
                    ),
                    onTap: () {
                      chooseDailog(context);
                    },
                  ),
            _videoAdded
                ? Container(
                    margin: EdgeInsets.only(top: 10, right: 10),
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          child: Container(
                            // padding: EdgeInsets.symmetric(
                            //     vertical: 10, horizontal: 15),
                            child: Text(
                              'Change Video',
                              style: TextStyle(color: Colors.blueGrey),
                            ),
                            decoration: BoxDecoration(
                                // color: Theme.of(context).primaryColor,
                                // borderRadius: BorderRadius.circular(20),
                                ),
                          ),
                          onTap: () {
                            chooseDailog(context);
                          },
                        )
                      ],
                    ),
                  )
                : Container(),
            SizedBox(
              height: 20,
            ),
            Container(
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _thumbnail == null
                      ? Image(
                          image: AssetImage(
                            'assets/images/thumbnail.png',
                          ),
                          height: 40,
                          width: 40,
                        )
                      : Image.file(
                          _thumbnail!,
                          width: 70,
                          height: 70,
                        ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    child: Center(
                      child: Container(
                        child: Text('Upload thumbnail',
                            style: TextStyle(
                              color: Colors.white,
                            )),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                    onTap: () {
                      openGalleryForThumnail();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              child: TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "Description"),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              child: Center(
                child: Container(
                  width: double.infinity,
                  child: Center(
                    child: Text('$uploadText',
                        style: TextStyle(
                          color: Colors.white,
                        )),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                      // borderRadius: BorderRadius.circular(25),
                      color: videoUploadinProgress
                          ? Colors.blueGrey[300]
                          : Theme.of(context).primaryColor),
                ),
              ),
              onTap: () {
                if (!videoUploadinProgress) {
                  uploadVideo();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Video'),
      ),
      body: _buildUploadForm(),
    );
  }

  chooseDailog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text('Create Post'),
            children: <Widget>[
              SimpleDialogOption(
                child: Text('Video with Camera'),
                onPressed: openCamera,
              ),
              SimpleDialogOption(
                child: Text('Video from Gallery'),
                onPressed: openGallery,
              ),
              SimpleDialogOption(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  succesDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Video Uploaded Successfully'),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text('Okay')),
            ],
          );
        });
  }

  showThumbnailDialog(String message) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Please upload $message to continue'),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Okay')),
            ],
          );
        });
  }

  void openGallery() async {
    var pickedVideo = await ImagePicker().getVideo(source: ImageSource.gallery);
    Navigator.pop(context);

    setState(() {
      _videoFile = File(pickedVideo!.path);
      _videoAdded = true;
      initialiseVideoController();
    });
  }

  void openCamera() async {
    var pickedVideo = await ImagePicker().getVideo(source: ImageSource.camera);

    Navigator.pop(context);
    setState(() {
      _videoFile = File(pickedVideo!.path);
      _videoAdded = true;
      initialiseVideoController();
    });
  }

  openGalleryForThumnail() async {
    var pickedImage = await ImagePicker().getImage(
      source: ImageSource.gallery,
    );

    setState(() {
      _thumbnail = File(pickedImage!.path);
    });
  }

  initialiseVideoController() {
    if (_videoAdded && _videoFile != null) {
      _videoPlayerController = VideoPlayerController.file(_videoFile!)
        ..initialize().then((value) {
          setState(() {
            _videoReady = true;
          });
        });
    }
  }

  Future<String?> uploadVideoToFb() async {
    print(_videoFile);
    print("_videoFile");
    setState(() {
      uploadText = 'Uploading video it may take a minute or two..';
      videoUploadinProgress = true;
    });
    String postId = Uuid().v4();

    print("1");
    var snapshot =
        await storageRef.ref().child('post_$postId.mp4').putFile(_videoFile!);
    print("2");
    var downloadUrl = await snapshot.ref.getDownloadURL();
    print("3");
    videoUrl = downloadUrl;

    print(videoUrl);
    print("VIDEO URLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL");

    // uploadTask.then((event)
    // {
    //   setState(() {
    //     _progess = event.snapshot.bytesTransferred.toDouble() / event.snapshot.totalByteCount.toDouble();
    //   });
    // }).onError((e)
    // {
    //   // _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(error.toString()), backgroundColor: Colors.red,) );
    // });

    await upload_thumbnail();
    return downloadUrl;
  }

  Future<String?> upload_thumbnail() async {
    String postId = Uuid().v4();

    var snapshot = await storageRef
        .ref()
        .child('profile_$postId.png')
        .putFile(_thumbnail!);
    var downloadUrl = await snapshot.ref.getDownloadURL();
    // StorageUploadTask uploadTask = storageRef.child('profile_$postId.png').putFile(_thumbnail!);
    // StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    // String? downloadUrl = await (storageSnap.ref.getDownloadURL() as FutureOr<String?>);

    setState(() {
      albumArtUrl = downloadUrl;
    });
    print("done");

    return downloadUrl;
  }

  void uploadVideo() {
    if (_videoFile == null) {
      showThumbnailDialog('Video');
      return;
    }

    if (_thumbnail == null) {
      showThumbnailDialog('Thumbnail');
      return;
    }
    uploadVideoToFb().then((value) {
      createVideoInFireStore(
          title: _titleController.text,
          description: _descriptionController.text,
          content: videoUrl,
          albumArt: albumArtUrl);
    });
  }

  Future createVideoInFireStore(
      {String? title,
      String? description,
      String? content,
      String? albumArt}) async {
    String postId = Uuid().v4();
    try {
      await postsRef
          .doc(widget.currentUser!.id)
          .collection('userPosts')
          .doc(postId)
          .set({
        'postId': postId,
        'ownerId': widget.currentUser!.id,
        'username': widget.currentUser!.username,
        'title': title,
        'type': 'VIDEO',
        'description': description,
        'content': content,
        'timestamp': timestamp,
        'likes': {},
        'mediaUrl': albumArt,
      }).then((value) {
        setState(() {
          uploadText = "Video Uploaded!";
          videoUploadinProgress = false;
        });

        succesDialog();
      });
    } catch (e) {
      print(e);
    }
  }

  _showToast({required title, color, icon}) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
          ),
          SizedBox(
            width: 12.0,
          ),
          Text(
            title,
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
