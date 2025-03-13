// import 'dart:convert';
// import 'dart:io';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:global_ios/screens/login.dart';
// import 'package:image_picker/image_picker.dart';

// class BlogView extends StatefulWidget
// {
// 	final String postId;
// 	final String ownerId;
// 	final String username;
// 	final String location;
// 	final String description;
// 	final String mediaUrl;
// 	final String title;
// 	final String content;
// 	final String type;
// 	final dynamic likes;

//   	BlogView(
//     {
// 		this.content = "",
// 		this.postId = "",
// 		this.ownerId = "",
// 		this.title = "",
// 		this.type = "",
// 		this.description = "",
// 		this.likes,
// 		this.location = "",
// 		this.mediaUrl = "",
// 		this.username = ""
// 	});

// 	@override
// 	_BlogViewState createState() => _BlogViewState();
// }

// class _BlogViewState extends State<BlogView>
// {
// 	@override
// 	void initState()
// 	{
// 		print("i am here");
// 		setState(() {});
// 		super.initState();
// 	}

//   	deletePost() async
// 	{
// 		// delete post itself
// 		postsRef.doc(widget.ownerId).collection('userPosts').doc(widget.postId).get().then((doc)
// 		{
// 			if (doc.exists)
// 			{
// 				doc.reference.delete();
// 			}
// 		});
// 		// delete uploaded image for the post
// 		// then delete all activity feed notifications
// 		QuerySnapshot activityFeedSnapshot = await activityFeedRef.doc(widget.ownerId).collection('feedItems').where('postId', isEqualTo: widget.postId).get();
// 		activityFeedSnapshot.docs.forEach((doc)
// 		{
// 			if (doc.exists)
// 			{
// 				doc.reference.delete();
// 			}
// 		});
// 		//  then delete all comments
// 		commentsRef.doc(widget.postId).collection('comments').get();
// 		activityFeedSnapshot.docs.forEach((doc)
// 		{
// 			if (doc.exists)
// 			{
// 				doc.reference.delete();
// 			}
// 		});
//   	}

// 	@override
// 	Widget build(BuildContext context)
// 	{
// 		return Scaffold
// 		(
// 			appBar: AppBar
// 			(
// 				centerTitle: true,
// 				title: Text("BLOG"),
// 				actions: <Widget>
// 				[
// 					FlatButton(
// 					  onPressed: () {
// 					    showDialog(
// 					        context: context,
// 					        builder: (BuildContext context) {
// 					          return AlertDialog(
// 					            title: Text("Are You Sure ?"),
// 					            content: Text("You Want To Delete ?"),
// 					            actions: <Widget>[
// 					              FlatButton(
// 					                onPressed: () => Navigator.of(context).pop(),
// 					                child: Text("NO"),
// 					              ),
// 					              FlatButton(
// 					                onPressed: () {
// 					                  Navigator.of(context).pop();
// 					                  deletePost();
// 					                  Navigator.pop(context);
// 					                },
// 					                child: Text("Yes"),
// 					              )
// 					            ],
// 					          );
// 					        },
// 					        );
// 					  },
// 					  child: Text(
// 					    "Delete",
// 					    style: TextStyle(
// 					        fontSize: 18,
// 					        color: Colors.white,
// 					        fontWeight: FontWeight.w600),
// 					  ),
// 					)
// 				],
// 			),
// 			body: GestureDetector
// 			(
// 				child: Container
// 				(
// 					height: double.infinity,
// 					margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
// 					child: Column
// 					(
// 						mainAxisSize: MainAxisSize.min,
// 						crossAxisAlignment: CrossAxisAlignment.center,
// 						children: <Widget>
// 						[
// 							Text
// 							(
// 								widget.title,
// 								style: TextStyle
// 								(
// 									fontWeight: FontWeight.bold,
// 									fontSize: 20,
// 									color: Colors.blueGrey[700]
// 								),
// 							),
// 								//              Text(
// 								//                "$description",
// 								//                style: TextStyle(fontSize: 15, color: Colors.blueGrey),
// 								//              ),
// 							Container
// 							(
// 								height: MediaQuery.of(context).size.height - 200,
// 								child: SingleChildScrollView
// 								(
// 									scrollDirection: Axis.vertical,
// 									child: Html
// 									(
// 										data: widget.content,
// 									),
// 								),
// 							),
// 						],
// 					),
//         		),
//       		),
//     	);
//   	}
// }

// --------------------

import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:global_ios/screens/login.dart';
import 'package:image_picker/image_picker.dart';

class BlogView extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final String title;
  final String content;
  final String type;
  final dynamic likes;

  BlogView(
      {this.content = "",
      this.postId = "",
      this.ownerId = "",
      this.title = "",
      this.type = "",
      this.description = "",
      this.likes,
      this.location = "",
      this.mediaUrl = "",
      this.username = ""});

  @override
  _BlogViewState createState() => _BlogViewState();
}

class _BlogViewState extends State<BlogView> {
  @override
  void initState() {
    print("i am here");
    setState(() {});
    super.initState();
  }

  deletePost() async {
    // delete post itself
    postsRef
        .doc(widget.ownerId)
        .collection('userPosts')
        .doc(widget.postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete uploaded image for the post
    // then delete all activity feed notifications
    QuerySnapshot activityFeedSnapshot = await activityFeedRef
        .doc(widget.ownerId)
        .collection('feedItems')
        .where('postId', isEqualTo: widget.postId)
        .get();
    activityFeedSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //  then delete all comments
    commentsRef.doc(widget.postId).collection('comments').get();
    activityFeedSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isOwnerOfBlog = currentUser!.id == widget.ownerId;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        centerTitle: true,
        title: Text("BLOG"),
        actions: <Widget>[
          if (isOwnerOfBlog)
            FlatButton(
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
                            Navigator.pop(context);
                          },
                          child: Text("Yes"),
                        )
                      ],
                    );
                  },
                );
              },
              child: Text(
                "Delete",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
            )
        ],
      ),
      body: GestureDetector(
        child: Container(
          height: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                widget.title,
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
                height: MediaQuery.of(context).size.height - 200,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Html(
                    data: widget.content,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
