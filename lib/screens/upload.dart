import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:global_ios/models/user_model.dart';
import 'package:global_ios/screens/create_blog.dart';
import 'package:global_ios/screens/create_podcast.dart';
import 'package:global_ios/screens/createpod.dart';
import 'package:global_ios/screens/login.dart';
import 'package:global_ios/screens/upload_video.dart';
import 'package:global_ios/utilities/progress.dart';
import 'package:zefyrka/zefyrka.dart';
import 'home.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as Im;

class Upload extends StatefulWidget {
  final User currentUser;

  Upload({required this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload>
    with AutomaticKeepAliveClientMixin<Upload> {
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();
  File file = File("");
  // XFile file = XFile("");
  bool isUploading = false;
  String postId = Uuid().v4();
  final picker = ImagePicker();
  ZefyrController? uploadBlogController;
  FocusNode blogFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  handleTakePhoto() async {
    Navigator.pop(context);
    final XFile? file = await picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );

    setState(() {
      this.file = File(file!.path);
    });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    print(file?.path.toString());
    setState(() {
      this.file = File(file!.path);
      print(this.file);
    });
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(title: Text('Create Post'), children: <Widget>[
            SimpleDialogOption(
              child: Text('Photo with Camera'),
              onPressed: handleTakePhoto,
            ),
            SimpleDialogOption(
              child: Text('Image from Gallery'),
              onPressed: handleChooseFromGallery,
            ),
            SimpleDialogOption(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            )
          ]);
        });
  }

  Container buildSplashScreen() {
    return Container(
        color: Theme.of(context).accentColor.withOpacity(0.2),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/images/upload.png', height: 260.0),
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  child: Text(
                    'Upload Image',
                    style: TextStyle(color: Colors.white, fontSize: 22.0),
                  ),
                  color: Colors.teal,
                  onPressed: () => selectImage(context),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Text(
                      'Write Blog',
                      style: TextStyle(color: Colors.white, fontSize: 22.0),
                    ),
                    color: Colors.teal,
                    onPressed: () {
                      null;
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              CreateBlog(currentUser: widget.currentUser)));
                    }),
              ),
              // Padding(
              //   padding: EdgeInsets.only(top: 20.0),
              //   child: RaisedButton(
              //     shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(10.0)),
              //     child: Text(
              //       'Create Podcast',
              //       style: TextStyle(color: Colors.white, fontSize: 22.0),
              //     ),
              //     color: Colors.teal,
              //     // onPressed: () => null,
              //     onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              //         builder: (context) =>
              //             CreatePodcast(currentUser: widget.currentUser))),
              //   ),
              // ),

              // -----------------------------------------------

              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: const Text(
                    'Create Podcast',
                    style: TextStyle(color: Colors.white, fontSize: 22.0),
                  ),
                  color: Colors.teal,
                  // onPressed: () => null,
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          CreatePod(currentUser: widget.currentUser))),
                ),
              ),

              // _____________________________________________________________

              Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Text(
                        'Upload Video',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.0,
                        ),
                      ),
                      color: Colors.teal,
                      onPressed: () {
                        // null;
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                UploadVideo(currentUser: widget.currentUser)));
                      }))
            ]));
  }

  clearImage() {
    print(file);
    setState(() {
      file = File("");
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image? imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/image_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile!, quality: 85));
    setState(() {
      file = compressedImageFile;
      print("FILE COMPRESSED");
    });
  }

  Future<String> uploadImage(imageFile) async {
    String downloadUrl = "";

    var snapshot =
        await storageRef.ref().child('post_$postId.jpg').putFile(imageFile);
    downloadUrl = await snapshot.ref.getDownloadURL();
    setState(() {
      print(downloadUrl);
      print("downloadUrl");
      // imageUrl = downloadUrl;
    });

    return downloadUrl;
  }

  createPostInFirestore({mediaUrl, location, description}) {
    postsRef
        .doc(widget.currentUser.id)
        .collection('userPosts')
        .doc(postId)
        .set({
      'postId': postId,
      'ownerId': widget.currentUser.id,
      'username': widget.currentUser.username,
      'mediaUrl': mediaUrl,
      'type': 'POST',
      'title': 'image',
      'content': 'image',
      'description': description,
      'location': location,
      'timestamp': timestamp,
      'likes': {},
    });
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });

    await compressImage();
    print(file.toString() + " HANDLE SUBMIT FUNCTION");
    String mediaUrl = await uploadImage(file);

    print(mediaUrl.length.toString() + " MEDIA URL");

    createPostInFirestore(
        mediaUrl: mediaUrl,
        location: locationController.text,
        description: captionController.text);

    captionController.clear();
    locationController.clear();

    setState(() {
      file = File("");
      isUploading = false;
      postId = Uuid().v4();

      print(postId);
    });
  }

  Scaffold buildUploadForm() {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white70,
            leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                onPressed: clearImage),
            title: const Text(
              'Caption',
              style: TextStyle(color: Colors.black),
            ),
            actions: [
              FlatButton(
                  onPressed: isUploading ? null : () => handleSubmit(),
                  child: const Text('Post',
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0)))
            ]),
        body: ListView(children: <Widget>[
          isUploading ? linearProgress() : const Text(''),
          Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(file),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: captionController,
                decoration: const InputDecoration(
                  hintText: 'Write a caption...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: const Icon(
              Icons.pin_drop,
              color: Colors.blueGrey,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  hintText: 'Where was this photo taken?',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
              width: 200.0,
              height: 100.0,
              alignment: Alignment.center,
              child: RaisedButton.icon(
                onPressed: getUserLocation,
                icon: Icon(
                  Icons.my_location,
                  color: Colors.white,
                ),
                label: const Text(
                  'Use Current Location',
                  style: TextStyle(color: Colors.white),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                color: Colors.blue,
              ))
        ]));
  }

  Future<void> getUserLocation() async {
    var permission = await GeolocatorPlatform.instance.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await GeolocatorPlatform.instance.requestPermission();
    }

    // Position position =
    var lat;
    var lon;

    await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.lowest,
    ).then((Position position) {
      setState(() {
        lat = position.latitude;
        lon = position.longitude;
      });
    }).catchError((onError) {
      print("error: $onError");
    });

    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);

    setState(() {
      locationController.text =
          '${placemarks[0].locality}, ${placemarks[0].country}';
      print(lat);
    });
    // 	getUserLocation() async
    // {
    // Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // List<Placemark> placemarks = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);

    // Placemark placemark = placemarks[0];
    // String completeAddress = '${placemark.subThoroughfare} ${placemark.thoroughfare}, ${placemark.subLocality} ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea},${placemark.postalCode},${placemark.country}';

    // print(completeAddress);
    // String formattedAddress = '${placemark.locality},${placemark.country}';
    // locationController.text = formattedAddress;
  }

  bool get wantKeepAlive => true;
  Fluttertoast? flutterToast;

  @override
  Widget build(BuildContext context) {
    // super.build(context);

    return file.path.isEmpty ? buildSplashScreen() : buildUploadForm();
    // return buildSplashScreen();
  }
}
