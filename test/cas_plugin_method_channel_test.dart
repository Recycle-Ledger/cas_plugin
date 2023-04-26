import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cas_plugin/cas_plugin_method_channel.dart';

void main() {
  MethodChannelCasPlugin platform = MethodChannelCasPlugin();
  const MethodChannel channel = MethodChannel('cas_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
