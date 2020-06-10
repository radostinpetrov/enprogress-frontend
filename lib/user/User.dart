import 'package:firebase_auth/firebase_auth.dart';

class User {

  String username;
  int userID;
  FirebaseUser firebaseUser;

  User(String username, int userID, FirebaseUser firebaseUser,) {
    this.username = username;
    this.userID = userID;
    this.firebaseUser = firebaseUser;
  }

}