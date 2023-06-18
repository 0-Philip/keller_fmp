import 'dart:io';

import 'package:a2i2/scripts_f.dart';
import 'package:a2i2/system_menu.dart';
import 'package:a2i2/text_edit.dart';
import 'package:a2i2/view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:provider/provider.dart';

import 'a2i2_serial.dart';
import 'envelopes_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();
  await Window.setEffect(effect: WindowEffect.acrylic);
  Window.makeTitlebarTransparent();
  Window.enableFullSizeContentView();
  runApp(
    ChangeNotifierProvider<EnvelopeManager>(
      create: (context) => EnvelopeManager(),
      child: ChangeNotifierProvider<ViewModel>(
          create: (context) => ViewModel(), child: const MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MailMarchMenu(
      child: MyHomePage(title: "Main Window"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    getSerialConnection(portContains: 'usbserial')
        .stream
        .listen(getDataProcessCallback(context.read<EnvelopeManager>()));
    chooseMailAccount(context);
  }

  @override
  Widget build(BuildContext context) {
    var currentEnvelope = context.watch<EnvelopeManager>().activeEnvelope;

    return Stack(
      alignment: AlignmentDirectional.center,
      fit: StackFit.loose,
      clipBehavior: Clip.antiAlias,
      children: [
        AnimatedPositioned(
          child: const SizedBox(
            width: 500,
            height: 300,
            child: TextEditor(),
          ),
          top: currentEnvelope == null ? -320 : 50,
          curve: Curves.easeOutCirc,
          duration: const Duration(milliseconds: 600),
        ),
      ],
    );
  }
}

void chooseMailAccount(BuildContext context) {
  Process.run('osascript', ['-e', getMailAccount]).then((p) {
    EnvelopeForFlutter.senderId = p.stdout;
    print(EnvelopeForFlutter.senderId);
    context.read<EnvelopeManager>().refresh();
  });
}
