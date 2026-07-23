import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_dev_summative/core/models/base_model.dart';

abstract class BaseRepository<T extends BaseModel> {
  final CollectionReference<T> _collection;

  BaseRepository(
    String collectionName,
    T Function(Map<String, dynamic> map) fromMap,
  ) : _collection = FirebaseFirestore.instance
          .collection(collectionName)
          .withConverter<T>(
            fromFirestore: (snapshot, _) =>
                fromMap({...snapshot.data()!, 'id': snapshot.id}),
            toFirestore: (entity, _) => entity.toMap()!,
          );

  CollectionReference<T> get collectionRef => _collection;

  Future<String> create(T entity) async {
    final docRef = await _collection.add(entity);
    return docRef.id;
  }

  Future<List<T>> findAll() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<T?> findById(String id) async {
    final snapshot = await _collection.doc(id).get();
    return snapshot.data();
  }

  Future<void> update(T entity) {
    return _collection.doc(entity.id).update(entity.toMap()!);
  }

  Future<void> delete(String id) {
    return _collection.doc(id).delete();
  }
}
