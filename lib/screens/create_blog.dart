// import 'dart:convert';
// import 'dart:io';
// import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:global_ios/models/user_model.dart';
// import 'package:global_ios/screens/login.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:notustohtml/notustohtml.dart';
// import 'package:uuid/uuid.dart';
// import 'package:zefyrka/zefyrka.dart';
// import 'package:quill_delta/quill_delta.dart';

// class CreateBlog extends StatefulWidget
// {
// 	final User currentUser;

//   	CreateBlog({required this.currentUser});

// 	@override
// 	_CreateBlogState createState() => _CreateBlogState();
// }

// class _CreateBlogState extends State<CreateBlog>
// {
// 	String postId = Uuid().v4();
// 	ZefyrController _controller = ZefyrController();
// 	String html = "";
// 	FocusNode blogFocusNode = FocusNode();
// 	late Fluttertoast flutterToast;

// 	TextEditingController blogTitleController = TextEditingController();
// 	TextEditingController blogDescriptionController = TextEditingController();
// 	TextEditingController uploadBlogController = TextEditingController();

// 	@override
// 	void initState()
// 	{
// 		super.initState();
// 		// flutterToast = Fluttertoast(context);

// 		_loadDocument()
// 		{

// 			late Delta delta ;
// 			delta = Delta()..insert("\n");
// 			// print(delta.runtimeType);
// 			// Delta  delta = Delta;

// 			final converter = NotusHtmlCodec();

// 		// 	String html = converter.encode(delta);

// 		// 	return NotusDocument.fromDelta(html);
//     	}

// 		// final document = _loadDocument();
// 		// uploadBlogController = ZefyrController(document);
// 	}

//   	bool isUploading = false;

//   	Future createBlogInFireStore({title, description, content}) async
// 	{
//     	try
// 		{
//      	 	await postsRef.doc(widget.currentUser.id).collection('userPosts').doc(postId).set(
// 			{
// 				'postId': postId,
// 				'ownerId': widget.currentUser.id,
// 				'username': widget.currentUser.username,
// 				'title': title,
// 				'type': 'BLOG',
// 				'description': description,
// 				'content': content,
// 				'timestamp': timestamp,
// 				'likes': {},
// 				'mediaUrl': '${widget.currentUser.photoUrl}'
//       		});
//     	}
// 		catch (e)
// 		{
//       		print(e);
//     	}
//   	}

//   	bool imageIsUploadding = false;

// 	@override
// 	Widget build(BuildContext context)
// 	{
// 		return Scaffold
// 		(
// 			resizeToAvoidBottomInset: true,
// 			appBar: AppBar
// 			(
// 				actions: <Widget>
// 				[
// 					TextButton
// 					(
// 						child: Text
// 						(
// 							"POST",
// 							style: const TextStyle(color: Colors.white, letterSpacing: 2, fontWeight: FontWeight.bold),
// 						),
// 						onPressed: () async
// 						{
// 							if (this.imageIsUploadding) return;
// 							setState(()
// 							{
// 								this.imageIsUploadding = true;
// 							});

// 							const converter = const NotusHtmlCodec();

// 							// String html = converter.encode(_controller.document);
// 							String html = uploadBlogController.text.toString();
// 							this.html = html;
// 							print(this.html);
// 							try
// 							{
// 								createBlogInFireStore
// 								(
// 									title: '${blogTitleController.text}',
// 									// description: uploadBlogController.text,
// 									content: html,
// 								).whenComplete(() => Navigator.of(context).pop());
// 							}
// 							catch(e)
// 							{
// 								print(e.toString());
// 								print("ERROR");
// 							}
// 							_showToast();

