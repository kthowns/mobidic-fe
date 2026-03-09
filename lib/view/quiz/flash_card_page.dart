import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic_flutter/viewmodel/auth_view_model.dart';
import 'package:mobidic_flutter/viewmodel/word_view_model.dart';

class FlashCardPage extends ConsumerStatefulWidget {
  const FlashCardPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => FlashCardPageState();
}

class FlashCardPageState extends ConsumerState<FlashCardPage> {
  final CardSwiperController cardSwiperController = CardSwiperController();
  final int quizColor = 0xFFb3e5fc;
  bool wordVisibility = true;
  bool defVisibility = false;

  @override
  void dispose() {
    cardSwiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wordListState = ref.watch(wordListStateProvider);

    print("FlashCardPage. Words : ${wordListState.words}");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(quizColor),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            Center(
              child: Image.asset('assets/images/mobidic_icon.png', height: 40),
            ),
            SizedBox(width: 8),
            Text(
              'MOBIDIC',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.black),
            onSelected: (value) async {
              if (value == '파닉스') {
                Navigator.pushNamed(context, '/phonics');
              } else if (value == '로그아웃') {
                await ref.read(authViewModelProvider.notifier).logout();

                // 💡 핵심: 이동하기 전에 현재 사용 중인 Provider들을 다 초기화해서 찌꺼기를 없앱니다.
                ref.invalidate(authViewModelProvider);

                if (!mounted) return;

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/', // 위에서 루트를 로그인으로 바꿨다면 '/'로 이동
                  (route) => false,
                );
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem<String>(value: '파닉스', child: Text('파닉스')),
                  const PopupMenuItem<String>(
                    value: '로그아웃',
                    child: Text('로그아웃'),
                  ),
                ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.home, color: Colors.black),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/vocabularies',
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFb3e5fc), Color(0xFF81d4fa)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 카드 내용
                  if (wordListState.words.isNotEmpty)
                    Expanded(
                      child: CardSwiper(
                        controller: cardSwiperController,
                        isLoop: false,
                        cardBuilder: (context, index, hPer, vPer) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(2, 4),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // 카드 내용
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // 영단어 영역
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            '영단어',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              wordVisibility
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                wordVisibility =
                                                    !wordVisibility;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Text(
                                            wordListState
                                                .words[index]
                                                .expression,
                                            style: const TextStyle(
                                              fontSize: 36,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (!wordVisibility)
                                            Positioned.fill(
                                              child: Container(
                                                color: Colors.blue[100],
                                              ),
                                            ),
                                        ],
                                      ),
                                      const Divider(height: 50, thickness: 1),
                                      // 뜻 영역
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            '뜻',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              defVisibility
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                defVisibility = !defVisibility;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Text(
                                            wordListState
                                                .words[index]
                                                .definitions
                                                .map(
                                                  (d) =>
                                                      "${d.meaning} (${d.part.label})",
                                                )
                                                .join(", "),
                                            style: const TextStyle(
                                              fontSize: 28,
                                            ),
                                          ),
                                          if (!defVisibility)
                                            Positioned.fill(
                                              child: Container(
                                                color: Colors.blue[100],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // 진행률 우측 상단
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Text(
                                      '${index + 1}/${wordListState.words.length}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        cardsCount: wordListState.words.length,
                        numberOfCardsDisplayed:
                            wordListState.words.length >= 3
                                ? 3
                                : wordListState.words.length,
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          iconSize: 32,
                          onPressed: cardSwiperController.undo,
                        ),
                        const SizedBox(width: 40),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          iconSize: 32,
                          onPressed: () {
                            cardSwiperController.swipe(
                              CardSwiperDirection.right,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (wordListState.words.isEmpty)
            Container(
              color: const Color(0x80000000), // 배경 어둡게
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //Icon(Icons.help_outline, size: 64, color: Colors.white70),
                    SizedBox(height: 16),
                    Text(
                      '단어장이 비어있습니다.',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '단어장에 단어를 추가해보세요!',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
