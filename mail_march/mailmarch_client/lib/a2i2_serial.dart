import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_libserialport/flutter_libserialport.dart';

import 'envelopes_flutter.dart';

SerialPortReader getSerialConnection({
  required final String portContains,
  final int baudRate = 9600,
}) {
  final portName = SerialPort.availablePorts.firstWhere(
    (element) => element.contains(portContains),
    orElse: () => '',
  );

  print(portName);

  final port = SerialPort(portName);
  if (!port.openReadWrite()) {
    print(SerialPort.lastError);
    print("Aur naur!");
    exit(-1);
  }

  port.config = SerialPortConfig()
    ..baudRate = baudRate
    ..bits = 8
    ..parity = 0;

  return SerialPortReader(port);
}

void Function(Uint8List) getDataProcessCallback(
    EnvelopeManager envelopeManager) {
  return (Uint8List event) {
    final text = String.fromCharCodes(event);
    final regex = RegExp(r'(.*?)/?([a-z]+)');
    print(text);
    final command = regex.firstMatch(text)?.group(2);
    final target = regex.firstMatch(text)?.group(1);
    envelopeManager.execute(command, target);
  };
}
