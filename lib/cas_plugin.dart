import 'dart:async';
import 'dart:convert';

import 'package:cas_plugin/cas_device_weight_listener.dart';
import 'package:cas_plugin/cas_scan_device_listener.dart';
import 'package:cas_plugin/ic_device.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class CasPlugin {
  static const tag = 'cas_plugin';
  final platform = const MethodChannel('cas_plugin');
  final scanChannel = const EventChannel('cas_scan');
  final streamChannel = const EventChannel('cas_stream');

  bool _isScanning = false;

  get isScanning => _isScanning;

  StreamSubscription? _streamSubscription;
  StreamSubscription? _scanSubscription;

  // Event callback listener
  CasScanDeviceListener? scanListener;
  CasDeviceWeightListener? weightListener;

  // Event data
  double _previousWeight = 0.0;
  double _weight = 0.0;
  int fixCount = 0;
  final List<ICDevice> _deviceList = [];

  void init({
    required CasDeviceWeightListener listener,
  }) {
    debugPrint('$tag - init');
    platform.invokeListMethod('init');
    weightListener = listener;
  }

  void dispose() {
    debugPrint('$tag - init');
    _isScanning = false;
    _weight = 0.0;
    _deviceList.clear();
    scanListener = null;
    weightListener = null;
    _streamSubscription?.cancel();
    _scanSubscription?.cancel();
  }

  void startScan({required CasScanDeviceListener listener}) {
    debugPrint('$tag - startScan');
    scanListener = listener;
    _isScanning = true;
    _scanSubscription = scanChannel.receiveBroadcastStream().listen(_listenScan);
    platform.invokeListMethod('startScan');
  }

  void stopScan() {
    debugPrint('$tag - stopScan');
    _isScanning = false;
    _scanSubscription?.cancel();
  }

  void selectDevice({required ICDevice device}) async {
    debugPrint('$tag - seleceDevice : ${device.macAddr}');
    platform.invokeMethod('selectDevice', device.macAddr);
    _streamSubscription = streamChannel.receiveBroadcastStream().listen(_listenStream);
    stopScan();
  }

  void _listenScan(dynamic value) {
    final item = ICDevice.fromMap(jsonDecode(value));
    if (!_deviceList.contains(item)) {
      _deviceList.add(item);
    }
    scanListener?.onScannedDeviceList(_deviceList);
  }

  void _listenStream(dynamic value) {
    _weight = value;
    if (_previousWeight == _weight) {
      fixCount++;
    } else {
      fixCount = 0;
    }
    _previousWeight = _weight;
    bool fixed = false;
    if (fixCount > 1) {
      fixed = true;
    }
    weightListener?.onDeviceWeightValue(_weight, fixed);
  }

  // Singleton patten
  factory CasPlugin() {
    return _casPlugin;
  }

  static final CasPlugin _casPlugin = CasPlugin._internal();

  CasPlugin._internal();
}
