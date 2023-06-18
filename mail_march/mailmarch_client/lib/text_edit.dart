import 'package:mailmarch_client/attachment_button.dart';
import 'package:mailmarch_client/envelopes_flutter.dart';
import 'package:mailmarch_client/scrollable_text_field.dart';
import 'package:mailmarch_client/view_model.dart';
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
  late TextEditingController _ccController;
  late TextEditingController _bccController;
  @override
  void initState() {
    super.initState();
    var envelopeManager = context.read<EnvelopeManager>();
    _toController = TextEditingController();
    _subjectController = TextEditingController();
    _ccController = TextEditingController();
    _bccController = TextEditingController();
    envelopeManager.addListener(() {
      _toController.text = envelopeManager.activeEnvelope?.to ?? "";
      _subjectController.text = envelopeManager.activeEnvelope?.subject ?? "";
      _ccController.text = envelopeManager.activeEnvelope?.cc ?? "";
      _bccController.text = envelopeManager.activeEnvelope?.bcc ?? "";
    });
    _toController.addListener(() {
      envelopeManager.activeEnvelope?.to = _toController.text;
    });

    _subjectController.addListener(() {
      envelopeManager.activeEnvelope?.subject = _subjectController.text;
    });

    _ccController.addListener(() {
      envelopeManager.activeEnvelope?.cc = _ccController.text;
    });

    _bccController.addListener(() {
      envelopeManager.activeEnvelope?.bcc = _bccController.text;
    });
  }

  @override
  void dispose() {
    _toController.dispose();
    _subjectController.dispose();
    _ccController.dispose();
    _bccController.dispose();
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
                  child: Column(
                    children: [
                      Row(
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
                          AttachmentButton(),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      if (context.watch<ViewModel>().shouldShowCcBcc)
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                  controller: _ccController,
                                  decoration: const InputDecoration(
                                    label: Text("Cc: "),
                                    filled: true,
                                  )),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              //Subject

                              child: TextFormField(
                                controller: _bccController,
                                decoration: const InputDecoration(
                                  label: Text("Bcc: "),
                                  filled: true,
                                ),
                              ),
                            ),
                          ],
                        )
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
