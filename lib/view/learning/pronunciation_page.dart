import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobidic/view/component/common_app_bar.dart';
import 'package:mobidic/viewmodel/pronunciation_view_model.dart';

class PronunciationPage extends ConsumerStatefulWidget {
  const PronunciationPage({super.key});

  @override
  ConsumerState<PronunciationPage> createState() => _PronunciationPageState();
}

class _PronunciationPageState extends ConsumerState<PronunciationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<double> _barHeights = List.filled(10, 10);
  Timer? _volumeTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _controller.stop();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(pronunciationStateProvider.notifier).checkMicPermission();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _volumeTimer?.cancel();
    super.dispose();
  }

  void onMicPressStart() {
    _controller.repeat(reverse: true);
    ref.read(pronunciationStateProvider.notifier).startRecording();
    _volumeTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      setState(() {
        _barHeights = List.generate(
          10,
          (index) => 10.0 + _random.nextDouble() * 40.0,
        );
      });
    });
  }

  void onMicPressEnd() {
    setState(() => _barHeights = List.filled(10, 10));
    _controller.stop();
    _volumeTimer?.cancel();
    ref.read(pronunciationStateProvider.notifier).stopRecordingAndUpload();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pronunciationStateProvider);
    final viewModel = ref.read(pronunciationStateProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: const CommonAppBar(title: '발음 체크'),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildBetaBanner(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Column(
                      children: [
                        _buildProgressInfo(state),
                        const SizedBox(height: 16),
                        _buildWordCard(state, viewModel),
                        const SizedBox(height: 24),
                        _buildResultSection(state),
                        const Spacer(),
                        _buildControlSection(state),
                      ],
                    ),
                  ),
                ),
                _buildNavigationButtons(state, viewModel),
              ],
            ),
          ),
          if (state.isLoading || state.isRating) _buildOverlay(state),
          if (state.words.isEmpty && !state.isLoading) _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildBetaBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.orange.shade100,
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: Colors.orange.shade800,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '베타 버전 안내: AI 발음 분석 엔진이 튜닝 중입니다. 결과가 다소 불안정할 수 있으니 양해 부탁드립니다.',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressInfo(PronunciationState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '실전 발음 연습',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        Text(
          '${state.currentWordIndex + 1} / ${state.words.length}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildWordCard(
    PronunciationState state,
    PronunciationViewModel viewModel,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            state.words.isNotEmpty ? state.currentWord.expression : "-",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.words.isNotEmpty
                ? state.currentWord.definitions
                      .take(2)
                      .map((d) => d.meaning)
                      .join(', ')
                : "-",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: viewModel.speak,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.volume_up_rounded, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    '원어민 발음 듣기',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection(PronunciationState state) {
    if (state.resultMessage.isEmpty && state.score == 0) {
      return Text(
        '하단 버튼을 눌러 말을 시작하세요',
        style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
      );
    }

    Color scoreColor = state.score >= 80
        ? Colors.green
        : (state.score >= 50 ? Colors.orange : Colors.red);

    return Column(
      children: [
        if (state.score > 0.1) ...[
          Text(
            '발음 정확도: ${state.score.toInt()}점',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: scoreColor,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          state.resultMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildControlSection(PronunciationState state) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            10,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 4,
              height: _barHeights[i],
              decoration: BoxDecoration(
                color: Colors.blue.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onLongPressStart: (_) =>
              state.hasPermission ? onMicPressStart() : null,
          onLongPressEnd: (_) => state.hasPermission ? onMicPressEnd() : null,
          child: Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 5,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(Icons.mic_rounded, color: Colors.white, size: 48),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          state.hasPermission ? '길게 눌러서 말하기' : '마이크 권한이 필요합니다',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(
    PronunciationState state,
    PronunciationViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavButton(
            icon: Icons.arrow_back_ios_new_rounded,
            label: '이전 단어',
            onTap: state.currentWordIndex > 0 ? viewModel.toPrevWord : null,
          ),
          _buildNavButton(
            icon: Icons.arrow_forward_ios_rounded,
            label: '다음 단어',
            onTap: state.currentWordIndex < state.words.length - 1
                ? viewModel.toNextWord
                : null,
            isRight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool isRight = false,
  }) {
    final color = onTap != null ? Colors.blue.shade700 : Colors.grey.shade300;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: isRight
              ? [
                  Text(
                    label,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Icon(icon, color: color, size: 18),
                ]
              : [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ],
        ),
      ),
    );
  }

  Widget _buildOverlay(PronunciationState state) {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 20),
            Text(
              state.isRating ? 'AI가 발음을 분석 중입니다...' : '잠시만 기다려주세요...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.folder_open_rounded,
              size: 80,
              color: Colors.white54,
            ),
            const SizedBox(height: 24),
            const Text(
              '단어장이 비어있습니다.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '학습할 단어를 먼저 추가해주세요.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
