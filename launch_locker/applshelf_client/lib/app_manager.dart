import 'scripts.dart' as scripts;

class AppManager {
  void execute(String? command, String? target) {
    final commands = {
      "launch": launch,
      "quit": quit,
      "show": show,
      "minmiz": minimize,
    };
    if (commands.containsKey(command)) commands[command]!();
  }

  AppManager();

  final _appName = "Microsoft Word";

  void launch() {
    scripts.launch(_appName);
    Future.delayed(Duration(seconds: 1), minimize);
  }

  void quit() => scripts.quit(_appName);

  void show() => scripts.show(_appName);

  void minimize() => scripts.minimize(_appName);
}
