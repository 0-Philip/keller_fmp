import 'dart:io';

import 'package:a2i2/scripts_f.dart';
import 'package:flutter/widgets.dart';

class Envelopes with ChangeNotifier {
  EnvelopeForFlutter? activeEnvelope;
  final Map<String, EnvelopeForFlutter> _drafts = {};

  void execute(String? command, String? target) {
    final commands = {
      "reopen": reopen,
      "close": close,
      "send": send,
      "create": create,
    };
    if (commands.containsKey(command)) commands[command]!(target ?? "");
  }

  void create(String id) {
    if (_drafts.containsKey(id)) {
      reopen(id);
    } else {
      activeEnvelope = EnvelopeForFlutter();
      notifyListeners();
    }
  }

  void close(String id) {
    if (!_drafts.containsKey(id) && activeEnvelope != null) {
      _drafts[id] = activeEnvelope!;
    }
    activeEnvelope = null;
    notifyListeners();
  }

  void send(String id) {
    _drafts.remove(id)?._send();
    notifyListeners();
  }

  void reopen(String id) {
    activeEnvelope = _drafts[id];
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }
}

class EnvelopeForFlutter {
  static String? _senderId;

  static String? get senderId {
    return _senderId;
  }

  static void set senderId(String? value) {
    _senderId = value?.trim();
  }

  String? _bcc;

  String? get bcc {
    return _bcc;
  }

  void set bcc(String? bcc) {
    _bcc = bcc?.trim();
  }

  String? subject;

  String? _to;
  String? get to {
    return _to;
  }

  void set to(String? to) {
    _to = to?.trim();
  }

  String? _cc;

  String? get cc {
    return _cc;
  }

  void set cc(String? cc) {
    _cc = cc?.trim();
  }

  List<String> attachments = <String>[];
  EnvelopeForFlutter();
  late final String fileName;
  String? messageBody;

  void _send() async {
    if (to != null && subject != null) {
      var sendCommand = sendEmail(
        senderID: EnvelopeForFlutter.senderId!,
        toRecipient: to!,
        subject: subject!,
        ccRecipient: cc,
        bccRecipient: bcc,
        body: messageBody ?? " ",
        attachmentPaths: attachments,
      );
      var p = await Process.run('osascript', ['-e', sendCommand]);
      print(p.stderr);
      print(sendCommand);
    } else {
      print("to or subject was null");
    }
  }
}
