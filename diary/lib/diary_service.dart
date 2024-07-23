import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Diary {
  String text; // 내용
  DateTime createdAt; // 작성 시간

  Diary({
    required this.text,
    required this.createdAt,
  });
}

class DiaryService extends ChangeNotifier {
  /// Diary 목록
  List<Diary> diaryList = [];

  /// 특정 날짜의 diary 조회
  List<Diary> getByDate(DateTime date) {
    return diaryList
        .where((diary) => isSameDay(date, diary.createdAt))
        .toList(); // .toList() 메서드는 Dart에서 Iterable을 리스트(List)로 변환할 때 사용
  }

  /// Diary 작성
  void create(String text, DateTime selectedDate) {
    DateTime now = DateTime.now();

    // 선택된 날짜(selectedDate)에 현재 시간으로 추가
    DateTime createdAt = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      now.hour,
      now.minute,
      now.second,
    );

    Diary diary = Diary(
      // 객체 하나 만들어서
      text: text,
      createdAt: createdAt,
    );
    diaryList.add(diary); // 삽입
    notifyListeners(); // 상태 변경 알리기
  }

  /// Diary 수정
  void update(DateTime createdAt, String newContent) {
    // createdAt은 중복될 일이 없기 때문에 createdAt을 고유 식별자로 사용
    // createdAt이 일치하는 diary 조회
    Diary diary = diaryList.firstWhere((diary) => diary.createdAt == createdAt);

    // text 수정
    diary.text = newContent;
    notifyListeners();
  }

  /// Diary 삭제
  void delete(DateTime createdAt) {
    // createdAt은 중복될 일이 없기 때문에 createdAt을 고유 식별자로 사용
    // createdAt이 일치하는 diary 삭제
    diaryList.removeWhere((diary) => diary.createdAt == createdAt);
    notifyListeners();
  }
}
