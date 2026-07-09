import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;
  final TextStyle? highlightStyle;
  final int? maxLines;
  final TextOverflow overflow;

  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    required this.style,
    this.highlightStyle,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty || text.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final lowercaseText = text.toLowerCase();
    final lowercaseQuery = query.toLowerCase();

    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final index = lowercaseText.indexOf(lowercaseQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start), style: style));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: style));
      }

      final matchText = text.substring(index, index + query.length);
      spans.add(TextSpan(
        text: matchText,
        style: highlightStyle ??
            style.copyWith(
              backgroundColor: Colors.yellow.withValues(alpha: 0.3),
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
      ));

      start = index + query.length;
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
