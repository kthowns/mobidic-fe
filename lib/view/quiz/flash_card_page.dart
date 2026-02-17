import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:mobidic_flutter/viewmodel/flash_card_view_model.dart';
import 'package:provider/provider.dart';

class FlashCardPage extends StatelessWidget {
  const FlashCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FlashCardViewModel flashCardViewModel =
        context.watch<FlashCardViewModel>();
    final int quizColor = 0xFFb3e5fc;
    final CardSwiperController _cardSwiperController = CardSwiperController();

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
            onSelected: (value) {
              if (value == '파닉스') {
                Navigator.pushNamed(context, '/phonics');
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem<String>(value: '파닉스', child: Text('파닉스')),
                ],
          ),
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.home, color: Colors.black),
              onPressed: () {
                Navigator.popUntil(context, (route) {
                  return route.settings.name == '/vocab_list'; // 특정 route 이름 기준
                });
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
                  if(flashCardViewModel.words.isNotEmpty)
                  Expanded(
                    child: CardSwiper(
                      controller: _cardSwiperController,
                      isLoop: false,
                      cardBuilder: (context, index, hPer, vPer) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                                            flashCardViewModel.wordVisibility
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                          ),
                                          onPressed:
                                              flashCardViewModel
                                                  .toggleWordVisibility,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Text(
                                          flashCardViewModel
                                              .words[index]
                                              .expression,
                                          style: const TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (!flashCardViewModel.wordVisibility)
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
                                            flashCardViewModel.defVisibility
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                          ),
                                          onPressed:
                                              flashCardViewModel
                                                  .toggleDefVisibility,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Text(
                                          flashCardViewModel.words[index].defs
                                              .map(
                                                (d) =>
                                                    "${d.definition} (${d.part.label})",
                                              )
                                              .join(", "),
                                          style: const TextStyle(fontSize: 28),
                                        ),
                                        if (!flashCardViewModel.defVisibility)
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
                                    '${index + 1}/${flashCardViewModel.words.length}',
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
                      cardsCount: flashCardViewModel.words.length,
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
                          onPressed: _cardSwiperController.undo
                        ),
                        const SizedBox(width: 40),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          iconSize: 32,
                          onPressed: () {
                            _cardSwiperController.swipe(CardSwiperDirection.right);
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (flashCardViewModel.isLoading)
            Container(
              color: const Color(0x80000000), // 배경 어둡게
              child: const Center(child: CircularProgressIndicator()),
            ),
          if (flashCardViewModel.words.isEmpty && !flashCardViewModel.isLoading)
            Container(
              color: const Color(0x80000000), // 배경 어둡게
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.help_outline, size: 64, color: Colors.white70),
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
