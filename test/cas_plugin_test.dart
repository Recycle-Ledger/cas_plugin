import 'package:flutter_test/flutter_test.dart';
import 'package:cas_plugin/cas_plugin.dart';
import 'package:cas_plugin/cas_plugin_platform_interface.dart';
import 'package:cas_plugin/cas_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCasPluginPlatform
    with MockPlatformInterfaceMixin
    implements CasPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final CasPluginPlatform initialPlatform = CasPluginPlatform.instance;

  test('$MethodChannelCasPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCasPlugin>());
  });

  test('getPlatformVersion', () async {
    CasPlugin casPlugin = CasPlugin();
    MockCasPluginPlatform fakePlatform = MockCasPluginPlatform();
    CasPluginPlatform.instance = fakePlatform;

    expect(await casPlugin.getPlatformVersion(), '42');
  });
}
