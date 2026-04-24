import 'package:flutter/material.dart';
import 'package:mobidic_flutter/model/word.dart';

class WordCard extends StatelessWidget {
  final Word word;
  final bool editMode;
  final Function(Word) onToggleLearned;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const WordCard({
    super.key,
    required this.word,
    this.editMode = false,
    required this.onToggleLearned,
    required this.onEdit,
    required this.onDelete,
  });

  Color getWordBoxColor(Word word) {
    double difficulty = word.difficulty;
    difficulty = difficulty.clamp(0.0, 1.0);

    if (difficulty < 0.5) {
      double t = difficulty / 0.5;
      return Color.lerp(Colors.green, Colors.yellow, t)!;
    } else {
      double t = (difficulty - 0.5) / 0.5;
      return Color.lerp(Colors.yellow, Colors.red, t)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final difficultyColor = getWordBoxColor(word);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6, color: difficultyColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              word.expression,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => onToggleLearned(word),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: word.isLearned ? Colors.green.shade50 : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: word.isLearned ? Colors.green.shade200 : Colors.grey.shade200,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    word.isLearned ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                    size: 14,
                                    color: word.isLearned ? Colors.green.shade700 : Colors.grey.shade400,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    word.isLearned ? '암기완료' : '미암기',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: word.isLearned ? Colors.green.shade700 : Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...word.definitions.map((d) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                                      children: [
                                        TextSpan(
                                          text: '[${d.part.label}] ',
                                          style: TextStyle(
                                            color: Colors.blue.shade700,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        TextSpan(text: d.meaning),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      if (editMode) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.edit_rounded, size: 16),
                              label: const Text('수정'),
                              onPressed: onEdit,
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.delete_outline_rounded, size: 16),
                              label: const Text('삭제', style: TextStyle(color: Colors.red)),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              onPressed: onDelete,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
