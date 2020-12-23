import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xinstall_flutter_plugin/xinstall_flutter_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('xinstall_flutter_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

}
