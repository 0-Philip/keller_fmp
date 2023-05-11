import 'package:applshelf_client/app_manager.dart';
import 'package:applshelf_client/appshelf_serial.dart';

void main() {
  final manager = AppManager();
  getSerialConnection(portContains: 'usbserial')
      .stream
      .listen(getDataProcessCallback(manager));
  print("makin connection");
}
