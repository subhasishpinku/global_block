// import 'dart:convert';
// import 'dart:io';

// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:global_ios/models/user_model.dart';
// import 'package:global_ios/screens/create_blog.dart';
// import 'package:global_ios/screens/login.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:notustohtml/notustohtml.dart';
// import 'package:quill_delta/quill_delta.dart';
// import 'package:uuid/uuid.dart';
// import 'package:zefyrka/zefyrka.dart';

// class EditBlog extends StatefulWidget {
//   final User? currentUser;
//   final String? postId;
//   final String? content;
//   final String? title;
//   final String? ownerid;

//   EditBlog(
//       {this.currentUser, this.postId, this.content, this.title, this.ownerid});

//   @override
//   _EditBlogState createState() => _EditBlogState();
// }

// class _EditBlogState extends State<EditBlog> {
//   late ZefyrController uploadBlogController;

//   FocusNode blogFocusNode = FocusNode();

//   TextEditingController blogTitleController = TextEditingController();
//   TextEditingController blogDescriptionController = TextEditingController();

//   @override
//   void initState() {
//     // TODO: implement initState
//     blogTitleController.text = widget.title!;
//     final converter = NotusHtmlCodec();

//     // Delta delta = converter.decode(widget.content); // Zefyr compatible Delta
//     // NotusDocument document = NotusDocument.fromDelta(delta);
//     super.initState();

//     // uploadBlogController = ZefyrController(document);
//   }

//   bool isUploading = false;

//   Future createBlogInFireStore(
//       {String? title, String? description, String? content}) async {
//     try {
//       await postsRef
//           .doc(widget.ownerid!)
//           .collection('userPosts')
//           .doc(widget.postId!)
//           .update({
//         'title': title,
//         'content': content,
//       });
//     } catch (e) {
//       print(e);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(
//         actions: <Widget>[
//           FlatButton(
//             child: Text(
//               "Update",
//               style: TextStyle(
//                   color: Colors.white,
//                   letterSpacing: 2,
//                   fontWeight: FontWeight.bold),
//             ),
//             onPressed: () async {
//               final converter = NotusHtmlCodec();

//               String html = "";
//                 //   converter.encode(uploadBlogController.document.toDelta());
//               createBlogInFireStore(
//                 title: '${blogTitleController.text}',
// //                description: '${blogDescriptionController.text}',
//                 content: html,
//               ).whenComplete(() => Navigator.of(context).pop({
//                     "content": html,
//                     "title": blogTitleController.text.toString()
//                   }));

//               print("done");
//             },
//           )
//         ],
//         centerTitle: true,
//         title: Text("Edit Blog"),
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           height: MediaQuery.of(context).size.height,
//           margin: EdgeInsets.only(top: 40, left: 20, right: 20),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: <Widget>[
//                 TextField(
//                   controller: blogTitleController,
//                   decoration: InputDecoration(
//                       border: OutlineInputBorder(), labelText: "Title"),
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
// //                TextField(
// //                  controller: blogDescriptionController,
// //                  decoration: InputDecoration(
// //                      border: OutlineInputBorder(), labelText: "Description"),
// //                ),
// //                SizedBox(
// //                  height: 10,
// //                ),
//                 Container(
//                   height: 250,
//                   width: MediaQuery.of(context).size.width - 40,
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: Colors.blueGrey, width: 1)),
//                 //   child: ZefyrScaffold(
//                 //     child: ZefyrEditor(
//                 //       autofocus: false,
//                 //       mode: ZefyrMode.edit,
//                 //       imageDelegate: MyAppZefyrImageDelegate(),
//                 //       padding: EdgeInsets.all(10),
//                 //       controller: uploadBlogController,
//                 //       focusNode: blogFocusNode,
//                 //     ),
//                 //   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class MyAppZefyrImageDelegate implements ZefyrImageDelegate {
//   String postId = Uuid().v4();
//   String? downloadUrl;
//   @override
//   Future<String?> pickImage(ImageSource source) async {
//     final file = await ImagePicker.platform.pickImage(source: source);
//     if (file == null) return null;
//     // StorageUploadTask uploadTask =
//     //     storageRef.child('post_$postId.jpg').putFile(file);
//     // StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
//     // downloadUrl = await (storageSnap.ref.getDownloadURL() as FutureOr<String?>);

//     return downloadUrl;
//   }

