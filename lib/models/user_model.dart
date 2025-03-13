import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;
  final String userId;

  User({
    this.id = "",
    this.username = "",
    this.email = "",
    this.photoUrl = "",
    this.displayName = "",
    this.bio = "",
    this.userId = "",
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    Map? map = doc.data() as Map?;

    if (map!.containsKey('id')) {
      return User(
          id: map['id'],
          email: map['email'],
          photoUrl: map['photoUrl'],
          username: map['username'],
          displayName: map['displayName'],
          bio: map['bio'],
          userId: map['id']);
    }
    throw (e) {
      print(e);
    };
  }

  factory User.fromJSON(Map<String, dynamic> doc, String userId) {
    return User(
      id: doc['id'],
      email: doc['email'],
      photoUrl: doc['photoUrl'],
      username: doc['username'],
      displayName: doc['displayName'],
      bio: doc['bio'],
    );
  }
}
