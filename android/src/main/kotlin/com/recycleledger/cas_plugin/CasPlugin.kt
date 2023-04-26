package com.recycleledger.cas_plugin

import android.content.Context
import androidx.annotation.NonNull
import cn.icomon.icdevicemanager.ICDeviceManager
import cn.icomon.icdevicemanager.ICDeviceManagerDelegate
import cn.icomon.icdevicemanager.ICDeviceManagerSettingManager
import cn.icomon.icdevicemanager.model.data.ICCoordData
import cn.icomon.icdevicemanager.model.data.ICKitchenScaleData
import cn.icomon.icdevicemanager.model.data.ICRulerData
import cn.icomon.icdevicemanager.model.data.ICSkipData
import cn.icomon.icdevicemanager.model.data.ICWeightCenterData
import cn.icomon.icdevicemanager.model.data.ICWeightData
import cn.icomon.icdevicemanager.model.data.ICWeightHistoryData
import cn.icomon.icdevicemanager.model.device.ICDevice
import cn.icomon.icdevicemanager.model.device.ICDeviceInfo
import cn.icomon.icdevicemanager.model.device.ICScanDeviceInfo
import cn.icomon.icdevicemanager.model.device.ICUserInfo
import cn.icomon.icdevicemanager.model.other.ICConstant
import cn.icomon.icdevicemanager.model.other.ICDeviceManagerConfig
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** CasPlugin */
class CasPlugin : FlutterPlugin, MethodCallHandler {
    private val CHANNEL = "cas_plugin"
    private val SCAN_EVENT = "cas_scan"
    private val STREAM_EVENT = "cas_stream"

    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    private var scanSink: EventSink? = null
    private var streamSink: EventSink? = null

    private val scanList: ArrayList<ICScanDeviceInfo> = arrayListOf()

    private val gson: Gson = Gson()

    // SDK Variable
    val device = ICDevice()
    val config = ICDeviceManagerConfig()

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)

        EventChannel(flutterPluginBinding.binaryMessenger, SCAN_EVENT).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventSink?) {
                    scanSink = events
                }
                override fun onCancel(arguments: Any?) {
                    scanSink = null
                }
            }
        )
        EventChannel(flutterPluginBinding.binaryMessenger, STREAM_EVENT).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventSink?) {
                    streamSink = events
                }

                override fun onCancel(arguments: Any?) {
                    streamSink = null
                }
            }
        )
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "init" -> initSDK()
            "startScan" -> startScan()
            "stopScan" -> stopScan()
            "selectDevice" -> selectDevice(call.arguments as String)
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun initSDK() {
        config.context = context
        ICDeviceManager.shared().delegate = icDelegate
        ICDeviceManager.shared().initMgrWithConfig(config)
    }

    private fun startScan() {
        ICDeviceManager.shared().scanDevice {
            if (!compareDevice(it)) {
                scanList.add(it)
            }
            for (device in scanList) {
                scanSink?.success(gson.toJson(device))
            }
        }
    }

    private fun stopScan() {
        ICDeviceManager.shared().stopScan()
    }

    private fun selectDevice(macAddr: String) {
        ICDeviceManager.shared().removeDevice(device, ICConstant.ICRemoveDeviceCallBack { device, code ->
        })

        device.macAddr = macAddr

        ICDeviceManager.shared().addDevice(device, ICConstant.ICAddDeviceCallBack { device, code ->
        })
        ICDeviceManager.shared().settingManager.setScaleUnit(
            device,
            ICConstant.ICWeightUnit.ICWeightUnitKg,
            ICDeviceManagerSettingManager.ICSettingCallback {

            }
        )
    }

    private fun compareDevice(device: ICScanDeviceInfo): Boolean {
        for (scanDevice in scanList) {
            try {
                if (scanDevice.macAddr == device.macAddr) {
                    return true
                }
            } catch (e: ArrayIndexOutOfBoundsException) {
                return false
            }
        }
        return false
    }

    private val icDelegate = object : ICDeviceManagerDelegate {
        override fun onInitFinish(bSuccess: Boolean) {
        }

        override fun onBleState(state: ICConstant.ICBleState?) {
        }

        override fun onDeviceConnectionChanged(
            device: ICDevice?,
            state: ICConstant.ICDeviceConnectState?
        ) {
        }

        override fun onNodeConnectionChanged(
            device: ICDevice?,
            nodeId: Int,
            state: ICConstant.ICDeviceConnectState?
        ) {
        }

        override fun onReceiveWeightData(device: ICDevice?, data: ICWeightData?) {
            streamSink?.success(data?.weight_kg)
        }

        override fun onReceiveKitchenScaleData(device: ICDevice?, data: ICKitchenScaleData?) {
        }

        override fun onReceiveKitchenScaleUnitChanged(
            device: ICDevice?,
            unit: ICConstant.ICKitchenScaleUnit?
        ) {
        }

        override fun onReceiveCoordData(device: ICDevice?, data: ICCoordData?) {
        }

        override fun onReceiveRulerData(device: ICDevice?, data: ICRulerData?) {
        }

        override fun onReceiveRulerHistoryData(device: ICDevice?, data: ICRulerData?) {
        }

        override fun onReceiveWeightCenterData(device: ICDevice?, data: ICWeightCenterData?) {
        }

        override fun onReceiveWeightUnitChanged(device: ICDevice?, unit: ICConstant.ICWeightUnit?) {
        }

        override fun onReceiveRulerUnitChanged(device: ICDevice?, unit: ICConstant.ICRulerUnit?) {
        }

        override fun onReceiveRulerMeasureModeChanged(
            device: ICDevice?,
            mode: ICConstant.ICRulerMeasureMode?
        ) {
        }

        override fun onReceiveMeasureStepData(
            device: ICDevice?,
            step: ICConstant.ICMeasureStep?,
            data: Any?
        ) {
        }

        override fun onReceiveWeightHistoryData(device: ICDevice?, data: ICWeightHistoryData?) {
        }

        override fun onReceiveSkipData(device: ICDevice?, data: ICSkipData?) {
        }

        override fun onReceiveHistorySkipData(device: ICDevice?, data: ICSkipData?) {
        }

        override fun onReceiveBattery(device: ICDevice?, battery: Int, ext: Any?) {
        }

        override fun onReceiveUpgradePercent(
            device: ICDevice?,
            status: ICConstant.ICUpgradeStatus?,
            percent: Int
        ) {
        }

        override fun onReceiveDeviceInfo(device: ICDevice?, deviceInfo: ICDeviceInfo?) {
        }

        override fun onReceiveDebugData(device: ICDevice?, type: Int, obj: Any?) {
        }

        override fun onReceiveConfigWifiResult(
            device: ICDevice?,
            state: ICConstant.ICConfigWifiState?
        ) {
        }

        override fun onReceiveHR(device: ICDevice?, hr: Int) {
        }

        override fun onReceiveUserInfo(device: ICDevice?, userInfo: ICUserInfo?) {
        }

        override fun onReceiveRSSI(device: ICDevice?, rssi: Int) {
        }

    }
}