// 							setState(() {});
// 						},
//           			)
//         		],
// 				centerTitle: true,
// 				title: Text("Create Blog"),
//       		),
//       		body: Stack
// 			(
//         		children: <Widget>
// 				[
// 					SingleChildScrollView
// 					(
// 						child: Container
// 						(
// 							height: MediaQuery.of(context).size.height,
// 							margin: EdgeInsets.only(top: 20, left: 20, right: 20),
// 							child: SingleChildScrollView
// 							(
// 								child: Column
// 								(
// 									mainAxisAlignment: MainAxisAlignment.start,
// 									children: <Widget>
// 									[
// 										Container
// 										(
// 											padding: EdgeInsets.only(top: 0),
// 											child: TextField
// 											(
// 												controller: blogTitleController,
// 												decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Title"),
// 											),
// 										),
// 										SizedBox(height: 10),
// 										// TextField
// 										// (
// 										// 	controller: blogDescriptionController,
// 										// 	decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Description"),
// 										// ),
// 										// SizedBox(height: 10),
// 										Stack
// 										(
// 											alignment: Alignment.topCenter,
// 											children: <Widget>
// 											[
// 												Container
// 												(
// 													height: MediaQuery.of(context).size.height / 2.4,
// 													width: MediaQuery.of(context).size.width - 40,
// 													decoration: BoxDecoration
// 													(
// 														borderRadius: BorderRadius.circular(10),
// 														border: Border.all
// 														(
// 															color: blogFocusNode.hasFocus
// 																? Colors.deepPurple
// 																: Colors.blueGrey,
// 															width: blogFocusNode.hasFocus ? 2 : 1
// 														)
// 													),
// 													//   child: ZefyrScaffold(
// 													// child: ZefyrEditor
// 													child: TextFormField
// 													(
// 														autofocus: false,
// 														//imageDelegate: MyAppZefyrImageDelegate(),
// 														// padding: EdgeInsets.all(10),
// 														controller: uploadBlogController,
// 														focusNode: blogFocusNode,
// 													),
// 													// ),
// 													// child: Align
// 													// (
// 													// 	alignment: Alignment.bottomCenter,
// 													// 	child: Column
// 													// 	(
// 													// 		children:
// 													// 		[
// 													// 			ZefyrToolbar.basic(controller: _controller),
// 													// 			Expanded
// 													// 			(
// 													// 				child: ZefyrEditor
// 													// 				(
// 													// 					controller: _controller,
// 													// 					focusNode: blogFocusNode,
// 													// 				),
// 													// 			)
// 													// 		]
// 													// 	)
// 													// )
// 												),

// 												blogFocusNode.hasFocus
// 												? Container()
// 												: Container
// 												(
// 													margin: EdgeInsets.symmetric(vertical: 20),
// 													child: Text
// 													(
// 														"Write Blog Here ...",
// 														style: TextStyle
// 														(
// 															fontSize: 25,
// 															fontStyle: FontStyle.italic,
// 															color: Colors.blueGrey
// 														)
// 													)
// 												),
// 											]
// 										)
// 									]
// 								)
// 							)
// 						)
// 					),
// 					this.imageIsUploadding
// 					? Container
// 					(
// 						child: Center
// 						(
// 							child: CircularProgressIndicator(),
// 						),
//                 	)
//               		: Container()
//         		]
//       		)
//     	);
//   	}

//   	_showToast()
// 	{
//     	Widget toast = Container
// 		(
// 			padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
// 			decoration: BoxDecoration
// 			(
// 				borderRadius: BorderRadius.circular(25.0),
// 				color: Colors.green,
// 			),
// 			child: Row
// 			(
// 				mainAxisSize: MainAxisSize.min,
// 				children:
// 				[
// 					Icon(Icons.check, color: Colors.white),
// 					SizedBox(width: 12.0),
// 					Text( "Blog is Uploaded", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
// 				],
// 			),
// 		);

//     	return Fluttertoast.showToast
// 		(
// 			msg: "Blog is Uploaded",
// 			//child: toast,
// 			gravity: ToastGravity.BOTTOM,
// 			//toastDuration: Duration(seconds: 2),
//     	);
//   	}
// }

// class MyAppZefyrImageDelegate implements ZefyrImageDelegate
// {
// 	String postId = Uuid().v4();
// 	var downloadUrl = "";
// 	final picker = ImagePicker();

// 	@override
// 	Future<String> pickImage(ImageSource source) async
// 	{
// 		final file = await picker.pickImage(source: source);
// 		if (file == null) return "null";

// 		File x;
// 		x = file as File;
// 		UploadTask uploadTask =  storageRef.ref().child('post_$postId.jpg').putFile(x);
// 		uploadTask.then((res)
// 		{
// 			downloadUrl = res.ref.getDownloadURL() as String;
// 		});
// 		return downloadUrl;

