// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:global_ios/models/user_model.dart';
// import 'package:global_ios/screens/activity_feeds.dart';
// import 'package:global_ios/screens/login.dart';
// import 'package:global_ios/screens/posts.dart';
// import 'package:global_ios/utilities/progress.dart';

// final postsRef = FirebaseFirestore.instance.collection('posts');

// class Search extends StatefulWidget
// {
// 	final User currentUser;

//   	Search({required this.currentUser});

// 	@override
// 	_SearchState createState() => _SearchState();
// }

// class _SearchState extends State<Search> with AutomaticKeepAliveClientMixin<Search>
// {
// 	TextEditingController searchController = TextEditingController();
// 	List<DocumentSnapshot> rowPosts = [];
// 	List<DocumentSnapshot> podCastRowPosts = [];
// 	List<DocumentSnapshot> videoRowPosts = [];

// 	List<DocumentSnapshot> blogRowPosts = [];
// 	List searchResultsFuture = [];
// 	List<User> user = [];
// 	String searchQuery = "";
// 	late FirebaseFirestore db;

// 	@override
//   	void initState()
// 	{
// 		// print("INIT");
// 		super.initState();
// 		searchHandle();
// 		getFollowing();
// 		searchPodCast();
// 		searchBlog();
// 		searchVideo();
// 	}

// 	getTimeline() async
// 	{
//     	QuerySnapshot snapshot = await timelineRef.doc(this.widget.currentUser.id).collection('timelinePosts').orderBy('timestamp', descending: true).get();
//     	rowPosts = snapshot.docs;

//     	setState(() {});
//   	}

//   	searchHandle() async
// 	{
//     	QuerySnapshot snapshot = await usersRef.get();

// 		user.clear();
// 		for (var i in snapshot.docs)
// 		{
// 			if (i != currentUser.id)
// 			{
// 				var userObj = User
// 				(
// 					id: i.get('id'),
// 					displayName: i.get('displayName'),
// 					username: i.get('username'),
// 					photoUrl: i.get('photoUrl'),
// 				);

// 				setState(()
// 				{
// 					user.add(userObj);
// 				});
// 			}
// 		}
// 	}

// 	List<User> tmpuser = [];
// 	bool isSearch = false;
// 	List<String> followingList = [];

//   	getFollowing() async
// 	{
//     	QuerySnapshot snapshot = await followingRef.doc(currentUser.id).collection('userFollowing').get();

//     	setState(()
// 		{
//       		followingList = snapshot.docs.map((doc) => doc.id).toList();
//     	});
//   	}

//   	handleSearch(String query)
// 	{
//     	setState(()
// 		{
//       		this.searchQuery = query;
//     	});

//     	tmpuser.clear();

//     	for (var i in user)
// 		{
//       		if (i.displayName.toLowerCase().contains(query.toLowerCase()) || i.username.toLowerCase().contains(query.toLowerCase()))
// 			{
//         		setState(()
// 				{
//           			tmpuser.add(i);
//         		});
//       		}
//     	}
//   	}

//   	clearSearch()
// 	{
//     	searchController.clear();
//   	}

