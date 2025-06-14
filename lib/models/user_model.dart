import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String userName;
  final String displayName;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.userName,
    required this.displayName,
    this.photoURL,
    required this.createdAt,
    required this.lastLoginAt,
  });

  // Convert UserModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'userName': userName,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
    };
  }

  // Create UserModel from Firestore JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      userName: json['userName'] ?? '',
      displayName: json['displayName'] ?? '',
      photoURL: json['photoURL'],
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (json['lastLoginAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? userName,
    String? displayName,
    String? photoURL,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      userName: userName ?? this.userName,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, userName: $userName, displayName: $displayName, photoURL: $photoURL, createdAt: $createdAt, lastLoginAt: $lastLoginAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.uid == uid &&
        other.email == email &&
        other.userName == userName &&
        other.displayName == displayName &&
        other.photoURL == photoURL &&
        other.createdAt == createdAt &&
        other.lastLoginAt == lastLoginAt;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
    email.hashCode ^
    userName.hashCode ^
    displayName.hashCode ^
    photoURL.hashCode ^
    createdAt.hashCode ^
    lastLoginAt.hashCode;
  }
}