// 		// StorageUploadTask uploadTask = storageRef.child('post_$postId.jpg').putFile(file);
// 		// StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
// 		// downloadUrl = await storageSnap.ref.getDownloadURL();
// 		// return downloadUrl;
// 	}

// 	@override
// 	Widget buildImage(BuildContext context, String key)
// 	{
// 		//final file = File.fromUri(Uri.parse(key));
// 		//final image = FileImage(file);

// 		return FancyShimmerImage
// 		(
// 			boxFit: BoxFit.contain,
// 			imageUrl: key,
// 			shimmerBaseColor: Colors.white,
// 			shimmerHighlightColor: Colors.blueGrey,
// 			shimmerBackColor: Colors.black,
//     	);
//   	}

//   	@override
//   	ImageSource get cameraSource => ImageSource.camera;

// 	@override
// 	ImageSource get gallerySource => ImageSource.gallery;
// }

// class ZefyrImageDelegate
// {
// }

// -------------------
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:global_ios/models/user_model.dart';
import 'package:global_ios/screens/login.dart';
import 'package:uuid/uuid.dart';
import 'package:html_editor_enhanced/html_editor.dart';
class CreateBlog extends StatefulWidget {
  final User currentUser;
  CreateBlog({required this.currentUser});
  @override
  _CreateBlogState createState() => _CreateBlogState();
}
class _CreateBlogState extends State<CreateBlog> {
  String postId = Uuid().v4();
  String html = "";
  FocusNode blogFocusNode = FocusNode();
  late Fluttertoast flutterToast;
  TextEditingController blogTitleController = TextEditingController();
  TextEditingController blogDescriptionController = TextEditingController();
  TextEditingController uploadBlogController = TextEditingController();
  final HtmlEditorController controller = HtmlEditorController();
  String htmltext = '';
  Future getHtmlText() async {
    String text = await controller.getText();
    setState(() {
      htmltext = text;
    });
    print(htmltext);
  }
  bool isUploading = false;
  Future createBlogInFireStore({title, description, content}) async {
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
        'type': 'BLOG',
        'description': description,
        'content': content,
        'timestamp': timestamp,
        'likes': {},
        'mediaUrl': '${widget.currentUser.photoUrl}'
      });
    } catch (e) {
      print(e);
    }
  }
  bool imageIsUploadding = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        actions: <Widget>[
          TextButton(
            child: const Text(
              "POST",
              style: TextStyle(
                  color: Colors.white,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              await getHtmlText();
              if (this.imageIsUploadding) return;
              setState(() {
                this.imageIsUploadding = true;
              });
              html = htmltext;
              // this.html = html;
              print(this.html);
              try {
                createBlogInFireStore(
                  title: '${blogTitleController.text}',
                  // description: uploadBlogController.text,
                  content: html,
                ).whenComplete(() {
                  Navigator.of(context).pop();
                  _showToast();
                });
              } catch (e) {
                print(e.toString());
                print("ERROR");
              }
              // ------------------------------------
              // _showToast();
              setState(() {});
            },
          )
        ],
        centerTitle: true,
        title: const Text("Create Blog"),
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(top: 0),
                      child: TextField(
                        controller: blogTitleController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), labelText: "Title"),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration:
                          BoxDecoration(border: Border.all(color: Colors.grey)),
                      child: HtmlEditor(
                        controller: controller, //required
                        htmlEditorOptions: const HtmlEditorOptions(
                          autoAdjustHeight: false,
                          adjustHeightForKeyboard: true,
                          spellCheck: true,
                          hint: "Your text here...",
                        ),
                        otherOptions: OtherOptions(
                          height: MediaQuery.of(context).size.height * .7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          imageIsUploadding
              ? const Center(
                  child: SpinKitThreeBounce(
                  color: Colors.grey,
                  size: 25,
                )
                  //  CircularProgressIndicator(),
                  )
              : Container()
        ],
      ),
    );
  }

// ---------------------toast----------------------------------

  _showToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.green,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check, color: Colors.white),
          SizedBox(width: 12.0),
          Text("Blog is Uploaded",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );

    return Fluttertoast.showToast(
      msg: "Blog is Uploaded",
      //child: toast,
      gravity: ToastGravity.BOTTOM,
      //toastDuration: Duration(seconds: 2),
    );
  }
}
