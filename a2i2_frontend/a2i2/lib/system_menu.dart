import 'package:a2i2/envelopes_flutter.dart';
import 'package:a2i2/main.dart';
import 'package:a2i2/view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MailMarchMenu extends StatelessWidget {
  const MailMarchMenu({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    var activeEnvelope = context.watch<EnvelopeManager>().activeEnvelope;
    var viewModel = context.watch<ViewModel>();
    return MaterialApp(
      home: PlatformMenuBar(
        menus: <PlatformMenuItem>[
          PlatformMenu(
            label: "Main",
            menus: <PlatformMenuItem>[
              PlatformMenuItemGroup(
                members: [PlatformMenuItem(label: "MailMatch")],
              ),
            ],
          ),
          PlatformMenu(label: "Attachments", menus: [
            PlatformMenuItem(
              label: "Clear Attachments",
              onSelected: (activeEnvelope?.attachments.isNotEmpty ?? false)
                  ? () {
                      activeEnvelope?.attachments = [];
                      context.read<EnvelopeManager>().refresh();
                    }
                  : null,
            ),
          ]),
          PlatformMenu(
            label: "Account",
            menus: [
              PlatformMenuItem(
                  label: EnvelopeForFlutter.senderId ?? "No Sender ID"),
              PlatformMenuItemGroup(members: [
                PlatformMenuItem(
                  label: "Change Account",
                  onSelected: () {
                    chooseMailAccount(context);
                    // context.read<Envelopes>().refresh();
                  },
                )
              ]),
            ],
          ),
          PlatformMenu(label: "View", menus: [
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label:
                      "${viewModel.shouldShowCcBcc ? "Hide" : "Show"} Cc and Bcc Fields",
                  onSelected: () =>
                      viewModel.shouldShowCcBcc = !viewModel.shouldShowCcBcc,
                ),
              ],
            ),
          ])
        ],
        child: child,
      ),
      title: "MailMarch",
    );
  }
}
