import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobidic_flutter/view/util/navigation_helper.dart';
import 'package:mobidic_flutter/viewmodel/vocab_view_model.dart';
import 'package:provider/provider.dart';

class VocabListPage extends StatelessWidget {
  const VocabListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vocabViewModel = context.watch<VocabViewModel>();

    void showAddVocabDialog() {
      TextEditingController titleController = TextEditingController();
      TextEditingController descController = TextEditingController();

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('단어장 추가'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(hintText: '새 단어장 이름'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      hintText: '세부 설명을 입력해주세요',
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isNotEmpty) {
                      vocabViewModel.addVocab(
                        titleController.text,
                        descController.text,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('추가'),
                ),
              ],
            ),
      );
    }

    void showEditVocabDialog(int index) {
      TextEditingController titleController = TextEditingController(
        text: vocabViewModel.showingVocabs[index].title,
      );
      TextEditingController descController = TextEditingController(
        text: vocabViewModel.showingVocabs[index].description,
      );

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('단어장 편집'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(hintText: '단어장 이름'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(hintText: '세부 설명'),
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isNotEmpty) {
                      vocabViewModel.updateVocab(
                        vocabViewModel.showingVocabs[index],
                        titleController.text.trim(),
                        descController.text.trim(),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('저장'),
                ),
              ],
            ),
      );
    }

    void showDeleteDialog(int index) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('단어장 삭제'),
              content: const Text('이 단어장을 삭제할까요?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('아니오'),
                ),
                TextButton(
                  onPressed: () {
                    vocabViewModel.deleteVocab(
                      vocabViewModel.showingVocabs[index],
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('예'),
                ),
              ],
            ),
      );
    }

    Widget tagButton(String label, int index) {
      return ElevatedButton(
        onPressed: () {
          if (label == '퀴즈') {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              backgroundColor: Colors.yellow[100],
              builder: (BuildContext context) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Center(
                        child: Text(
                          '퀴즈 선택',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.5,
                        // 버튼 너비 비율 조정
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              vocabViewModel.selectVocabAt(index);
                              NavigationHelper.navigateToFlashCard(
                                context,
                                vocabViewModel,
                                index,
                              );
                            },
                            child: const Text('플래시카드'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              NavigationHelper.navigateToOxQuiz(
                                context,
                                vocabViewModel,
                                index,
                              );
                            },
                            child: const Text('O/X 퀴즈'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              NavigationHelper.navigateToDictationQuiz(
                                context,
                                vocabViewModel,
                                index,
                              );
                            },
                            child: const Text('받아쓰기'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              NavigationHelper.navigateToBlankQuiz(
                                context,
                                vocabViewModel,
                                index,
                              );
                            },
                            child: const Text('빈칸 채우기'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (label == '발음 체크') {
            NavigationHelper.navigateToPronunciationCheck(
              context,
              vocabViewModel,
              index,
            );
          }
        },
        child: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          textStyle: const TextStyle(fontSize: 12),
          backgroundColor: Colors.grey[300],
          foregroundColor: Colors.black87,
          shape: const StadiumBorder(),
        ),
      );
    }

    Widget buildVocabCard(int index) {
      final progress = vocabViewModel.showingVocabs[index].learningRate;

      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vocabViewModel.showingVocabs[index].title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vocabViewModel.showingVocabs[index].description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                if (vocabViewModel.editMode)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => showEditVocabDialog(index),
                        child: const Text('수정'),
                      ),
                      TextButton(
                        onPressed: () => showDeleteDialog(index),
                        child: const Text('삭제'),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              spacing: 8,
              children: [tagButton('퀴즈', index), tagButton('발음 체크', index)],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      Container(height: 20, color: Colors.grey[300]),
                      Container(
                        height: 20,
                        width: constraints.maxWidth * progress,
                        decoration: const BoxDecoration(color: Colors.green),
                      ),
                      Positioned.fill(
                        child: Center(
                          child: Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    Color getRateColor(double value) {
      value = value.clamp(0.0, 1.0);

      if (value < 0.5) {
        // 0.0 ~ 0.5 → 파랑 → 노랑
        double t = value / 0.5; // 0~1
        return Color.lerp(Colors.blue, Colors.yellow, t)!;
      } else {
        // 0.5 ~ 1.0 → 노랑 → 빨강
        double t = (value - 0.5) / 0.5; // 0~1
        return Color.lerp(Colors.yellow, Colors.red, t)!;
      }
    }

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                // 원하는 로직
                print('뒤로가기 누름');
                // 실제 뒤로 가기
                Navigator.pop(context);
              },
            ),
            title: Row(
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/mobidic_icon.png',
                    height: 40,
                  ),
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
                      const PopupMenuItem<String>(
                        value: '파닉스',
                        child: Text('파닉스'),
                      ),
                    ],
              ),
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: IconButton(
                  icon: const Icon(Icons.home, color: Colors.black),
                  onPressed: () {
                    Navigator.popUntil(context, (route) {
                      return route.settings.name ==
                          '/vocab_list'; // 특정 route 이름 기준
                    });
                  },
                ),
              ),
            ],
          ),
          extendBodyBehindAppBar: true,
          body: Container(
            decoration: BoxDecoration(color: Colors.white),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 20,
                      left: 20,
                      top: 10,
                      bottom: 4,
                    ),
                    child: TextField(
                      controller: vocabViewModel.searchController,
                      decoration: InputDecoration(
                        hintText: '검색어를 입력하세요',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.blue[100],
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('평균 학습률'),
                                  SizedBox(width: 8), // 텍스트와 프로그레스 바 사이 간격
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: vocabViewModel.avgLearningRate
                                          .clamp(0.0, 1.0),
                                      backgroundColor: Colors.grey[300],
                                      color: getRateColor(
                                        vocabViewModel.avgLearningRate,
                                      ),
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('평균 정답률'),
                                  SizedBox(width: 8), // 텍스트와 프로그레스 바 사이 간격
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: vocabViewModel.avgAccuracy.clamp(
                                        0.0,
                                        1.0,
                                      ),
                                      backgroundColor: Colors.grey[300],
                                      color: getRateColor(
                                        vocabViewModel.avgAccuracy,
                                      ),
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                              Text('단어장 개수 : ${vocabViewModel.vocabs.length}'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: vocabViewModel.cycleSortOption,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[100],
                            foregroundColor: Colors.black,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          child: Text(
                            vocabViewModel.sortOptions[vocabViewModel
                                .currentSortIndex],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: vocabViewModel.toggleEditMode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                vocabViewModel.editMode
                                    ? Colors.blue[300]
                                    : Colors.blue[100],
                            foregroundColor: Colors.black,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          child: Text(
                            '편집',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: vocabViewModel.loadData,
                      child:
                          vocabViewModel.vocabs.isNotEmpty
                              ? ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: vocabViewModel.showingVocabs.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap:
                                        () =>
                                            NavigationHelper.navigateToWordList(
                                              context,
                                              vocabViewModel,
                                              index,
                                            ),
                                    child: buildVocabCard(index),
                                  );
                                },
                              )
                              : Center(
                                child: Text(
                                  "단어장을 추가해주세요.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: showAddVocabDialog,
            backgroundColor: Colors.blue[100],
            child: const Icon(Icons.add),
          ),
        ),
        if (vocabViewModel.isLoading)
          Container(
            color: const Color(0x80000000), // 배경 어둡게
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
