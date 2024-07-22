import 'package:flutter/material.dart';

import 'main.dart';

/// Bucket 담당
class BucketService extends ChangeNotifier {
  List<Bucket> bucketList = [];

  /// 추가
  void createBucket(String job) {
    bucketList.add(Bucket(job, false));
    notifyListeners(); // 갱신 = Consumer<BucketService>의 builder 부분만 새로고침
  }

  /// 수정
  void updateBucket(Bucket bucket, int index) {
    bucketList[index] = bucket;
    notifyListeners();
  }

  /// 삭제
  void deleteBucket(int index) {
    bucketList.removeAt(index);
    notifyListeners();
  }
}
