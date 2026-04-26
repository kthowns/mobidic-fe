import 'package:flutter/material.dart';
import 'package:mobidic_flutter/model/vocab.dart';
import 'package:mobidic_flutter/view/component/quick_action_tag.dart';

class VocabCard extends StatelessWidget {
  final Vocab vocab;
  final bool editMode;
  final Function(String) onTagTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const VocabCard({
    super.key,
    required this.vocab,
    this.editMode = false,
    required this.onTagTap,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = vocab.learningRate;
    final color = Colors.blue.shade600;

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
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 6, color: color),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                vocab.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                            ),
                            Text(
                              "${vocab.wordCount} words",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                        if (vocab.createdAt != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            "${vocab.createdAt!.year}-${vocab.createdAt!.month.toString().padLeft(2, '0')}-${vocab.createdAt!.day.toString().padLeft(2, '0')}",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        if (vocab.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            vocab.description,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            QuickActionTag(
                              label: '카드',
                              icon: Icons.style_rounded,
                              color: Colors.blue.shade700,
                              onTap: () => onTagTap('플래시카드'),
                            ),
                            QuickActionTag(
                              label: '발음',
                              icon: Icons.mic_rounded,
                              color: Colors.purple.shade600,
                              onTap: () => onTagTap('발음 체크'),
                            ),
                            QuickActionTag(
                              label: '퀴즈',
                              icon: Icons.extension_rounded,
                              color: Colors.orange.shade700,
                              onTap: () => onTagTap('퀴즈'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        '학습 달성도',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        '${(progress * 100).toInt()}%',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: color,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: progress.clamp(0.0, 1.0),
                                      backgroundColor: color.withOpacity(0.1),
                                      color: color,
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (editMode) ...[
                              const SizedBox(width: 12),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.edit_rounded, size: 18, color: Colors.grey),
                                onPressed: onEdit,
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                                onPressed: onDelete,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
