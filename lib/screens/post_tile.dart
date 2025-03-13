import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:global_ios/screens/blog_view.dart';
import 'package:global_ios/screens/podcast_fullscreen.dart';
import 'package:global_ios/screens/post_screen.dart';
import 'package:global_ios/screens/posts.dart';
import 'package:global_ios/screens/video_screen.dart';
import 'dart:math';

import 'package:image/image.dart';

class PostTile extends StatelessWidget {
  final Post post;

  PostTile(this.post);

  showPost(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostScreen(
                  postId: post.postId,
                  userId: post.ownerId,
                  type: post.type,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => post.type == "BLOG" || post.type == "PODCAST"
          ? post.type == "BLOG"
              ? Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => BlogView(
                        type: post.type,
                        title: post.title,
                        username: post.username,
                        ownerId: post.ownerId,
                        location: post.location,
                        likes: post.likes!,
                        description: post.description,
                        postId: post.postId,
                        mediaUrl: post.mediaUrl,
                        content: post.content,
                      )))
              : Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PodCastFullScreen(
                            ownerId: post.ownerId,
                            postId: post.postId,
                            content: post.content,
                            title: post.title,
                            mediaUrl: post.mediaUrl,
                            description: post.description,
                          )))
          : post.type == 'VIDEO'
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VideoScreenTimeline(
                            ownerId: post.ownerId,
                            postId: post.postId,
                            content: post.content,
                            likes: post.likes,
                            title: post.title,
                            mediaUrl: post.mediaUrl,
                            description: post.description,
                          )))
              : showPost(context),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          FancyShimmerImage(imageUrl: post.mediaUrl, boxFit: BoxFit.contain),
          (post.type == "VIDEO")
              ? Center(
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                )
              : Container(),
          post.type == "BLOG" || post.type == "PODCAST"
              ? Container(
                  alignment: Alignment.center,
                  color: post.type == "BLOG"
                      ? Colors.blueGrey
                      // Colors.blue.withOpacity(0.5)
                      : Colors.blue.withOpacity(0.2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        post.type == "BLOG" ? "BLOG" : "PODCAST",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      (post.type == "BLOG" || post.type == "PODCAST")
                          ? Text(
                              (post.title == null) ? '' : post.title,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic),
                            )
                          : Container(),
                    ],
                  ))
              : Container(),
        ],
      ),
    );
  }
}
