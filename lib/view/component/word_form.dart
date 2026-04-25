import 'package:flutter/material.dart';
import 'package:mobidic_flutter/model/definition.dart';
import 'package:mobidic_flutter/type/part_of_speech.dart';

class WordForm extends StatefulWidget {
  final String? initialExpression;
  final List<Definition>? initialDefinitions;
  final String errorMessage;
  final void Function(String expression, List<Definition> definitions, List<Definition> removedDefinitions) onSave;
  final VoidCallback onCancel;
  final String title;
  final String submitLabel;
  final Color themeColor;

  const WordForm({
    super.key,
    this.initialExpression,
    this.initialDefinitions,
    required this.errorMessage,
    required this.onSave,
    required this.onCancel,
    required this.title,
    required this.submitLabel,
    this.themeColor = const Color(0xFF43A047), // Green 600
  });

  @override
  State<WordForm> createState() => _WordFormState();
}

class _WordFormState extends State<WordForm> {
  final _expressionController = TextEditingController();
  final List<TextEditingController> _definitionControllers = [];
  final List<Definition> _definitions = [];
  final List<Definition> _removedDefinitions = [];

  @override
  void initState() {
    super.initState();
    _expressionController.text = widget.initialExpression ?? '';
    if (widget.initialDefinitions != null && widget.initialDefinitions!.isNotEmpty) {
      for (var def in widget.initialDefinitions!) {
        _definitions.add(def);
        _definitionControllers.add(TextEditingController(text: def.meaning));
      }
    } else {
      _addDefinition();
    }
  }

  void _addDefinition() {
    setState(() {
      _definitions.add(Definition(id: '', meaning: '', part: PartOfSpeech.NOUN));
      _definitionControllers.add(TextEditingController());
    });
  }

  void _removeDefinition(int index) {
    setState(() {
      final def = _definitions[index];
      if (def.id.isNotEmpty) {
        _removedDefinitions.add(def);
      }
      _definitions.removeAt(index);
      _definitionControllers[index].dispose();
      _definitionControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    _expressionController.dispose();
    for (var controller in _definitionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.themeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.translate_rounded, color: widget.themeColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildFieldLabel('단어'),
              const SizedBox(height: 8),
              TextField(
                controller: _expressionController,
                decoration: _buildInputDecoration('추가할 단어를 입력하세요'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (widget.errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 4),
                  child: Text(
                    widget.errorMessage,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFieldLabel('뜻 목록'),
                  TextButton.icon(
                    onPressed: _addDefinition,
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                    label: const Text('뜻 추가'),
                    style: TextButton.styleFrom(
                      foregroundColor: widget.themeColor,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...List.generate(_definitions.length, (index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _definitionControllers[index],
                              onChanged: (value) {
                                _definitions[index] = Definition(
                                  id: _definitions[index].id,
                                  meaning: value,
                                  part: _definitions[index].part,
                                );
                              },
                              decoration: const InputDecoration(
                                hintText: '뜻을 입력하세요',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (_definitions.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent, size: 20),
                              onPressed: () => _removeDefinition(index),
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                      const Divider(height: 12),
                      Row(
                        children: [
                          const Text('품사:', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          DropdownButton<PartOfSpeech>(
                            value: _definitions[index].part,
                            underline: const SizedBox(),
                            isDense: true,
                            items: PartOfSpeech.values.map((pos) {
                              return DropdownMenuItem(
                                value: pos,
                                child: Text(
                                  pos.label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: widget.themeColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _definitions[index] = Definition(
                                    id: _definitions[index].id,
                                    meaning: _definitions[index].meaning,
                                    part: newValue,
                                  );
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: widget.onCancel,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        '취소',
                        style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => widget.onSave(
                        _expressionController.text.trim(),
                        _definitions,
                        _removedDefinitions,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.themeColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        widget.submitLabel,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade700,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: widget.themeColor, width: 2),
      ),
    );
  }
}
