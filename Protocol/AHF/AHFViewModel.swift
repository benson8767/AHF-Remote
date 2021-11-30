//
//  AHFViewModel.swift
//  AHF MEDIFIT
//
//  Created by benson chan on 2021/11/1.
//

import Foundation
class AHFViewModel: NSObject {
    func execute(action: Action, antiCollitionLevel: UInt8?) {
        
    }
    private let tag = "AHFViewModel"
    static let sharedInstance = AHFViewModel()
    public let actionTool = ActionTool.sharedInstance
    private let ahfReceivedModel = AHFReceivedModel.sharedInstance
    private let ahfCommandModel = AHFCommandModel()
    var structuredData: LiveData<_ahfInfo> = LiveData(_ahfInfo())
    override init() {
        super.init()
        ahfReceivedModel.structuredData.observe { (structuredData) in
            //print(self.tag,"structuredData observe")
            self.structuredData.value = structuredData
        }
    }
    //data
    func setDataToStructure(data: Data){
        if ahfReceivedModel.isDataValid(data: data){
            //print(self.tag,"setDataToStructure:\(data)")
            ahfReceivedModel.assignDataToStructure(data: data)
        }
    }
    
    func isAllDataReady() -> Bool{
        return ahfReceivedModel.isAllDataReady()
    }
    
    func getReceivedLog() -> Data{
        return ahfReceivedModel.getReceivedLog()!
    }
    
    func getP1DeviceStatus() -> _ahfInfo{
        return ahfReceivedModel.getAHFDeviceStatus()
    }
    
    func getCommand() -> [UInt8] {
        //print("getCommand:\(p3CommandModel.getCommand())")
        return ahfCommandModel.getCommand()
    }
    //commands
    public func execute(action : Action){
        switch(action)
        {
        case .back_up:
            ahfCommandModel.back_up()
            actionTool.setAction(action: .CONTINUIOUS_EXECUTION, guaranteedTimes: 1, command: getCommand())
            break
        case .back_down:
            ahfCommandModel.back_down()
            actionTool.setAction(action: .CONTINUIOUS_EXECUTION, guaranteedTimes: 1, command: getCommand())
            break
        case .leg_up:
            ahfCommandModel.leg_up()
            actionTool.setAction(action: .CONTINUIOUS_EXECUTION, guaranteedTimes: 1, command: getCommand())
            break
        case .leg_down:
            ahfCommandModel.leg_down()
            actionTool.setAction(action: .CONTINUIOUS_EXECUTION, guaranteedTimes: 1, command: getCommand())
            break
        case .back_leg_up:
            ahfCommandModel.back_leg_up()
            actionTool.setAction(action: .CONTINUIOUS_EXECUTION, guaranteedTimes: 1, command: getCommand())
            break
        case .back_leg_down:
            ahfCommandModel.back_leg_down()
            actionTool.setAction(action: .CONTINUIOUS_EXECUTION, guaranteedTimes: 1, command: getCommand())
            break
        case .high_low_up:
            ahfCommandModel.high_low_up()
            actionTool.setAction(action: .CONTINUIOUS_EXECUTION, guaranteedTimes: 1, command: getCommand())
            break
        case .high_low_down:
            ahfCommandModel.high_low_down()
            actionTool.setAction(action: .CONTINUIOUS_EXECUTION, guaranteedTimes: 1, command: getCommand())
            break
        case .trend_up:
            ahfCommandModel.trend_up()
            actionTool.setAction(action: .CONTINUIOUS_EXECUTION, guaranteedTimes: 1, command: getCommand())
            break
        case .trend_down:
            ahfCommandModel.trend_down()
            actionTool.setAction(action: .CONTINUIOUS_EXECUTION, guaranteedTimes: 1, command: getCommand())
            break
        case .night_mode:
            ahfCommandModel.night_mode()
            actionTool.setAction(action: .CONTINUIOUS_EXECUTION, guaranteedTimes: 1, command: getCommand())
            break
        case .chair_mode:
            ahfCommandModel.chair_mode()
            actionTool.setAction(action: .CONTINUIOUS_EXECUTION, guaranteedTimes: 1, command: getCommand())
            break
        case .light_mode:
            ahfCommandModel.light_mode()
            actionTool.setAction(action: .SINGLE_EXECUTION, guaranteedTimes: 3, command: getCommand())
            break
        case .release:
            ahfCommandModel.button_dummy()
            actionTool.setAction(action: .SINGLE_EXECUTION, guaranteedTimes: 3, command: getCommand())
            break
        }
        actionTool.setActionTimer()
    }
}
