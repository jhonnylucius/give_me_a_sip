class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final bool termsAccepted;

  UserModel(
      {required this.uid,
      required this.displayName,
      required this.email,
      this.termsAccepted = false});

  factory UserModel.fromDocument(Map<String, dynamic> doc) {
    return UserModel(
        uid: doc['uid'],
        displayName: doc['displayName'],
        email: doc['email'],
        termsAccepted: doc['termsAccepted'] ?? false);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'termsAccepted': termsAccepted
    };
  }
}
