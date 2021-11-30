//
//  keyAction.swift
//  LiveSpa
//
//  Created by benson chan on 2020/11/6.
//

import Foundation

enum ActionMode{
    case NONE
    case SINGLE_EXECUTION
    case CONTINUIOUS_EXECUTION
}

class ActionTool : NSObject{
    public static let sharedInstance = ActionTool()
    private let bleController = BleController.sharedInstance
    private var actionTimer : Timer?
    private var currentGuaranteedTimes:UInt8 = 0
    private var currentAction : ActionMode = .NONE
    private var currentCommand : [UInt8] = []

    private override init(){
        
    }
    
    public func setAction(action : ActionMode, guaranteedTimes: UInt8, command: [UInt8]){
        currentAction = action
        currentGuaranteedTimes = guaranteedTimes
        currentCommand = command
    }
    
    public func setActionTimer(){
        if actionTimer == nil{
            actionTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(0.1), repeats: true) { [self] (ktimer) in
                switch currentAction{
                case .NONE:
                    stopActionTimer()
                case .SINGLE_EXECUTION:
                    if currentGuaranteedTimes > 0 {
                        bleController.postDataToTRF2(data: currentCommand)
                        currentGuaranteedTimes -= 1
                    }else{
                        currentCommand = []
                        currentAction = .NONE
                        stopActionTimer()
                    }
                case .CONTINUIOUS_EXECUTION:
                    bleController.postDataToTRF2(data: currentCommand)
                }
            }
        }
    }
    
    public func stopActionTimer(){
        if actionTimer != nil{
            actionTimer?.invalidate()
            actionTimer = nil
        }
    }
}
