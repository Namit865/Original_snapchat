import 'package:cloud_firestore/cloud_firestore.dart';

class userData {
  final String name;
  final String email;
  final String password;
  final bool isLoading;

  userData({
    required this.name,
    required this.email,
    required this.password,
    this.isLoading = false,
  });

  factory userData.fromDocument(DocumentSnapshot doc) {
    return userData(
      name: doc['name'] ?? '',
      email: doc['email'] ?? '',
      password: doc['password'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      // Password should not be stored in plain text
    };
  }
}
