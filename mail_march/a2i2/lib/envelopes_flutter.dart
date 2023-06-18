import 'dart:io';

import 'package:a2i2/parse_fields.dart';
import 'package:a2i2/scripts_f.dart';
import 'package:flutter/widgets.dart';

class EnvelopeManager with ChangeNotifier {
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

  void refresh() => notifyListeners();
}

class EnvelopeForFlutter {
  static String? _senderId;

  String? _rawCc;
  String? _rawBcc;

  static String? get senderId {
    return _senderId;
  }

  static void set senderId(String? value) {
    _senderId = value?.trim();
  }

  String? get bcc {
    return _rawBcc;
  }

  void set bcc(String? bcc) {
    _rawBcc = bcc;
  }

  String? subject;

  String? _rawTo;

  String? get to {
    return _rawTo;
  }

  List<String> get toRecipients {
    if (_rawTo != null) {
      return parseField(_rawTo!);
    } else {
      return [];
    }
  }

  List<String> get ccRecipients {
    if (_rawCc != null) {
      return parseField(_rawCc!);
    } else {
      return [];
    }
  }

  List<String> get bccRecipients {
    if (_rawBcc != null) {
      return parseField(_rawBcc!);
    } else {
      return [];
    }
  }

  void set to(String? to) {
    _rawTo = to;
  }

  String? get cc {
    return _rawCc;
  }

  void set cc(String? cc) {
    _rawCc = cc;
  }

  List<String> attachments = <String>[];
  EnvelopeForFlutter();
  String? messageBody;

  void _send() async {
    if (to != null && subject != null) {
      var sendCommand = sendEmail(
        senderID: EnvelopeForFlutter.senderId!,
        toRecipients: toRecipients,
        subject: subject!,
        ccRecipients: ccRecipients,
        bccRecipients: bccRecipients,
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
