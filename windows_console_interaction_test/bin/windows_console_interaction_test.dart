import 'dart:io';

void main() async {
  var p = await Process.start(
    'powershell',
    [],
    runInShell: true,
  ).then((process) {
    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);
    process.stdin.writeln('pwd');
  });
}
