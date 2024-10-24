import 'package:flutter/material.dart';
import 'package:memory/classes/player.dart';
import 'package:memory/widgets/slider.dart';

class PlayerOptionsWidget extends StatelessWidget {
  final int playerIndex;
  final void Function(PlayerOptions) onOptionsChanged;
  final PlayerOptions initialOptions;
  final void Function()? onPlayerRemoved;

  const PlayerOptionsWidget({
    super.key,
    required this.playerIndex,
    required this.onOptionsChanged,
    required this.initialOptions,
    required this.onPlayerRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text("Player ${playerIndex + 1} Options"),
            if (onPlayerRemoved != null)
              IconButton(
                onPressed: onPlayerRemoved,
                icon: const Icon(Icons.delete),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _OptionCheckboxField(
          title: "Human player",
          initialValue: initialOptions.human,
          onChanged: _onHumanChanged,
        ),
        const SizedBox(height: 16),
        _OptionCheckboxField(
          title: "Use optimal strategy",
          initialValue: initialOptions.useOptimalStrategy,
          onChanged: _onOptimalStrategyChanged,
        ),
        const SizedBox(height: 16),
        SliderAndNumberDisplay(
          title: "Memory chance",
          sliderValue: initialOptions.memoryChance,
          onChanged: _onMemoryChanceChanged,
        ),
      ],
    );
  }

  void _onOptimalStrategyChanged(bool? value) {
    onOptionsChanged(
      initialOptions.copyWith(useOptimalStrategy: value ?? false),
    );
  }

  void _onMemoryChanceChanged(double value) {
    onOptionsChanged(
      initialOptions.copyWith(memoryChance: value),
    );
  }

  void _onHumanChanged(bool? value) {
    onOptionsChanged(
      initialOptions.copyWith(human: value ?? false),
    );
  }
}

class _OptionCheckboxField extends StatefulWidget {
  final void Function(bool?) onChanged;
  final bool initialValue;
  final String title;
  const _OptionCheckboxField({
    required this.onChanged,
    required this.initialValue,
    required this.title,
  });

  @override
  State<_OptionCheckboxField> createState() => _OptionCheckboxFieldState();
}

class _OptionCheckboxFieldState extends State<_OptionCheckboxField> {
  late bool value = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: (value) {
            setState(() {
              this.value = value ?? false;
            });
            widget.onChanged(value);
          },
        ),
        Text(widget.title),
      ],
    );
  }
}
