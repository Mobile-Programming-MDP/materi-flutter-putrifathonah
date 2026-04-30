import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String? id;
  final String image;
  final String description;
  final String category;
  final String latitude;
  final String longitude;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final String userId;
  final String userFullname;

  Post({
    this.id,
    required this.image,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.createdAt,
    this.updatedAt,
    required this.userId,
    required this.userFullname,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Post(
      id: doc.id,
      image: data['image'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      latitude: data['latitude'] ?? '',
      longitude: data['longitude'] ?? '',
      createdAt: data['created_at'],
      updatedAt: data['updated_at'],
      userId: data['user_id'] ?? '',
      userFullname: data['user_fullname'] ?? '',
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'image': image,
      'description': description,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
      'updated_at': updatedAt,
      'user_id': userId,
      'user_fullname': userFullname,
    };
  }
}