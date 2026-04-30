import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tapreport/models/post.dart';

class PostService {
  static final FirebaseFirestore _database = FirebaseFirestore.instance;
  static final CollectionReference _postsCollection = _database.collection
  ('post');

  static Future<void> addPost(Post post) async {
    Map<String, dynamic> newPost = {
      'image': post.image,
      'description': post.description,
      'category': post.category,
      'latitude': post.latitude,
      'longitude': post.longitude,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'user_id': post.userId,
      'user_fullname': post.userFullname,
    };

    await _postsCollection.add(newPost);
  }

  static Future<void> updatePost(Post post) async {
    Map<String, dynamic> updatedPost = {
      'image': post.image,
      'description': post.description,
      'category': post.category,
      'latitude': post.latitude,
      'longitude': post.longitude,
      'created_at': post.createdAt,
      'updated_at': FieldValue.serverTimestamp(),
      'user_id': post.userId,
      'user_fullname': post.userFullname,
    };

    await _postsCollection.doc(post.id).update(updatedPost);
  }

  static Future<void> deletePost(Post post) async {
    await _postsCollection.doc(post.id).delete();
  }

  static Future<QuerySnapshot> retrievePosts() {
    return _postsCollection.get();
  }

  static Stream<List<Post>> getPostList() {
    return _postsCollection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Post.fromDocument(doc);
      }).toList();
    });
  }
}