//   @override
//   Widget buildImage(BuildContext context, String key) {
//     //final file = File.fromUri(Uri.parse(key));
//     //final image = FileImage(file);
//     final image = NetworkImage('${downloadUrl}');
//     return Image(
//       image: image,
//     );
//   }

//   @override
//   ImageSource get cameraSource => ImageSource.camera;

//   @override
//   ImageSource get gallerySource => ImageSource.gallery;
// }

// -------------------------------

import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_ios/models/user_model.dart';
import 'package:global_ios/screens/create_blog.dart';
import 'package:global_ios/screens/login.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:notustohtml/notustohtml.dart';
// import 'package:quill_delta/quill_delta.dart';
import 'package:uuid/uuid.dart';
// import 'package:zefyrka/zefyrka.dart';
// import 'package:flutter_quill/flutter_quill.dart' hide Text;

class EditBlog extends StatefulWidget {
  final User? currentUser;
  final String? postId;
  final String? content;
  final String? title;
  final String? ownerid;

  EditBlog(
      {this.currentUser, this.postId, this.content, this.title, this.ownerid});

  @override
  _EditBlogState createState() => _EditBlogState();
}

class _EditBlogState extends State<EditBlog> {
  // -----------------------------------------
  // ZefyrController? uploadBlogController;
  // FocusNode blogFocusNode = FocusNode();

  TextEditingController blogTitleController = TextEditingController();
  TextEditingController blogDescriptionController = TextEditingController();

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   blogTitleController.text = widget.title!;
  //   // final converter = NotusHtmlCodec();
  //   // Delta delta = converter.decode(widget.content!); // Zefyr compatible Delta
  //   // NotusDocument document = NotusDocument.fromDelta(delta);
  //   super.initState();
  //   // uploadBlogController = ZefyrController(document);
  // }

  bool isUploading = false;

  Future createBlogInFireStore(
      {String? title, String? description, String? content}) async {
    try {
      await postsRef
          .doc(widget.ownerid!)
          .collection('userPosts')
          .doc(widget.postId!)
          .update({
        'title': title,
        'content': content,
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        actions: <Widget>[
          FlatButton(
            child: Text(
              "Update",
              style: TextStyle(
                  color: Colors.white,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              // final converter = NotusHtmlCodec();

              String html = "";
              //   converter.encode(uploadBlogController.document.toDelta());
              createBlogInFireStore(
                title: '${blogTitleController.text}',
//                description: '${blogDescriptionController.text}',
                content: html,
              ).whenComplete(() => Navigator.of(context).pop({
                    "content": html,
                    "title": blogTitleController.text.toString()
                  }));

              print("done");
            },
          )
        ],
        centerTitle: true,
        title: Text("Edit Blog"),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                TextField(
                  controller: blogTitleController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: "Title"),
                ),
                SizedBox(
                  height: 10,
                ),
//                TextField(
//                  controller: blogDescriptionController,
//                  decoration: InputDecoration(
//                      border: OutlineInputBorder(), labelText: "Description"),
//                ),
//                SizedBox(
//                  height: 10,
//                ),
                Container(
                  height: 250,
                  width: MediaQuery.of(context).size.width - 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blueGrey, width: 1)),
                  //   child: ZefyrScaffold(
                  //     child: ZefyrEditor(
                  //       autofocus: false,
                  //       mode: ZefyrMode.edit,
                  //       imageDelegate: MyAppZefyrImageDelegate(),
                  //       padding: EdgeInsets.all(10),
                  //       controller: uploadBlogController,
                  //       focusNode: blogFocusNode,
                  //     ),
                  //   ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class MyAppZefyrImageDelegate implements ZefyrImageDelegate {
//   String postId = Uuid().v4();
//   String? downloadUrl;
//   @override
//   Future<String?> pickImage(ImageSource source) async {
//     final file = await ImagePicker.platform.pickImage(source: source);
//     if (file == null) return null;
//     // StorageUploadTask uploadTask =
//     //     storageRef.child('post_$postId.jpg').putFile(file);
//     // StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
//     // downloadUrl = await (storageSnap.ref.getDownloadURL() as FutureOr<String?>);

//     return downloadUrl;
//   }

//   @override
//   Widget buildImage(BuildContext context, String key) {
//     //final file = File.fromUri(Uri.parse(key));
//     //final image = FileImage(file);
//     final image = NetworkImage('${downloadUrl}');
//     return Image(
//       image: image,
//     );
//   }

//   @override
//   ImageSource get cameraSource => ImageSource.camera;

//   @override
//   ImageSource get gallerySource => ImageSource.gallery;
// }
