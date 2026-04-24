import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic_flutter/view/component/common_app_bar.dart';
import 'package:mobidic_flutter/viewmodel/ox_quiz_view_model.dart';

class OxQuizPage extends ConsumerStatefulWidget {
  const OxQuizPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OxQuizPageState();
}

class _OxQuizPageState extends ConsumerState<OxQuizPage> {
  final int quizColor = 0xFFb3e5fc;

  @override
  Widget build(BuildContext context) {
    final oxQuizViewModel = ref.read(oxQuizStateProvider.notifier);
    final oxQuizState = ref.watch(oxQuizStateProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CommonAppBar(title: 'O/X 퀴즈'),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFFb3e5fc)),
            child: SafeArea(
              child: Column(
                children: [
                  // 카드 내용
                  Expanded(
                    child: Padding(
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
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Expanded(child: Container()),
                                      Column(
                                        children: [
                                          Text(
                                            oxQuizState.quizzes.isNotEmpty
                                                ? oxQuizState.currentQuiz.stem
                                                : "-",
                                            style: const TextStyle(
                                              fontSize: 36,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Divider(
                                            height: 50,
                                            thickness: 1,
                                          ),
                                          Text(
                                            oxQuizState.quizzes.isNotEmpty
                                                ? oxQuizState
                                                    .currentQuiz
                                                    .options
                                                    .join(', ')
                                                : "-",
                                            style: const TextStyle(
                                              fontSize: 28,
                                            ),
                                          ),
                                          Text(
                                            oxQuizState.resultMessage,
                                            style: const TextStyle(
                                              fontSize: 28,
                                              color: Colors.green,
                                            ),
                                          ),
                                          SizedBox(height: 30),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: ElevatedButton(
                                            onPressed:
                                                oxQuizState.isButtonAvailable
                                                    ? () {
                                                      oxQuizViewModel
                                                          .checkAnswer(true);
                                                    }
                                                    : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue[100],
                                              // 보기 쉽게 색 추가
                                              minimumSize: Size.fromHeight(
                                                double.infinity,
                                              ),
                                              // 세로 꽉 채우기
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      10,
                                                    ), // 적당히 각진 정도
                                              ),
                                            ),
                                            child: Text(
                                              "O",
                                              style: TextStyle(
                                                fontSize: 30,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: ElevatedButton(
                                            onPressed:
                                                oxQuizState.isButtonAvailable
                                                    ? () {
                                                      oxQuizViewModel
                                                          .checkAnswer(false);
                                                    }
                                                    : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.yellow[100],
                                              minimumSize: Size.fromHeight(
                                                double.infinity,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            child: Text(
                                              "X",
                                              style: TextStyle(
                                                fontSize: 30,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // 진행률 우측 상단
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Text(
                                '${oxQuizState.currentQuizIndex + 1}/'
                                '${oxQuizState.quizzes.length}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Text(
                                '남은 시간: ${oxQuizState.remainingSeconds}\'s',
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
                    ),
                  ),  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (oxQuizState.isLoading)
            Container(
              color: const Color(0x80000000), // 배경 어둡게
              child: const Center(child: CircularProgressIndicator()),
            ),
          if (oxQuizState.quizzes.isEmpty && !oxQuizState.isLoading)
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
