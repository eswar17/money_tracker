class UserModel {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'name': name, 'email': email, 'photoUrl': photoUrl};
  }
}
