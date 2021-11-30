//
//  BleController.swift
//  Stand Up Pls Simple
//
//  Created by Billy W on 2020/10/21.
//  Copyright © 2020 Jia-Xing Li. All rights reserved.
//

import Foundation
import CoreBluetooth

enum BtStage:Int {
    case init_value = 0
    case connecting = 1
    case processing = 2
    case is_connect = 3
    case notify_ok = 4
    case function_ok = 5
    case reconnect = 6
    case manual_disconnect = 7
    case disconnected = 8
    case auto_connect = 9
    case failure = -1
    case dismiss = -2
}

protocol BleDeviceRecognize {
    func foundNewDevice(_ peripheral: CBPeripheral)
    func dataReceived(_ data: Data)
    func postLog(_ data: Data)
}

class BleController : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    private let tag = "BleController"
    public var bleDeviceRecognize : BleDeviceRecognize?
    static let sharedInstance = BleController()
    
    private let saveTool = SaveTool.sharedInstance
    public var centralManager: CBCentralManager?
    public var peripheral: CBPeripheral?
    public var characteristic: CBCharacteristic?
    var debug_flag: LiveData<Bool> = LiveData(false)
    var debug_received: LiveData<String> = LiveData("")
    var debug_command: LiveData<String> = LiveData("")
    var bt_stage: LiveData<BtStage> = LiveData(BtStage.init_value)
    var bt_state: LiveData<CBManagerState> = LiveData(CBManagerState.unknown)
    
    private var BT_name : String = ""
    private var secondTimer: Timer?
    private var secondCount : Int = 0
    private var reconnectAction : [Int] = [0,0] // index 0 is enable, 1 is current count
    
    private override init() {
        super.init()
        centralManager = CBCentralManager.init(delegate: self, queue: .main)
    }
    deinit {
        stopSecondTimer()
    }
    func set_bt_init()
    {
        print(tag,"set_bt_init..")
        centralManager = CBCentralManager.init(delegate: self, queue: .main)
    }
    func set_bt_stage(data:BtStage)
    {
        bt_stage.value = data
        print(tag,"set_bt_stage:\(bt_stage.value)")
    }
    func get_bt_stage()->BtStage
    {
        return bt_stage.value
    }
    func set_bt_state(data:CBManagerState)
    {
        bt_state.value = data
        print(tag,"set_bt_state:\(bt_state.value.rawValue)")
    }
    func get_bt_state()->CBManagerState
    {
        return bt_state.value
    }
    func setSecondTimer(){
        if secondTimer == nil {
            secondTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.secondTimerFunc), userInfo: nil, repeats: true)
        }
    }
    
    @objc func secondTimerFunc(){
        secondCount += 1
        // reconnect
        if reconnectAction[0] == 1{
            reconnectAction[1] += 1
            if reconnectAction[1] % 5 == 0{ // reconnect every half sec
                connect(peripheral: peripheral!)
                stopSecondTimer()
            }
        }
    }
    
    func stopSecondTimer(){
        if secondTimer != nil{
            secondTimer?.invalidate()
            secondTimer = nil
        }
    }
    
    func startScan(){
        centralManager?.stopScan()
        print(tag,"startScan")
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }
    func stopScan(){
        centralManager?.stopScan()
        print(tag,"stopScan")
    }
    func setPeripheral(peripheral: CBPeripheral){
        self.peripheral = peripheral
    }
    func connect(peripheral : CBPeripheral){
        centralManager?.stopScan()//stop scanning for peripherals
        print(tag,"connecting")
        bt_stage.value = .connecting
        centralManager?.connect(peripheral , options: nil)
    }
    func connect(){
        centralManager?.stopScan()//stop scanning for peripherals
        print(tag,"connecting")
        bt_stage.value = .connecting
        centralManager?.connect(self.peripheral!, options: nil)
    }
    func getConnectedBtName()->String{
        return BT_name
    }
    
    func disconnect(){
        if peripheral != nil{
            print(tag,"disconnect")
            centralManager?.cancelPeripheralConnection(peripheral!)
        }
    }
    
    func postDataToTRF2(data : [UInt8]){
        let writeData = Data.init(_: data)
        bleDeviceRecognize!.postLog(writeData)
        /*if debug_flag.value
        {
            debug_command.value=""
            for i in 0..<data.count
            {
                debug_command.value="\(debug_command.value) \(String(format: "%02X",data[i]))"
            }
            print(debug_command.value)
        }*/
        self.peripheral?.writeValue(writeData, for: self.characteristic!,type: CBCharacteristicWriteType.withResponse)
    }
    
    // check bluetooth status
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("unknown")
        case .resetting:
            print("resetting")
        case .unsupported:
            print("unsupported")
        case .unauthorized:
            print("unauthorized")
        case .poweredOff:
            print("poweredOff")
        case .poweredOn:
            print("scan")
            //central.scanForPeripherals(withServices: [CBUUID.init(string: Service_UUID)], options: nil)
            central.scanForPeripherals(withServices: nil, options: nil)
        default:
            print("unknown")
        }
        set_bt_state(data: central.state)
    }
    
    /** check device */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        bleDeviceRecognize?.foundNewDevice(peripheral)
    }
    
    /** 连接成功 */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        bt_stage.value = .is_connect
        print("didConnect bt_stage:\(bt_stage)")
        centralManager?.stopScan()
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        saveTool.writeParams(name: "tapToDisconnect_flag", data: false)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        bt_stage.value = .failure
        BT_name = ""
        //bleDeviceRecognize?.connecting(false)
        print("connect failure bt_stage:\(bt_stage)")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        bt_stage.value = .disconnected
        BT_name = ""
        print("disconnected bt_stage:\(bt_stage)")
    }
    
    /** services */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        //        print("didDiscoverServices")
        for service: CBService in peripheral.services! {
            if (service.uuid.uuidString == AHFBleConfig.Service_UUID) {
                print("find service：\(service)")
                peripheral.discoverCharacteristics(nil, for: service)
            }else{
                print("not support service：\(service)")
                saveTool.writeParams(name: "last_device", data: "")
            }
        }
    }
    
    /** characteristic */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        //        print("didDiscoverCharacteristicsFor")
        for characteristic: CBCharacteristic in service.characteristics! {
            if (characteristic.uuid.uuidString == AHFBleConfig.Characteristic_UUID1) { //properties: read, write ,Notify
                print("find TX characteristic：\(characteristic)")
                peripheral.setNotifyValue(true, for: characteristic) // notify enable
            }else if (characteristic.uuid.uuidString == AHFBleConfig.Characteristic_UUID2) { //properties: read, write
                print("find RX characteristic：\(characteristic)")
                self.characteristic = characteristic;                // write data
                self.peripheral = peripheral
            }else{
                print("not support characteristic：\(characteristic)")
                saveTool.writeParams(name: "last_device", data: "")
            }
        }
    }
    
    /** notify status */
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("notify failure: \(error)")
            return
        }
        if characteristic.isNotifying {
            BT_name = peripheral.name ?? ""
            print("notify success", BT_name)
            bt_stage.value = .notify_ok
        } else {
            print("notify disabled")
        }
    }
    
    
    /** receive data */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        bleDeviceRecognize?.dataReceived(characteristic.value!)
        //        var data : [String] = []
        //        for i in 0..<Int(characteristic.value!.count){
        //            data.append(String(format: "%02X",characteristic.value![i]))
        //        }
        //        print("received", data)
    }
}
