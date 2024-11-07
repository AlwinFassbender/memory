import 'package:flutter/material.dart';

class SliderAndNumberDisplay extends StatelessWidget {
  final String? displayValue;
  final String title;
  final double sliderValue;
  final void Function(double) onChanged;
  const SliderAndNumberDisplay({
    super.key,
    this.displayValue,
    required this.title,
    required this.sliderValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (displayValue != null) Text(displayValue!),
            Slider(
              value: sliderValue,
              onChanged: onChanged,
            ),
          ],
        ),
      ],
    );
  }
}
