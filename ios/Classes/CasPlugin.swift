import Flutter
import UIKit
import ICDeviceManager

var scanSink: FlutterEventSink? = nil
var streamSink: FlutterEventSink? = nil

public class CasPlugin: NSObject, FlutterPlugin, ICDeviceManagerDelegate, ICScanDeviceDelegate {
    public func onInitFinish(_ bSuccess: Bool) {
        
    }
    
    public func onReceiveWeightData(_ device: ICDevice!, data: ICWeightData!) {
        if let sink = streamSink {
            sink(data.weight_kg)
        }
    }
    
    public func onScanResult(_ deviceInfo: ICScanDeviceInfo!) {
        if (!compareDevice(device: deviceInfo)) {
            scanList.append(deviceInfo)
        }
        
        if let sink = scanSink {
            do {
                for device in scanList {
                    let input: ICDeviceConvert = ICDeviceConvert(name: device.name!, macAddr: device.macAddr!)
                    let encoder = JSONEncoder()
                    let data = try encoder.encode(input)
                    let jsonString = String(data: data, encoding: .utf8)
                    
                    sink(jsonString)
                }
            } catch {
                print(error)
            }
        }
    }
    
    static let CHANNEL: String = "cas_plugin"
    static let SCAN_EVENT: String = "cas_scan"
    static let STREAM_EVENT: String = "cas_stream"
    
    var scanList: Array<ICScanDeviceInfo> = [ICScanDeviceInfo]()
    
    // SDK Variable
    let device: ICDevice = ICDevice()
    let config: ICDeviceManagerConfig = ICDeviceManagerConfig()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: registrar.messenger())
        let instance = CasPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        FlutterEventChannel(name: SCAN_EVENT, binaryMessenger: registrar.messenger()).setStreamHandler(ScanStreamHandler())
        
        FlutterEventChannel(name: STREAM_EVENT, binaryMessenger: registrar.messenger()).setStreamHandler(DataStreamHandler())
        
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "init":
            self.initSDK()
        case "startScan":
            self.startScan()
        case "stopScan":
            self.stopScan()
        case "selectDevice":
            self.selectDevice(macAddr: call.arguments as! String)
        default:
            return
        }
    }
    
    private func initSDK() {
        ICDeviceManager.shared().delegate = self
        ICDeviceManager.shared().initMgr(with: config)
    }
    
    private func startScan() {
        ICDeviceManager.shared().scanDevice(self)
    }
    
    private func stopScan() {
        ICDeviceManager.shared().stopScan()
    }
    
    private func selectDevice(macAddr: String) {
        device.macAddr = macAddr
        ICDeviceManager.shared().remove(
            device,
            callback: {(device, code) in return}
        )
        
        device.macAddr = macAddr
        
        ICDeviceManager.shared().add(
            device,
            callback: {(device, code) in return}
        )
        ICDeviceManager.shared().getSettingManager().setScaleUnit(
            device,
            unit: ICWeightUnit.kg, callback: {(code) in return}
        )
        
    }
    
    private func compareDevice(device: ICScanDeviceInfo) -> Bool {
        for scanDevice in scanList {
            return scanDevice.macAddr == device.macAddr
        }
        return false
    }
}

class ScanStreamHandler: NSObject, FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        scanSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        scanSink = nil
        return nil
    }
}

class DataStreamHandler: NSObject, FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        streamSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        streamSink = nil
        return nil
    }
    
    
}