// 	AppBar buildSearchField()
// 	{
//     	return AppBar(
//       backgroundColor: Colors.white,
//       bottom: new TabBar(
//           indicatorColor: Colors.pinkAccent[100],
//           labelColor: Colors.pinkAccent[100],
//           indicatorWeight: 0.5,
//           unselectedLabelColor: Colors.grey[400],
//           tabs: [
//             new Tab(
//               text: 'User',
//             ),
//             new Tab(
//               text: 'PodCast',
//             ),
//             new Tab(text: 'Blog'),
//             Tab(text: 'Video')
//           ]),
//       title: TextFormField(
//         controller: searchController,
//         decoration: InputDecoration(
//           border: InputBorder.none,
//           hintText: 'Search for a user...',
//           filled: true,
//           prefixIcon: Icon(
//             Icons.search,
//             size: 28.0,
//           ),
//           suffixIcon: isSearch && searchController.text.isNotEmpty
//               ? IconButton(
//                   icon: Icon(Icons.clear),
//                   onPressed: clearSearch,
//                 )
//               : Container(),
//         ),
//         onFieldSubmitted: (value) {
//           if (value.isEmpty) {
//             setState(() {
//               isSearch = false;
//             });
//             searchHandle();
//           } else {
//             setState(() {
//               isSearch = true;
//             });
//             handleSearch(value);
//           }
//         },
//         onChanged: (value) {
//           if (mounted) {
//             setState(() {
//               this.searchQuery = value;
//             });
//           }
//           if (value.isEmpty) {
//             setState(() {
//               isSearch = false;
//             });
//             searchHandle();
//           } else {
//             setState(() {
//               isSearch = true;
//             });
//             handleSearch(value);
//           }
//         },
//       ),
//     );
//   }

//   Container buildNoContent() {
//     final Orientation orientation = MediaQuery.of(context).orientation;
//     return Container(
//       child: Center(
//         child: ListView(
//           shrinkWrap: true,
//           children: <Widget>[
//             Image.asset(
//               'assets/images/search.png',
//               height: orientation == Orientation.portrait ? 300.0 : 200.0,
//             ),
//             Text(
//               'Find Users',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontStyle: FontStyle.italic,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 60.0,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   buildUsersToFollow() {
//     return StreamBuilder(
//       stream:
//           usersRef.orderBy('timestamp', descending: true).limit(30).snapshots(),
//       builder: (context, AsyncSnapshot snapshot) {
//         if (!snapshot.hasData) {
//           return circularProgress();
//         }
//         List<UserResult> userResults = [];
//         snapshot.data.doc.forEach((doc) {
//           User user = User.fromDocument(doc);
//           final bool isAuthUser = currentUser.id == user.id;
//           final bool isFollowingUser = followingList.contains(user.id);
//           // remove auth user from recommended list
//           if (isAuthUser) {
//             return;
//           } else if (isFollowingUser) {
//             return;
//           } else {
//             UserResult userResult = UserResult(user);
//             userResults.add(userResult);
//           }
//         });
//         return SingleChildScrollView(
//           child: Container(
//             color: Theme.of(context).accentColor.withOpacity(0.2),
//             child: Column(
//               children: <Widget>[
//                 Container(
//                   padding: EdgeInsets.all(12.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       Icon(
//                         Icons.person_add,
//                         color: Theme.of(context).primaryColor,
//                         size: 30.0,
//                       ),
//                       SizedBox(
//                         width: 8.0,
//                       ),
//                       Text(
//                         "Users to Follow",
//                         style: TextStyle(
//                           color: Theme.of(context).primaryColor,
//                           fontSize: 30.0,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Column(children: userResults),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   buildUserSearchResults() {
//     if (isSearch) {
//       return ListView.builder(
//         itemBuilder: (context, index) {
//           return GestureDetector(
//             onTap: () =>
//                 showProfile(context, profileId: "${tmpuser[index].id}"),
//             child: Container(
//               margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
//               decoration: BoxDecoration(
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black26,
//                       offset: Offset(4, 4),
//                       blurRadius: 10,
//                     ),
//                   ],
//                   borderRadius: BorderRadius.circular(10)),
//               child: ListTile(
//                 title: Text("${tmpuser[index].displayName}"),
//                 subtitle: Text("${tmpuser[index].username}"),
//                 leading: CircleAvatar(
//                   backgroundImage: NetworkImage("${tmpuser[index].photoUrl}"),
//                 ),
//               ),
//             ),
//           );
//         },
//         itemCount: tmpuser.length,
//       );
//     } else {
//       return ListView.builder(
//         itemBuilder: (context, index) {
//           return GestureDetector(
//             onTap: () => showProfile(context, profileId: "${user[index].id}"),
//             child: Container(
//               margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
//               decoration: BoxDecoration(
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black26,
//                       offset: Offset(4, 4),
//                       blurRadius: 10,
//                     ),
//                   ],
//                   borderRadius: BorderRadius.circular(10)),
//               child: ListTile(
//                 title: Text("${user[index].displayName}"),
//                 subtitle: Text("${user[index].username}"),
//                 leading: CircleAvatar(
//                   backgroundImage: NetworkImage("${user[index].photoUrl}"),
//                 ),
//               ),
//             ),
//           );
//         },
//         itemCount: user.length,
//       );
//     }
//   }

