import 'package:a2i2/attachment_button.dart';
import 'package:a2i2/envelopes_flutter.dart';
import 'package:a2i2/scrollable_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TextEditor extends StatefulWidget {
  const TextEditor({super.key});

  @override
  State<TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  late TextEditingController _toController;
  late TextEditingController _subjectController;

  @override
  void initState() {
    super.initState();
    var envelopeManager = context.read<Envelopes>();
    _toController = TextEditingController();
    _subjectController = TextEditingController();
    envelopeManager.addListener(() {
      _toController.text = envelopeManager.activeEnvelope?.to ?? "";
      _subjectController.text = envelopeManager.activeEnvelope?.subject ?? "";
    });
    _toController.addListener(() {
      envelopeManager.activeEnvelope?.to = _toController.text;
    });

    _subjectController.addListener(() {
      envelopeManager.activeEnvelope?.subject = _subjectController.text;
    });
  }

  @override
  void dispose() {
    _toController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Form(
        child: Card(
          elevation: 20,
          child: Column(
            children: [
              Expanded(
                child: ScrollableTextField(),
              ),
              Card(
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        // To
                        flex: 3,
                        child: TextFormField(
                          controller: _toController,
                          decoration: const InputDecoration(
                            label: Text("To: "),
                            filled: true,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        //Subject
                        flex: 2,
                        child: TextFormField(
                          controller: _subjectController,
                          decoration: const InputDecoration(
                            label: Text("Subject: "),
                            filled: true,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      AttachmentButton()
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
