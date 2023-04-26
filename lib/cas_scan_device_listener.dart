import 'package:cas_plugin/ic_device.dart';

abstract class CasScanDeviceListener {
  void onScannedDeviceList(List<ICDevice> deviceList);
}