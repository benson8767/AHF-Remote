//
//  ControlModel.swift
//  AHF Remote
//
//  Created by benson chan on 2021/10/28.
//

import Foundation
import UIKit
import CoreBluetooth

extension ControlModel:BleDeviceRecognize
{
    func foundNewDevice(_ peripheral: CBPeripheral) {
            var peripheralName = String(describing: peripheral.name)
            if peripheralName != "nil"
            {
                var bytes = Array(String(peripheral.name!).data(using: .utf8)!)
                if bytes.last == 17
                {
                    bytes.remove(at: bytes.count - 1)
                }
                peripheralName = String(bytes: bytes, encoding: String.Encoding.utf8)!
                //print("peripheral name:\(String(peripheral.name!)),bt_stage:\(bt_stage.value.rawValue)")
                if auto_connect && peripheralName == last_device
                {
                    print("direct last_device:\(String(peripheral.name!))")
                    bleController.peripheral = peripheral
                    saveTool.writeParams(name: "last_device", data: last_device)
                    bleController.centralManager?.connect(peripheral , options: nil)
                }else
                {
                    var checkDuplicates=false;
                    for element in info {
                        //print("peripheralName:\(String(peripheral.name!)) element:\(element)")
                        if (String(peripheral.name!)==element)
                        {
                            checkDuplicates=true;
                            break;
                        }
                        //print(element)
                    }
                    if (!checkDuplicates)
                    {
                        info.append(String(peripheral.name!))
                        peripheralArray.append(peripheral)
                        refreshFlag.value = true
                        print("insert:\(peripheral.name!)")
                    }
                }
            }
    }
    func dataReceived(_ data: Data) {
        bleController.debug_received.value = "\(tag) received:"
        for i in 0..<data.count
        {
          bleController.debug_received.value="\(bleController.debug_received.value) \(String(format: "%02X",data[i]))"
        }
        //print(bleController.debug_received.value)
        ahfViewModel.setDataToStructure(data: data)
    }
    func postLog(_ data: Data) {
        bleController.debug_command.value = "\(tag) command:"
        for i in 0..<data.count
        {
          bleController.debug_command.value="\(bleController.debug_command.value) \(String(format: "%02X",data[i]))"
        }
        print(bleController.debug_command.value)
    }
}
class ControlModel: NSObject {
    var tag = "ControlModel"
    static let sharedInstance = ControlModel()
    private let bleController = BleController.sharedInstance
    private var ahfViewModel = AHFViewModel.sharedInstance
    private let saveTool = SaveTool.sharedInstance
    private var last_device:String = ""
    public var auto_connect:Bool = true
    private var peripheralArray: [CBPeripheral] = []
    private var peripheral: CBPeripheral?
    var info: [String] = []
    var ahfData: LiveData<_ahfInfo> = LiveData(_ahfInfo())
    var refreshFlag: LiveData<Bool> = LiveData(false)
    var bt_stage: LiveData<BtStage> = LiveData(BtStage.init_value)
    var bt_state: LiveData<CBManagerState> = LiveData(CBManagerState.unknown)

    func setObserver(){
        print(tag,"setObserver")
        ahfViewModel.structuredData.observe{ [self] (structuredData) in
            self.ahfData.value = structuredData
        }
        bleController.bt_stage.observe{ [self] (bt_stage) in
            //print(tag,"bt_stage:\(bt_stage.rawValue)")
            self.bt_stage.value = bt_stage
        }
        bleController.bt_state.observe{ [self] (bt_state) in
            //print(tag,"bt_state:\(bt_state.rawValue)")
            self.bt_state.value = bt_state
        }
    }
    override init(){
        super.init()
        bleController.bleDeviceRecognize = self
        last_device = saveTool.readParams(name: "last_device")
        setObserver()
        print("BTListViewModel last device :\(last_device)")
    }
    func set_bt_init()
    {
        bleController.set_bt_init()
    }
    func get_last_device()->String
    {
        return last_device
    }
    func set_last_device(bt_name:String)
    {
        last_device = bt_name
        saveTool.writeParams(name: "last_device", data: last_device)
    }
    func btListCnt() -> Int{
        return info.count
    }
    func btListGet() -> [String]{
        return info
    }
    func btListGetName(index:Int) -> String{
        return info[index]
    }
    func reScanBt(){
        info.removeAll()
        //auto_connect = false
        //last_device = ""
        peripheralArray.removeAll()
        bleController.startScan()
    }
    func startScan(){
        bleController.startScan()
    }
    func stopScan(){
        info.removeAll()
        auto_connect = false
        peripheralArray.removeAll()
        bleController.stopScan()
    }
    func setPeripheral(peripheral: CBPeripheral){
        bleController.setPeripheral(peripheral: peripheral)
    }
    func getPeripheral() -> CBPeripheral{
        return peripheral!
    }
    func connect(index : Int){
        last_device = peripheralArray[index].name ?? ""
        print("writeParams last device :\(last_device)")
        saveTool.writeParams(name: "last_device", data: last_device)
        peripheral = peripheralArray[index]
        bleController.connect(peripheral: peripheralArray[index])
    }
    func connect(name : String){
        bleController.set_bt_stage(data: .connecting)
        for i in 0..<peripheralArray.count
        {
            let bt_name = peripheralArray[i].name ?? ""
            if bt_name == name
            {
                bleController.connect(peripheral: peripheralArray[i])
                break
            }
        }
    }
    func connect(peripheral : CBPeripheral){
        bleController.connect(peripheral: peripheral)
    }
    func connect(){
        bleController.connect()
    }
    func disconnect(){
        auto_connect = false
        bleController.disconnect()
    }
    func getConnectedBtName()->String{
        return bleController.getConnectedBtName()
    }
    func postDataToTRF2(data : [UInt8]){
        bleController.postDataToTRF2(data: data)
    }
    func set_bt_stage(data:BtStage)
    {
        bleController.set_bt_stage(data: data)
    }
    func get_bt_stage()->BtStage
    {
        return bleController.get_bt_stage()
    }
    func get_bt_state()->CBManagerState
    {
        return bleController.get_bt_state()
    }
    func setAutoConnect(auto_connect:Bool,bt_name:String)
    {
        self.auto_connect = auto_connect
        if self.auto_connect
        {
            last_device = bt_name
            startScan()
        }
        print(self.tag,"auto_connect:\(self.auto_connect) lastDevice:\(self.last_device)")
    }
    
}
