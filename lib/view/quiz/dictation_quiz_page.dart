import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobidic/view/component/common_app_bar.dart';
import 'package:mobidic/viewmodel/dictation_quiz_view_model.dart';

class DictationQuizPage extends ConsumerStatefulWidget {
  const DictationQuizPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DictationQuizPageState();
}

class _DictationQuizPageState extends ConsumerState<DictationQuizPage> {
  final TextEditingController userAnswerController = TextEditingController();

  @override
  void dispose() {
    userAnswerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dictationQuizViewModel = ref.read(
      dictationQuizStateProvider.notifier,
    );
    final dictationQuizState = ref.watch(dictationQuizStateProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CommonAppBar(title: '받아쓰기'),
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
                        child: dictationQuizState.isDone
                            ? _buildResultView(dictationQuizState)
                            : _buildQuizView(
                                dictationQuizState,
                                dictationQuizViewModel,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (dictationQuizState.isLoading)
            Container(
              color: const Color(0x80000000), // 배경 어둡게
              child: const Center(child: CircularProgressIndicator()),
            ),
          if (dictationQuizState.quizzes.isEmpty &&
              !dictationQuizState.isLoading)
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
    DictationQuizState dictationQuizState,
    DictationQuizViewModel dictationQuizViewModel,
  ) {
    return Stack(
      children: [
        // 카드 내용
        Column(
          children: [
            Flexible(flex: 1, fit: FlexFit.loose, child: Container()),
            Flexible(
              flex: 2,
              fit: FlexFit.loose,
              child: _buildFirstHalf(
                dictationQuizState,
                dictationQuizViewModel,
              ),
            ),
            Flexible(
              flex: 4,
              fit: FlexFit.loose,
              child: _buildSecondHalf(
                dictationQuizState,
                dictationQuizViewModel,
              ),
            ),
          ],
        ),
        // 진행률 우측 상단
        Positioned(
          top: 0,
          right: 0,
          child: Text(
            '${dictationQuizState.currentQuizIndex + 1}/${dictationQuizState.quizzes.length}',
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
            '남은 시간: ${dictationQuizState.remainingSeconds}\'s',
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

  Widget _buildFirstHalf(
    DictationQuizState dictationQuizState,
    DictationQuizViewModel dictationQuizViewModel,
  ) {
    return GestureDetector(
      onTap: dictationQuizViewModel.speak,
      child: Container(
        padding: const EdgeInsets.symmetric(),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dictationQuizState.quizzes.isNotEmpty
                      ? "${dictationQuizState.currentQuizIndex + 1}번 음성"
                      : "-",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.volume_up, size: 30),
              ],
            ),
            const Spacer(),
            const Text("발음을 들어보세요.", style: TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondHalf(
    DictationQuizState dictationQuizState,
    DictationQuizViewModel dictationQuizViewModel,
  ) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          dictationQuizState.resultMessage,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: dictationQuizState.resultMessage.contains('정답')
                ? Colors.green
                : Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        const Text(
          "음성을 듣고 단어를 입력해주세요",
          style: TextStyle(
            fontSize: 18,
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          enabled: dictationQuizState.isButtonAvailable,
          controller: userAnswerController,
          maxLines: 1,
          maxLength: dictationQuizState.quizzes.isNotEmpty
              ? dictationQuizState.currentQuiz.stem.length
              : 10,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 30, color: Colors.black),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (s) {
            dictationQuizViewModel.checkAnswer(s);
            userAnswerController.text = '';
          },
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: dictationQuizState.isButtonAvailable
                ? () {
                    dictationQuizViewModel.checkAnswer(
                      userAnswerController.text,
                    );
                    userAnswerController.text = '';
                  }
                : null,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              "제출하기",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView(DictationQuizState state) {
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
