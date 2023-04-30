import 'package:a2i2/envelopes_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScrollableTextField extends StatefulWidget {
  const ScrollableTextField({
    super.key,
  });

  @override
  State<ScrollableTextField> createState() => _ScrollableTextFieldState();
}

class _ScrollableTextFieldState extends State<ScrollableTextField> {
  late TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    var envelopeManager = context.read<Envelopes>();

    _bodyController = TextEditingController();
    envelopeManager.addListener(() {
      _bodyController.text = envelopeManager.activeEnvelope?.messageBody ?? "";
    });
    _bodyController.addListener(() {
      envelopeManager.activeEnvelope?.messageBody = _bodyController.text;
    });
  }

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextFormField(
          controller: _bodyController,
          decoration: const InputDecoration(
            hintText: "Write your email here...",
            border: InputBorder.none,
          ),
          keyboardType: TextInputType.multiline,
          maxLines: null,
          minLines: 2,
        ),
      ),
    );
  }
}
