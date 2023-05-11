import 'dart:io';

Future<void> launch(String appName) async {
  var script = ''' 
  tell application "$appName"
  create new document
	activate
	end tell
  ''';

  var p = await Process.run('osascript', ['-e', script]);
  print(p.stderr);
}

Future<void> quit(String appName) async {
  var script = ''' 
  tell application "$appName"
	quit
	end tell
  ''';

  var p = await Process.run('osascript', ['-e', script]);
  print(p.stderr);
}

Future<void> minimize(String appName) async {
  var script = ''' 
  tell application "$appName"
  activate
	set collapsed of every window to true
	end tell
  ''';

  var p = await Process.run('osascript', ['-e', script]);
  print(p.stderr);
}

Future<void> show(String appName) async {
  var script = ''' 
  tell application "$appName"
  activate
	set collapsed of every window to false
	end tell
  ''';

  var p = await Process.run('osascript', ['-e', script]);
  print(p.stderr);
}

void main(List<String> args) async {
  minimize("Microsoft Word");
}