// 	buildPodCastTimeline()
//   	{
//     	if (podCastRowPosts == null)
// 		{
//       		return circularProgress();
//     	}
// 		else if (podCastRowPosts.isEmpty)
// 		{
//       		return buildUsersToFollow();
//     	}
// 		else
// 		{
//       		return ListView.builder
// 			(
// 				itemCount: podCastRowPosts.length,
// 				itemBuilder: (BuildContext context, int i)
// 				{
// 					return Container
// 					(
// 						child: isSearch ? podCastRowPosts[i]["title"].toString().toLowerCase().indexOf(searchQuery.toLowerCase()) != -1
// 							? Post.fromDocument(podCastRowPosts[i])
// 							: Container()
//                   		: Post.fromDocument(podCastRowPosts[i]),
//             		);
//           		}
// 			);
//     	}
//   	}

//   buildVideoTimeline() {
//     if (this.videoRowPosts == null) {
//       return circularProgress();
//     } else if (this.videoRowPosts.isEmpty) {
//       return buildUsersToFollow();
//     } else {
//       return ListView.builder(
//           itemCount: this.videoRowPosts.length,
//           itemBuilder: (BuildContext context, int i) {
//             return Container(
//               child: isSearch
//                   ? (this
//                               .videoRowPosts[i]["title"]
//                               .toString()
//                               .toLowerCase()
//                               .indexOf(this.searchQuery.toLowerCase()) !=
//                           -1
//                       ? Post.fromDocument(this.videoRowPosts[i])
//                       : Container())
//                   : Post.fromDocument(this.videoRowPosts[i]),
//             );
//           });
//     }
//   }

//   buildBlogCastTimeline() {
//     if (this.blogRowPosts == null) {
//       return circularProgress();
//     } else if (this.blogRowPosts.isEmpty) {
//       return buildUsersToFollow();
//     } else {
//       return ListView.builder(
//           itemCount: this.blogRowPosts.length,
//           itemBuilder: (BuildContext context, int i) {
//             return Container(
//               child: isSearch
//                   ? (this
//                               .blogRowPosts[i]["title"]
//                               .toString()
//                               .toLowerCase()
//                               .indexOf(this.searchQuery.toLowerCase()) !=
//                           -1
//                       ? Post.fromDocument(this.blogRowPosts[i])
//                       : Container())
//                   : Post.fromDocument(this.blogRowPosts[i]),
//             );
//           });
//     }
//   }

//   searchVideo() async {
//     FirebaseFirestore db =
//         FirebaseFirestore.instance.collection("posts").firestore;

//     this.videoRowPosts = (await db
//             .collectionGroup("userPosts")
//             .where("type", isEqualTo: "VIDEO")
//             .get())
//         .docs;
//     setState(() {});
//   }

//   searchPodCast() async
//   {
// 	  FirebaseFirestore db = FirebaseFirestore.instance.collection("posts").firestore;

//     this.podCastRowPosts = (await db.collectionGroup("userPosts").where("type", isEqualTo: "PODCAST").get()).docs;
//     setState(()
// 	{
// 	});
//   }

//   searchBlog() async {
//     FirebaseFirestore db =
//         FirebaseFirestore.instance.collection("posts").firestore;

//     this.blogRowPosts = (await db
//             .collectionGroup("userPosts")
//             .where("type", isEqualTo: "BLOG")
//             .get())
//         .docs;
//     setState(() {});
//   }

