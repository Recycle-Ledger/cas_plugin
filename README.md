# cas_plugin

Use CasScale native SDK in flutter
Measurement only weight

## Preparing setting

### Android

- AndroidManifext.xml
```
<!-- Request legacy Bluetooth permissions on older devices. -->
<uses-permission android:name="android.permission.BLUETOOTH"
    android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN"
    android:maxSdkVersion="30" />

<!-- Needed only if your app looks for Bluetooth devices.
     If your app doesn't use Bluetooth scan results to derive physical
     location information, you can strongly assert that your app
     doesn't derive physical location. -->
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />

<!-- Needed only if your app communicates with already-paired Bluetooth
     devices. -->
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
```

### IOS

- Runner/Info.plist
```
<!-- Permission options for the `bluetooth` -->
<key>NSBluetoothAlwaysUsageDescription</key>
<string>bluetooth</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>bluetooth</string>
```