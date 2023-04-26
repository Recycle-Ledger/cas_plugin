import 'package:cas_plugin/cas_device_weight_listener.dart';
import 'package:cas_plugin/cas_scan_device_listener.dart';
import 'package:cas_plugin/ic_device.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:cas_plugin/cas_plugin.dart';
import 'package:cas_plugin/ic_device.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> implements CasDeviceWeightListener, CasScanDeviceListener {
  final CasPlugin _casPlugin = CasPlugin();
  List<ICDevice> deviceList = [];
  String weight = '0.0';

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('cas plugin example'),
        ),
        body: Container(
          alignment: Alignment.center,
          width: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FilledButton(
                    onPressed: () async {
                      _casPlugin.init(listener: this);
                      Future.delayed(const Duration(milliseconds: 200));
                      _casPlugin.startScan(listener: this);
                    },
                    child: const Text(
                      'start scan'
                    ),
                  ),
                  FilledButton(
                    onPressed: () {
                      _casPlugin.dispose();
                    },
                    child: const Text(
                        'stop stream'
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '$weight KG',
                style: const TextStyle(
                  fontSize: 32.0,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(deviceList[index].macAddr),
                      onTap: () {
                        _casPlugin.selectDevice(device: deviceList[index]);
                        _casPlugin.stopScan();
                      },
                    );
                  },
                  itemCount: deviceList.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void checkPermission() async {
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
  }

  @override
  void onDeviceWeightValue(double weight, bool fixed) {
    setState(() {
      this.weight = weight.toStringAsFixed(1);
    });
  }

  @override
  void onScannedDeviceList(List<ICDevice> deviceList) {
    setState(() {
      this.deviceList = deviceList;
    });
  }
}
