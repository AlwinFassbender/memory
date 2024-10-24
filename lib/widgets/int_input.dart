import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberInputField extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final int initialValue;
  final void Function(int) onChanged;

  const NumberInputField({
    super.key,
    this.minValue = 1,
    this.maxValue = 50,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  createState() => _NumberInputFieldState();
}

class _NumberInputFieldState extends State<NumberInputField> {
  late int _value = widget.initialValue;
  late final _textEditingController = TextEditingController(text: _value.toString());

  void _onMinus() {
    setState(() {
      _value = (_value > widget.minValue) ? _value - 1 : widget.minValue;
      _textEditingController.text = _value.toString();
    });
    widget.onChanged(_value);
  }

  void _onPlus() {
    setState(() {
      _value = (_value < widget.maxValue) ? _value + 1 : widget.maxValue;
      _textEditingController.text = _value.toString();
    });
    widget.onChanged(_value);
  }

  void _onChanged(String value) {
    int? intValue = int.tryParse(value);
    if (intValue != null && intValue >= widget.minValue && intValue <= widget.maxValue) {
      setState(() {
        _value = intValue;
        _textEditingController.text = _value.toString();
      });
      widget.onChanged(_value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: _onMinus,
          icon: const Icon(Icons.remove, color: Colors.black),
        ),
        SizedBox(
          width: 60,
          child: TextFormField(
            controller: _textEditingController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            ),
            textAlign: TextAlign.center,
            onChanged: _onChanged,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ),
        IconButton(
          onPressed: _onPlus,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
