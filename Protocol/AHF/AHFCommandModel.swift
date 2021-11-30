//
//  AHFCommandModel.swift
//  AHF MEDIFIT
//
//  Created by benson chan on 2021/11/1.
//

import Foundation

class AHFCommandModel: NSObject {
    public let saveTool = SaveTool.sharedInstance
    private var command: [UInt8] = [0xdd, 0xdd, 0xff, 0x00, 0x00 ,0x00 ,0x00 ,0x00 ,0x00 ,0x00 ,0x00  ]
    override init(){
        super.init()
    }
    func back_up() {
        command[3] = 0x01
        command[4] = 0x01
        command[5] = 0x0
        command[6] = 0x0
        //addCheckSum(data: command)
    }
    func back_down() {
        command[3] = 0x02
        command[4] = 0x02
        command[5] = 0x0
        command[6] = 0x0
        //addCheckSum(data: command)
    }
    func leg_up() {
        command[3] = 0x04
        command[4] = 0x04
        command[5] = 0x0
        command[6] = 0x0
        //addCheckSum(data: command)
    }
    func leg_down() {
        command[3] = 0x08
        command[4] = 0x08
        command[5] = 0x0
        command[6] = 0x0
        //addCheckSum(data: command)
    }
    func back_leg_up() {
        command[3] = 0x10
        command[4] = 0x10
        command[5] = 0x0
        command[6] = 0x0
        //addCheckSum(data: command)
    }
    func back_leg_down() {
        command[3] = 0x20
        command[4] = 0x20
        command[5] = 0x0
        command[6] = 0x0
        //addCheckSum(data: command)
    }
    func high_low_up() {
        command[3] = 0x0
        command[4] = 0x0
        command[5] = 0x01
        command[6] = 0x01
        //addCheckSum(data: command)
    }
    func high_low_down() {
        command[3] = 0x0
        command[4] = 0x0
        command[5] = 0x02
        command[6] = 0x02
        //addCheckSum(data: command)
    }
    func trend_up() {
        command[3] = 0x0
        command[4] = 0x0
        command[5] = 0x04
        command[6] = 0x04
        //addCheckSum(data: command)
    }
    func trend_down() {
        command[3] = 0x0
        command[4] = 0x0
        command[5] = 0x08
        command[6] = 0x08
        //addCheckSum(data: command)
    }
    func night_mode() {
        command[3] = 0x0
        command[4] = 0x0
        command[5] = 0x10
        command[6] = 0x10
        //addCheckSum(data: command)
    }
    func chair_mode() {
        command[3] = 0x0
        command[4] = 0x0
        command[5] = 0x40
        command[6] = 0x40
        //addCheckSum(data: command)
    }
    func light_mode() {
        command[3] = 0x0
        command[4] = 0x0
        command[5] = 0x20
        command[6] = 0x20
        //addCheckSum(data: command)
    }
    func button_dummy()
    {
        command[3] = 0x0
        command[4] = 0x0
        command[5] = 0x0
        command[6] = 0x0
        command[7] = 0x0
        command[8] = 0x0
        command[9] = 0x0
        command[10] = 0x0
        //addCheckSum(data: command)
    }
    /*func addCheckSum(data: [UInt8])
    {
        let checkSumGet = checkSum(data: data)
        command[11] = checkSumGet
        //command[12] = checkSumGet
    }
    func checkSum(data: [UInt8]) -> UInt8
    {
        var truncated = 0;
        var checkSum:UInt8 = 0
        //print(String(format: "%02X",data[1]))
        for i in 0..<Int(data.count)
        {
            //print(String(format: "%02X",data[i]))
            truncated=truncated+Int(UInt8(truncatingIfNeeded:data[i]))
        }
        checkSum=UInt8(truncatingIfNeeded:truncated&0x7f);
        return checkSum
    }*/
    func getCommand() -> [UInt8]{
        return command
    }
}
