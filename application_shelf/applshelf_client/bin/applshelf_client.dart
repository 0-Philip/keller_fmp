import 'package:applshelf_client/app_manager.dart';
import 'package:applshelf_client/appshelf_serial.dart';

void main() {
  final manager = AppManager();
  Future.delayed(Duration(seconds: 3)).then((_) {
    getSerialConnection(portContains: 'usbserial-1210')
        .stream
        .listen(getDataProcessCallback(manager));
    print("makin connection");
  });
}
