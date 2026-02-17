import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobidic_flutter/viewmodel/pronunciation_view_model.dart';
import 'package:provider/provider.dart';

class PronunciationCheckPage extends StatefulWidget {
  const PronunciationCheckPage({super.key});

  @override
  State<PronunciationCheckPage> createState() => _PronunciationCheckPageState();
}

class _PronunciationCheckPageState extends State<PronunciationCheckPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  List<double> _barHeights = List.filled(6, 20);
  Timer? _volumeTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _controller.stop(); // 처음에는 정지
  }

  @override
  void dispose() {
    _controller.dispose();
    _volumeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pronunciationViewModel = context.watch<PronunciationViewModel>();
    final int quizColor = 0xFFb3e5fc;

    void onMicPressStart() {
      _controller.repeat(reverse: true);
      pronunciationViewModel.startRecording();

      _volumeTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        setState(() {
          _barHeights = List.generate(
            6,
            (index) => 20.0 + _random.nextDouble() * 40.0,
          );
        });
      });
    }

    void onMicPressEnd() {
      setState(() {
        _barHeights = List.filled(6, 20);
      });
      _controller.stop();
      _volumeTimer?.cancel();

      pronunciationViewModel.stopRecordingAndUpload();
    }

    Widget buildHeader() {
      return Container();
    }

    Widget buildFirstBody() {
      return GestureDetector(
        onTap: pronunciationViewModel.speak,
        child: Container(
          padding: const EdgeInsets.symmetric(),
          decoration: BoxDecoration(
            color: const Color(0xFFB2F2BB),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    pronunciationViewModel.words.isNotEmpty
                        ? pronunciationViewModel.currentWord.expression
                        : "-",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true, // 줄바꿈 허용
                    overflow: TextOverflow.ellipsis, // 넘치면 ... 표시
                    maxLines: 2, // 최대 두 줄까지
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.volume_up, size: 30),
                ],
              ),
              Text(
                pronunciationViewModel.words.isNotEmpty
                    ? pronunciationViewModel.currentWord.defs
                        .map((d) => "${d.definition} (${d.part.label})")
                        .join(', ')
                    : "-",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 28),
              ),
              Spacer(),
              Text("발음을 들어보세요.", style: const TextStyle(fontSize: 15)),
              SizedBox(height: 10),
            ],
          ),
        ),
      );
    }

    Widget buildSecondBody() {
      Color scoreColor;
      if (pronunciationViewModel.score < 30) {
        scoreColor = Colors.red;
      } else if (pronunciationViewModel.score < 65) {
        scoreColor = Colors.orange;
      } else {
        scoreColor = Colors.green;
      }

      return Container(
        child: Column(
          children: [
            SizedBox(height: 10),
            if (pronunciationViewModel.resultMessage != "")
              Text(
                '발음 채점 결과',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.orange,
                ),
                textAlign: TextAlign.center,
              ),
            Spacer(),
            if (pronunciationViewModel.resultMessage != "")
              Text(
                pronunciationViewModel.resultMessage,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: scoreColor,
                ),
                textAlign: TextAlign.center,
              ),
            Spacer(),
            Column(
              children: [
                SizedBox(
                  height: 60, // ← 고정 높이
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 8,
                          height: _barHeights[i],
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const Text(
                  'AI 티쳐가 발음을 확인합니다',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ],
        ),
      );
    }

    Widget buildFooter() {
      return Container(
        child: Column(
          children: [
            GestureDetector(
              onLongPressStart:
                  (_) =>
                      !pronunciationViewModel.isWeb ? onMicPressStart() : null,
              onLongPressEnd: (_) => !pronunciationViewModel.isWeb ? onMicPressEnd() : null,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF6A7FDB), Color(0xFF52E5E7)],
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(14.0),
                  child: Icon(Icons.mic, color: Colors.white, size: 44),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              !pronunciationViewModel.isWeb
                  ? '버튼을 누른 채 말해보세요!'
                  : "발음체크는 모바일 앱에서만 지원됩니다.",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      );
    }

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
                  Expanded(
                    flex: 1,
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
                            Column(
                              children: [
                                Flexible(
                                  flex: 1,
                                  fit: FlexFit.loose,
                                  child: buildHeader(),
                                ),
                                Flexible(
                                  flex: 2,
                                  fit: FlexFit.loose,
                                  child: buildFirstBody(),
                                ),
                                Flexible(
                                  flex: 3,
                                  fit: FlexFit.loose,
                                  child: buildSecondBody(),
                                ),
                                Flexible(
                                  flex: 2,
                                  fit: FlexFit.loose,
                                  child: buildFooter(),
                                ),
                              ],
                            ),
                            // 진행률 우측 상단
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Text(
                                '${pronunciationViewModel.currentWordIndex + 1}/'
                                '${pronunciationViewModel.words.length}',
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          iconSize: 32,
                          onPressed:
                              pronunciationViewModel.currentWordIndex > 0
                                  ? () {
                                    pronunciationViewModel.toPrevWord();
                                  }
                                  : null,
                        ),
                        const SizedBox(width: 40),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          iconSize: 32,
                          onPressed:
                              pronunciationViewModel.currentWordIndex <
                                      pronunciationViewModel.words.length - 1
                                  ? () {
                                    pronunciationViewModel.toNextWord();
                                  }
                                  : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (pronunciationViewModel.isLoading)
            Container(
              color: const Color(0x80000000), // 배경 어둡게
              child: const Center(child: CircularProgressIndicator()),
            ),
          if (pronunciationViewModel.isRating)
            Container(
              color: const Color(0x80000000), // 배경 어둡게
              child: const Center(
                child: const Text(
                  '채점 중...',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          if (pronunciationViewModel.words.isEmpty &&
              !pronunciationViewModel.isLoading)
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
    Stack(children: []);
  }
}
