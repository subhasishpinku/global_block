import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:global_ios/screens/login.dart';
import 'package:global_ios/screens/profile.dart';
import 'package:global_ios/utilities/appbar.dart';
import 'package:global_ios/widgets/app_service.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'post_screen.dart';

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  getActivityFeed() async {
    QuerySnapshot snapshot = await activityFeedRef
        .doc(currentUser!.id)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();
    List<ActivityFeedItem> listFeedItem = [];
    snapshot.docs.forEach((doc) {
      listFeedItem.add(ActivityFeedItem.fromDocument(doc));
      print('listFeedItem : $listFeedItem');
    });
    return listFeedItem;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        false,
        'Activity Feeds',
        false,
      ),
      body: Container(
        child: FutureBuilder(
          future: getActivityFeed(),
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return const SpinKitThreeBounce(
                color: Colors.grey,
                size: 35,
              );
              // circularProgress();
            }
            return ListView(children: snapshot.data);
          },
        ),
      ),
    );
  }

  configureMediaPreview(context) {
    GestureDetector(
      // onTap: () => showPost(context),
      child: Container(
        height: 50.0,
        width: 50.0,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(
                  "https://images.pexels.com/photos/1987301/pexels-photo-1987301.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

showProfile(BuildContext context, {profileId}) {
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => Profile(profileId)));
}

Widget? mediaPreview;
String? activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final String? username;
  final String? userId;
  final String? type;
  final String? mediaUrl;
  final String? postId;
  final String? userProfileImg;
  final String? commentData;
  final Timestamp? timestamp;

  ActivityFeedItem({
    this.username,
    this.userId,
    this.type,
    this.mediaUrl,
    this.postId,
    this.userProfileImg,
    this.commentData,
    this.timestamp,
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    Map map = doc.data() as Map;

    var postId = '';
    if (map.containsKey('postId')) {
      postId = map['postId'];
    }
    var commentData = '';
    if (map.containsKey('commentData')) {
      commentData = map['commentData'];
    }
    var mediaUrl = '';
    if (map.containsKey('mediaUrl')) {
      mediaUrl = map['mediaUrl'];
    }
    return ActivityFeedItem(
      username: doc['username'],
      userId: doc['userId'],
      type: doc['type'],
      postId: postId,
      userProfileImg: doc['userProfileImg'],
      commentData: commentData,
      timestamp: doc['timestamp'],
      mediaUrl: mediaUrl,
    );
  }

  showPost(context) {
    print(this.postId);
    print(this.userId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: postId,
          userId: appService.CurrentUSer,
        ),
      ),
    );
  }

  configureMediaPreview(context) {
    if (type == 'like' || type == 'comment') {
      mediaPreview = GestureDetector(
        onTap: () => showPost(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(mediaUrl!),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text('');
    }
    if (type == 'like') {
      activityItemText = 'liked Your post';
    } else if (type == 'follow') {
      activityItemText = 'is following you';
    } else if (type == 'comment') {
      activityItemText = 'commented $commentData';
    } else {
      activityItemText = 'Error: Unknown type $type';
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: username,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' $activityItemText',
                  ),
                ],
              ),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImg!),
          ),
          onTap: () {
            if (type == "follow") showProfile(context, profileId: userId!);
            if (type == 'like' || type == 'comment') {
              showPost(context);
            }
          },
          subtitle: Text(
            timeago.format(
              timestamp!.toDate(),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }

  showProfile(BuildContext context, {required String profileId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // ------------
        builder: (context) => Profile(profileId),
      ),
    );
  }
}
