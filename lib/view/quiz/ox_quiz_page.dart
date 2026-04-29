import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobidic/view/component/common_app_bar.dart';
import 'package:mobidic/viewmodel/ox_quiz_view_model.dart';

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
                        child: oxQuizState.isDone
                            ? _buildResultView(oxQuizState)
                            : _buildQuizView(oxQuizState, oxQuizViewModel),
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

  Widget _buildQuizView(
    OxQuizState oxQuizState,
    OxQuizViewModel oxQuizViewModel,
  ) {
    return Stack(
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
                      const Divider(height: 50, thickness: 1),
                      Text(
                        oxQuizState.quizzes.isNotEmpty
                            ? oxQuizState.currentQuiz.options.join(', ')
                            : "-",
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        oxQuizState.resultMessage,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: oxQuizState.resultMessage.contains('정답')
                              ? Colors.green
                              : Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
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
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: oxQuizState.isButtonAvailable
                            ? () => oxQuizViewModel.checkAnswer(true)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[100],
                          minimumSize: const Size.fromHeight(double.infinity),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "O",
                          style: TextStyle(fontSize: 30, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: oxQuizState.isButtonAvailable
                            ? () => oxQuizViewModel.checkAnswer(false)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow[100],
                          minimumSize: const Size.fromHeight(double.infinity),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "X",
                          style: TextStyle(fontSize: 30, color: Colors.black),
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
            '${oxQuizState.currentQuizIndex + 1}/${oxQuizState.quizzes.length}',
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
    );
  }

  Widget _buildResultView(OxQuizState state) {
    final accuracy = (state.correctCount / state.quizzes.length * 100).toInt();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.stars_rounded, size: 80, color: Colors.orange),
          const SizedBox(height: 24),
          const Text(
            "퀴즈 완료!",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            "정답: ${state.correctCount} / ${state.quizzes.length}",
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            "정답률: $accuracy%",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: accuracy >= 70 ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "단어장으로 돌아가기",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
