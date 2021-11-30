//
//  AHFReceivedModel.swift
//  AHF MEDIFIT
//
//  Created by benson chan on 2021/11/1.
//

import Foundation

class AHFReceivedModel {
    private let tag = "AHFReceivedModel"
    static let sharedInstance = AHFReceivedModel()
    public var debugRecievedLog : String = ""
    public var debugPostedLog : String = ""
    public var dataIsReady: Bool = false
    public var currentReceivedLog : Data?
    var structuredData: LiveData<_ahfInfo> = LiveData(_ahfInfo())
    func isAllDataReady() -> Bool{
        return structuredData.value.isDataReady
    }
    func isDataValid(data: Data) -> Bool{
        if isLengthValid(data: data){
            var truncated = 0
            var checkSum: UInt8 = 0
            for i in 1 ..< Int(data.count - 1){
                //print(String(format: "%02X",data[i]))
                truncated = truncated + Int(UInt8(truncatingIfNeeded: data[i]))
            }
            checkSum = UInt8(truncatingIfNeeded: truncated & 0x7f);
            if data.last == checkSum{
                return true
            }else{
                print("checkSum NG:\(checkSum),\(String(describing: data.last))")
                return false
            }
        }
        //print("length NG count:\(data.count)")
        return false
    }
    func isLengthValid(data: Data) -> Bool{
        if data.count == RECEIVED_LEN{
            return true
        }
        return false
    }
    func getReceivedLog() -> Data?{
        if isAllDataReady(){
            return currentReceivedLog
        }
        return nil
    }
    func getAHFDeviceStatus() -> _ahfInfo{
        return structuredData.value
    }
    func assignDataToStructure(data: Data){
        let prefix = (UInt16(data[0]) & 0xff) << 8 | UInt16(data[1]) & 0xff
        if prefix == structuredData.value.prefix
        {
            structuredData.value.back_lock = (data[2]&0x01) != 0
            structuredData.value.leg_lock = (data[2]&0x02) != 0
            structuredData.value.back_leg_lock = (data[2]&0x04) != 0
            structuredData.value.high_low_lock = (data[2]&0x08) != 0
            structuredData.value.trend_lock = (data[2]&0x10) != 0
            structuredData.value.night_lock = (data[2]&0x20) != 0
            structuredData.value.chair_lock = (data[2]&0x40) != 0
            if ((data[3]&0x03) == 0x00) {structuredData.value.light_mode = .off}
            else if ((data[3]&0x03) == 0x01) {structuredData.value.light_mode = .white}
            else if ((data[3]&0x03) == 0x02) {structuredData.value.light_mode = .green}
            else if ((data[3]&0x03) == 0x03) {structuredData.value.light_mode = .red}
            structuredData.value.isDataReady = true
            //dump(structuredData.value)
        }
        currentReceivedLog = data
    }
}
