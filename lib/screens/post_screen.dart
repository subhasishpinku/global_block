import 'package:flutter/material.dart';
import 'package:global_ios/screens/login.dart';
import 'package:global_ios/screens/posts.dart';
import 'package:global_ios/utilities/appbar.dart';
import 'package:global_ios/utilities/progress.dart';

class PostScreen extends StatelessWidget {
  final String? userId;
  final String? postId;
  final String? type;

  PostScreen({this.userId, this.postId, this.type});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: postsRef.doc(userId).collection('userPosts').doc(postId).get(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }

          if (!snapshot.data.exists) {
            return Center(
                child: Scaffold(
                    appBar: header(context, false, "Post not found", true),
                    body: ListView(children: <Widget>[
                      Container(
                        child: Text("post not found"),
                      )
                    ])));
          }
          print(snapshot.data);
          print(snapshot);

          Post post = Post.fromDocument(snapshot.data);

          return Center(
              child: Scaffold(
                  appBar: header(context, false, post.description, false),
                  body: ListView(children: <Widget>[Container(child: post)])));
        });
  }
}
