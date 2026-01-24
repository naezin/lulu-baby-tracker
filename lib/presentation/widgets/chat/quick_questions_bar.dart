import 'package:flutter/material.dart';
import '../../providers/chat_provider.dart';

/// 빠른 질문 선택 바
class QuickQuestionsBar extends StatelessWidget {
  final Function(QuickQuestion) onQuestionSelected;

  const QuickQuestionsBar({
    Key? key,
    required this.onQuestionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final templates = QuickQuestions.getTemplates(context);

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final question = templates[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _QuickQuestionChip(
              question: question,
              onTap: () => onQuestionSelected(question),
            ),
          );
        },
      ),
    );
  }
}

class _QuickQuestionChip extends StatelessWidget {
  final QuickQuestion question;
  final VoidCallback onTap;

  const _QuickQuestionChip({
    required this.question,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                question.icon,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Text(
                question.text,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
