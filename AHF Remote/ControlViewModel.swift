//
//  ControlViewModel.swift
//  AHF Remote
//
//  Created by benson chan on 2021/10/28.
//

import Foundation
import CoreBluetooth

class ControlViewModel: NSObject {
    var tag = "ControlViewModel"
    static let sharedInstance = ControlViewModel()
    private var btListModel = ControlModel.sharedInstance
    private var ahfViewModel = AHFViewModel.sharedInstance
    var ahfData: LiveData<_ahfInfo> = LiveData(_ahfInfo())
    var refreshFlag: LiveData<Bool> = LiveData(false)
    var bt_stage: LiveData<BtStage> = LiveData(BtStage.init_value)
    var bt_state: LiveData<CBManagerState> = LiveData(CBManagerState.unknown)
    func setObserver(){
        print(tag,"setObserver")
        ahfViewModel.structuredData.observe{ [self] (structuredData) in
            self.ahfData.value = structuredData
        }
        btListModel.refreshFlag.observe{ [self] (refreshFlag) in
            self.refreshFlag.value = refreshFlag
        }
        btListModel.bt_stage.observe{ [self] (bt_stage) in
            //print(tag,"bt_stage:\(bt_stage.rawValue)")
            self.bt_stage.value = bt_stage
        }
        btListModel.bt_state.observe{ [self] (bt_state) in
            //print(tag,"bt_state:\(bt_state.rawValue)")
            self.bt_state.value = bt_state
        }
    }
    override init(){
        super.init()
        setObserver()
    }
    func get_last_device()->String
    {
        return btListModel.get_last_device()
    }
    func set_last_device(bt_name:String)
    {
        btListModel.set_last_device(bt_name: bt_name) 
    }
    func btListCnt() -> Int{
        return btListModel.info.count
    }
    func btListGet() -> [String]{
        return btListModel.info
    }
    func btListGetName(index:Int) -> String{
        if  btListModel.info.indices.contains(index)
        {
            return btListModel.info[index]
        }
        return ""
    }
    func reScanBt(){
        btListModel.reScanBt()
    }
    func startScan(){
        btListModel.startScan()
    }
    func stopScan(){
        btListModel.stopScan()
    }
    func setPeripheral(peripheral: CBPeripheral){
        btListModel.setPeripheral(peripheral: peripheral)
    }
    func getPeripheral() -> CBPeripheral{
        return btListModel.getPeripheral()
    }
    func set_bt_init()
    {
        btListModel.set_bt_init()
    }
    func connect(index : Int){
        btListModel.connect(index: index)
    }
    func connect(peripheral : CBPeripheral){
        btListModel.connect(peripheral: peripheral)
    }
    func connect(){
        btListModel.connect()
    }
    func connect(name : String){
        btListModel.connect(name: name)
    }
    func disconnect(){
        btListModel.disconnect()
    }
    func getConnectedBtName()->String{
        return btListModel.getConnectedBtName()
    }
    func postDataToTRF2(data : [UInt8]){
        btListModel.postDataToTRF2(data: data)
    }
    func set_bt_stage(data:BtStage)
    {
        btListModel.set_bt_stage(data: data)
    }
    func get_bt_stage()->BtStage
    {
        return btListModel.get_bt_stage()
    }
    func get_bt_state()->CBManagerState
    {
        return btListModel.get_bt_state()
    }
    func setAutoConnect(auto_connect:Bool,bt_name:String)
    {
        btListModel.setAutoConnect(auto_connect: auto_connect,bt_name: bt_name)
    }
    
}
