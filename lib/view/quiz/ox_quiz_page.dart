import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobidic_flutter/viewmodel/ox_quiz_view_model.dart';
import 'package:provider/provider.dart';

class OxQuizPage extends StatelessWidget {
  const OxQuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    final int quizColor = 0xFFb3e5fc;
    final OxQuizViewModel oxQuizViewModel = context.watch<OxQuizViewModel>();

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
                                            oxQuizViewModel.questions.isNotEmpty
                                                ? oxQuizViewModel
                                                    .currentQuestion
                                                    .stem
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
                                            oxQuizViewModel.questions.isNotEmpty
                                                ? oxQuizViewModel
                                                    .currentQuestion
                                                    .options
                                                    .join(', ')
                                                : "-",
                                            style: const TextStyle(
                                              fontSize: 28,
                                            ),
                                          ),
                                          SizedBox(height: 40),
                                          if (oxQuizViewModel.isSolved)
                                            Text(
                                              oxQuizViewModel.resultMessage,
                                              style: TextStyle(
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                          if (oxQuizViewModel.isDone)
                                            Column(
                                              children: [
                                                Text(
                                                  "정답률 : ${oxQuizViewModel.correctCount}/"
                                                  "${oxQuizViewModel.correctCount + oxQuizViewModel.incorrectCount}",
                                                  style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.amber,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          SizedBox(height: 40),
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
                                                oxQuizViewModel
                                                        .isButtonAvailable
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
                                                oxQuizViewModel
                                                        .isButtonAvailable
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
                                '${oxQuizViewModel.currentQuestionIndex + 1}/'
                                '${oxQuizViewModel.questions.length}',
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
                                '남은 시간: ${oxQuizViewModel.secondsLeft}\'s',
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
                ],
              ),
            ),
          ),
          if (oxQuizViewModel.isLoading)
            Container(
              color: const Color(0x80000000), // 배경 어둡게
              child: const Center(child: CircularProgressIndicator()),
            ),
          if (oxQuizViewModel.questions.isEmpty && !oxQuizViewModel.isLoading)
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
