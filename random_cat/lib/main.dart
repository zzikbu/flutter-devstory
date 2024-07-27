import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // main() 함수에서 async를 쓰려면 필요
  WidgetsFlutterBinding.ensureInitialized();

  // shared_preferences 인스턴스 생성
  SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CatService(prefs)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

/// 고양이 서비스
class CatService extends ChangeNotifier {
  // 고양이 사진 담을 변수
  List<String> catImages = [];

  // 좋아요 사진
  List<String> favoriteImages = [];

  // SharedPreferences 인스턴스
  SharedPreferences prefs;

  // 생성자(Constructor)
  CatService(this.prefs) {
    getRandomCatImages(); // api 호출

    // favorites key로 저장된 favoriteImages를 가져옴
    // 저장된 값이 없는 경우 null을 반환하므로 이때는 빈 배열을 넣어줌
    favoriteImages = prefs.getStringList("favorites") ?? [];
  }

  // 랜덤 고양이 사진 API 호출
  void getRandomCatImages() async {
    var result = await Dio().get(
      "https://api.thecatapi.com/v1/images/search?limit=10&mime_types=jpg",
    );
    print(result.data);
    for (int i = 0; i < result.data.length; i++) {
      var map = result.data[i]; // 반복문을 돌며 i번째의 map에 접근
      print(map);
      print(map['url']); // url만 추출
      catImages.add(map['url']); // catImages에 이미지 추가
    }

    notifyListeners(); // 새로고침
  }

  // 좋아요 토글
  void toggleFavoriteImage(String catImage) {
    if (favoriteImages.contains(catImage)) {
      favoriteImages.remove(catImage); // 이미 좋아요한 경우 제거
    } else {
      favoriteImages.add(catImage); // 새로운 사진 추가
    }

    // favoriteImages를 favorites라는 이름으로 저장하기
    prefs.setStringList("favorites", favoriteImages);

    notifyListeners(); // 새로고침
  }
}

/// 홈 페이지
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CatService>(
      builder: (context, catService, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("랜덤 고양이"),
            backgroundColor: Colors.amber,
            actions: [
              // 좋아요 페이지로 이동
              IconButton(
                icon: Icon(Icons.favorite),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FavoritePage()),
                  );
                },
              )
            ],
          ),
          // 고양이 사진 목록
          body: GridView.count(
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: EdgeInsets.all(8),
            crossAxisCount: 2,
            children: List.generate(
              catService.catImages.length, // 항목 개수
              (index) {
                String catImage = catService.catImages[index];
                return GestureDetector(
                  onTap: () {
                    print("인덱스 $index번 클릭 $catImage");
                    catService.toggleFavoriteImage(catImage);
                  },
                  child: Stack(
                    children: [
                      // 사진
                      // Positioned.fill은 left, right, top, bottom 모두 0으로 준 것과 같음
                      Positioned.fill(
                        child: Image.network(
                          catImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // 좋아요
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Icon(
                          Icons.favorite,
                          size: 40,
                          color: catService.favoriteImages.contains(catImage)
                              ? Colors.red
                              : Colors.transparent, // 투명
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// 좋아요 페이지
class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CatService>(
      builder: (context, catService, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("좋아요"),
            backgroundColor: Colors.amber,
          ),
          body: GridView.count(
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: EdgeInsets.all(8),
            crossAxisCount: 2,
            children: List.generate(
              catService.favoriteImages.length, // 항목 개수
              (index) {
                String catImage = catService.favoriteImages[index];
                return GestureDetector(
                  onTap: () {
                    print("인덱스 $index번 클릭 $catImage");
                    catService.toggleFavoriteImage(catImage);
                  },
                  child: Stack(
                    children: [
                      // 사진
                      // Positioned.fill은 left, right, top, bottom 모두 0으로 준 것과 같음
                      Positioned.fill(
                        child: Image.network(
                          catImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // 좋아요
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Icon(
                          Icons.favorite,
                          size: 40,
                          color: catService.favoriteImages.contains(catImage)
                              ? Colors.red
                              : Colors.transparent, // 투명
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
