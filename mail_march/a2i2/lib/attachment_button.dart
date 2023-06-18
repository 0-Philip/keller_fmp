import 'package:a2i2/envelopes_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AttachmentButton extends StatefulWidget {
  const AttachmentButton({
    super.key,
  });

  @override
  State<AttachmentButton> createState() => _AttachmentButtonState();
}

class _AttachmentButtonState extends State<AttachmentButton> {
  var _isActive = true;

  void _whenFilesPicked(pickerResult) {
    setState(() {
      _isActive = true;
    });
    var attachments =
        context.read<EnvelopeManager>().activeEnvelope?.attachments;

    var paths = pickerResult?.paths.where((i) => i != null).toList();

    if (attachments != null) {
      paths?.forEach((path) {
        attachments.add(path!);
        context.read<EnvelopeManager>().refresh();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final attachmentCount =
        context.watch<EnvelopeManager>().activeEnvelope?.attachments.length;
    return Badge(
      alignment: AlignmentDirectional(35, 0),
      label: Text(attachmentCount.toString()),
      isLabelVisible: (attachmentCount ?? 0) > 0,
      child: SizedBox(
        width: 50,
        child: IconButton(
          // padding: EdgeInsets.symmetric(horizontal: 15),
          splashRadius: 25,
          onPressed: !_isActive
              ? null
              : () {
                  setState(() => _isActive = false);
                  FilePicker.platform.pickFiles().then(_whenFilesPicked);
                },
          icon: const Icon(Icons.attach_file),
        ),
      ),
    );
  }
}