//   buildPodCastSearch() {
// //    this.searchPodCast();

// //    this.db.app.
//     return Container(
//       child: buildPodCastTimeline(),
//       height: MediaQuery.of(context).size.height,
//       color: Colors.white,
//     );
//   }

//   buildVideoSearch() {
// //    this.searchPodCast();

// //    this.db.app.
//     print("i am called");
//     return Container(
//       child: buildVideoTimeline(),
//       height: MediaQuery.of(context).size.height,
//       color: Colors.white,
//     );
//   }

//   buildBlogSearch() {
//     return Container(
//       child: buildBlogCastTimeline(),
//       height: MediaQuery.of(context).size.height,
//       color: Colors.white,
//     );
//     return buildBlogCastTimeline();
//   }

//   bool get wantKeepAlive => true;

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return DefaultTabController(
//       length: 4,
//       child: Scaffold(
//         backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
//         appBar: buildSearchField(),
//         body: TabBarView(
//           children: <Widget>[
//             buildUserSearchResults(),
//             buildPodCastSearch(),
//             buildBlogSearch(),
//             buildVideoSearch()
//           ],
//         ),
//       ),
//     );
//   }
// }

// class UserResult extends StatelessWidget {
//   final User user;

//   UserResult(this.user);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Theme.of(context).primaryColor.withOpacity(0.7),
//       child: Column(
//         children: <Widget>[
//           GestureDetector(
//             onTap: () => showProfile(context, profileId: user.id),
//             child: ListTile(
//               leading: CircleAvatar(
//                 backgroundColor: Colors.grey,
//                 backgroundImage: CachedNetworkImageProvider(user.photoUrl),
//               ),
//               title: Text(
//                 user.displayName,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               subtitle: Text(
//                 "${user.username}",
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ),
//           Divider(
//             height: 2.0,
//             color: Colors.white54,
//           ),
//         ],
//       ),
//     );
//   }
// }

// ---------------------------------

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:global_ios/models/user_model.dart';
import 'package:global_ios/screens/activity_feeds.dart';
import 'package:global_ios/screens/login.dart';
import 'package:global_ios/screens/posts.dart';
import 'package:global_ios/utilities/progress.dart';

final postsRef = FirebaseFirestore.instance.collection('posts');

class Search extends StatefulWidget {
  final User currentUser;

