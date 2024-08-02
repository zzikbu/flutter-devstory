import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BucketService extends ChangeNotifier {
  // 컬렉션
  final bucketCollection = FirebaseFirestore.instance.collection('bucket');

  Future<QuerySnapshot> read(String uid) async {
    // 내 bucketList 가져오기
    // 전달 받은 uid와 일치하는 문서만 가져오기
    return bucketCollection.where('uid', isEqualTo: uid).get();
  }

  void create(String job, String uid) async {
    // bucket 만들기
    // 컬렉션에 문서 추가
    await bucketCollection.add({
      'uid': uid, // 유저 식별자
      'job': job, // 하고싶은 일
      'isDone': false, // 완료 여부
    });
    notifyListeners(); // 화면 갱신
  }

  void update(String docId, bool isDone) async {
    // bucket isDone 업데이트
    await bucketCollection.doc(docId).update({"isDone": isDone});
    notifyListeners();
  }

  void delete(String docId) async {
    // bucket 삭제
    await bucketCollection.doc(docId).delete();
    notifyListeners();
  }
}
