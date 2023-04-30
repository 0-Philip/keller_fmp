import 'dart:io';

import 'scripts.dart';

class Envelopes {
  final Map<String, TextWindowEnvelope> _drafts = {};

  TextWindowEnvelope? activeEnvelope;

  void execute(String? command, String? target) {
    final commands = {
      "reopen": reopen,
      "close": close,
      "send": send,
      "create": create,
    };
    if (commands.containsKey(command)) commands[command]!(target ?? "");
  }

  void create(String _) {
    activeEnvelope = TextWindowEnvelope();
    activeEnvelope!
      .._create()
      .._open();
  }

  void close(String id) {
    if (!_drafts.containsKey(id) && activeEnvelope != null) {
      _drafts[id] = activeEnvelope!;
    }
    _drafts[id]?._close();
    activeEnvelope = null;
  }

  void send(String id) {
    if (_drafts.containsKey(id)) {
      _drafts[id]?._send();
      print("sending");
      _drafts.remove(id);
    }
  }

  void reopen(String id) {
    activeEnvelope = _drafts[id];
    _drafts[id]?._open();
  }
}

class TextWindowEnvelope implements Envelope {
  @override
  late final String fileName;

  TextWindowEnvelope() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    fileName = 'new_mail_$timestamp';
  }

  @override
  _create() async {
    await Process.run('cp', [
      'NewMailTemplate.txt',
      './emails/$fileName',
    ]);
  }

  @override
  void _close() async {
    final p = await Process.run(
        'osascript', ['-e', closeWindow(fileName, Directory.current.path)]);

    print(p.stderr);
  }

  @override
  void _send() async {}
  @override
  void _open() async {
    await Process.run('open', ['-e', './emails/$fileName']);
  }

  @override
  String? bcc;

  @override
  String? cc;

  @override
  late String subject;

  @override
  late String to;
}

abstract class Envelope {
  void _close();
  void _send();
  void _open();
  String get fileName;
  void _create() {}
  late String to;
  late String subject;
  String? cc;
  String? bcc;
}

void main() async {
  final envelopes = Envelopes();

  var commands = {
    "reopen": envelopes.reopen,
    "close": envelopes.close,
    "send": envelopes.send,
    "create": envelopes.create,
  };
  var testId = "sen";
  if (commands.containsKey(testId)) {
    commands[testId]!("yg");
  }

  var process = await Process.run('osascript', ['-e', getMailAccount]);

  String senderId = process.stdout;
  print(senderId);

  String emailcommand = sendEmail(
    senderID: senderId.trim(),
    toRecipient: 'philipugk@icloud.com',
    subject: 'multi-line testing-ish',
    ccRecipient: 'philipugk@gmail.com',
    body: '''
hooing to get be able to send stuff!
It seems like I needed to trim the Strings...
      
      ''',
  );

  var process8 = await Process.run('osascript', ['-e', emailcommand]);
  print(process8.stderr);

  envelopes.create("");
  Future.delayed(Duration(seconds: 5), () {
    envelopes.close("MG");
  });
}