  Search({required this.currentUser});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search> {
  TextEditingController searchController = TextEditingController();
  List<DocumentSnapshot> rowPosts = [];
  List<DocumentSnapshot> podCastRowPosts = [];
  List<DocumentSnapshot> videoRowPosts = [];

  List<DocumentSnapshot> blogRowPosts = [];
  List searchResultsFuture = [];
  List<User> user = [];
  List<String> blockedUser = [];
  String searchQuery = "";
  late FirebaseFirestore db;

  @override
  void initState() {
    // print("INIT");
    super.initState();
    searchHandle();
    getFollowing();
    searchPodCast();
    searchBlog();
    searchVideo();
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .doc(this.widget.currentUser.id)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .get();
    rowPosts = snapshot.docs;

    setState(() {});
  }

  searchHandle() async {
    QuerySnapshot snapshot = await usersRef.get();
    blockedUser.clear();
    user.clear();

    await usersRef
        .doc(currentUser!.id)
        .collection("blockedBy")
        .get()
        .then((value) => {
              for (var docData in value.docs) {blockedUser.add(docData.id)}
            });

    for (var i in snapshot.docs) {
      if (i != currentUser!.id) {
        var userObj = User(
          id: i.get('id'),
          displayName: i.get('displayName').toString(),
          username: i.get('username').toString(),
          photoUrl: i.get('photoUrl'),
        );

        setState(() {
          if (i.get('id') != this.widget.currentUser.id) {
            if (blockedUser.isNotEmpty) {
              for (var id in blockedUser) {
                if (userObj.id != id) {
                  user.add(userObj);
                }
              }
            } else {
              user.add(userObj);
            }
          }
        });
      }
    }
  }

  List<User> tmpuser = [];
  bool isSearch = false;
  List<String> followingList = [];

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(currentUser!.id)
        .collection('userFollowing')
        .get();

    setState(() {
      followingList = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  handleSearch(String query) {
    setState(() {
      this.searchQuery = query;
    });

    tmpuser.clear();

    for (var i in user) {
      if (i.displayName.toLowerCase().contains(query.toLowerCase()) ||
          i.username.toLowerCase().contains(query.toLowerCase())) {
        setState(() {
          tmpuser.add(i);
        });
      }
    }
  }

  clearSearch() {
    searchController.clear();
  }

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      bottom: new TabBar(
          indicatorColor: Colors.pinkAccent[100],
          labelColor: Colors.pinkAccent[100],
          indicatorWeight: 0.5,
          unselectedLabelColor: Colors.grey[400],
          tabs: [
            new Tab(
              text: 'User',
            ),
            new Tab(
              text: 'PodCast',
            ),
            new Tab(text: 'Blog'),
            Tab(text: 'Video')
          ]),
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search for a user...',
          filled: true,
          prefixIcon: Icon(
            Icons.search,
            size: 28.0,
          ),
          suffixIcon: isSearch && searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: clearSearch,
                )
              : Container(),
        ),
        onFieldSubmitted: (value) {
          if (value.isEmpty) {
            setState(() {
              isSearch = false;
            });
            searchHandle();
          } else {
            setState(() {
              isSearch = true;
            });
            handleSearch(value);
          }
        },
        onChanged: (value) {
          if (mounted) {
            setState(() {
              this.searchQuery = value;
            });
          }
          if (value.isEmpty) {
            setState(() {
              isSearch = false;
            });
            searchHandle();
          } else {
            setState(() {
              isSearch = true;
            });
            handleSearch(value);
          }
        },
      ),
    );
  }

  Container buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Image.asset(
              'assets/images/search.png',
              height: orientation == Orientation.portrait ? 300.0 : 200.0,
            ),
            Text(
              'Find Users',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 60.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildUsersToFollow() {
    return StreamBuilder(
      stream:
          usersRef.orderBy('timestamp', descending: true).limit(30).snapshots(),
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> userResults = [];

        snapshot.data.doc.forEach((doc) {
          User user = User.fromDocument(doc);
          final bool isAuthUser = currentUser!.id == user.id;
          final bool isFollowingUser = followingList.contains(user.id);
          // remove auth user from recommended list
          if (isAuthUser) {
            return;
          } else if (isFollowingUser) {
            return;
          } else {
            /*usersRef
                .doc(widget.profileId)
                .collection('blockedBy')
                .doc(currentUserId)
                .get()
                .then((value) {})*/

            UserResult userResult = UserResult(user);
            userResults.add(userResult);
          }
        });
        return SingleChildScrollView(
          child: Container(
            color: Theme.of(context).accentColor.withOpacity(0.2),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.person_add,
                        color: Theme.of(context).primaryColor,
                        size: 30.0,
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      Text(
                        "Users to Follow",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 30.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(children: userResults),
              ],
            ),
          ),
        );
      },
    );
  }

  buildUserSearchResults() {
    if (isSearch) {
      return ListView.builder(
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () =>
                showProfile(context, profileId: "${tmpuser[index].id}"),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(4, 4),
                      blurRadius: 10,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                title: Text("${tmpuser[index].displayName}"),
                subtitle: Text("${tmpuser[index].username}"),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage("${tmpuser[index].photoUrl}"),
                ),
              ),
            ),
          );
        },
        itemCount: tmpuser.length,
      );
    } else {
      return ListView.builder(
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => showProfile(context, profileId: "${user[index].id}"),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(4, 4),
                      blurRadius: 10,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                title: Text("${user[index].displayName}"),
                subtitle: Text("${user[index].username}"),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage("${user[index].photoUrl}"),
                ),
              ),
            ),
          );
        },
        itemCount: user.length,
      );
    }
  }

  buildPodCastTimeline() {
    if (podCastRowPosts == null) {
      return circularProgress();
    } else if (podCastRowPosts.isEmpty) {
      return buildUsersToFollow();
    } else {
      return ListView.builder(
          itemCount: podCastRowPosts.length,
          itemBuilder: (BuildContext context, int i) {
            return Container(
              child: isSearch
                  ? podCastRowPosts[i]["title"]
                              .toString()
                              .toLowerCase()
                              .indexOf(searchQuery.toLowerCase()) !=
                          -1
                      ? Post.fromDocument(podCastRowPosts[i])
                      : Container()
                  : Post.fromDocument(podCastRowPosts[i]),
            );
          });
    }
  }

  buildVideoTimeline() {
    if (this.videoRowPosts == null) {
      return circularProgress();
    } else if (this.videoRowPosts.isEmpty) {
      return buildUsersToFollow();
    } else {
      return ListView.builder(
          itemCount: this.videoRowPosts.length,
          itemBuilder: (BuildContext context, int i) {
            return Container(
              child: isSearch
                  ? (this
                              .videoRowPosts[i]["title"]
                              .toString()
                              .toLowerCase()
                              .indexOf(this.searchQuery.toLowerCase()) !=
                          -1
                      ? Post.fromDocument(this.videoRowPosts[i])
                      : Container())
                  : Post.fromDocument(this.videoRowPosts[i]),
            );
          });
    }
  }

  buildBlogCastTimeline() {
    if (this.blogRowPosts == null) {
      return circularProgress();
    } else if (this.blogRowPosts.isEmpty) {
      return buildUsersToFollow();
    } else {
      return ListView.builder(
          itemCount: this.blogRowPosts.length,
          itemBuilder: (BuildContext context, int i) {
            return Container(
              child: isSearch
                  ? (this
                              .blogRowPosts[i]["title"]
                              .toString()
                              .toLowerCase()
                              .indexOf(this.searchQuery.toLowerCase()) !=
                          -1
                      ? Post.fromDocument(this.blogRowPosts[i])
                      : Container())
                  : Post.fromDocument(this.blogRowPosts[i]),
            );
          });
    }
  }

  searchVideo() async {
    FirebaseFirestore db =
        FirebaseFirestore.instance.collection("posts").firestore;

    this.videoRowPosts = (await db
            .collectionGroup("userPosts")
            .where("type", isEqualTo: "VIDEO")
            .get())
        .docs;
    setState(() {});
  }

  searchPodCast() async {
    FirebaseFirestore db =
        FirebaseFirestore.instance.collection("posts").firestore;

    this.podCastRowPosts = (await db
            .collectionGroup("userPosts")
            .where("type", isEqualTo: "PODCAST")
            .get())
        .docs;
    setState(() {});
  }

  searchBlog() async {
    FirebaseFirestore db =
        FirebaseFirestore.instance.collection("posts").firestore;

    this.blogRowPosts = (await db
            .collectionGroup("userPosts")
            .where("type", isEqualTo: "BLOG")
            .get())
        .docs;
    setState(() {});
  }

  buildPodCastSearch() {
//    this.searchPodCast();

//    this.db.app.
    return Container(
      child: buildPodCastTimeline(),
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
    );
  }

  buildVideoSearch() {
//    this.searchPodCast();

//    this.db.app.
    print("i am called");
    return Container(
      child: buildVideoTimeline(),
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
    );
  }

  buildBlogSearch() {
    return Container(
      child: buildBlogCastTimeline(),
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
    );
    return buildBlogCastTimeline();
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
        appBar: buildSearchField(),
        body: TabBarView(
          children: <Widget>[
            buildUserSearchResults(),
            buildPodCastSearch(),
            buildBlogSearch(),
            buildVideoSearch()
          ],
        ),
      ),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;

  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "${user.username}",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}
