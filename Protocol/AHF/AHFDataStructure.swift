//
//  AHFDataStructure.swift
//  AHF MEDIFIT
//
//  Created by benson chan on 2021/11/1.
//

import Foundation

import CoreBluetooth
class AHFBleConfig:NSObject
{
    //Nordic
    static let Service_UUID: String = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
    static let Characteristic_UUID1: String = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"//TX,NOTIFY
    static let Characteristic_UUID2: String = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"//RX
}
enum Operate_mode{
    case none
    case mode_init
    case back
    case leg
    case back_leg
    case high_low
}
enum Action{
    case back_up
    case back_down
    case leg_up
    case leg_down
    case back_leg_up
    case back_leg_down
    case high_low_up
    case high_low_down
    case trend_up
    case trend_down
    case night_mode
    case chair_mode
    case light_mode
    case release
}
enum light_mode{
    case off
    case white
    case green
    case red
}
struct _ahfInfo {
    public var isDataReady:Bool = false
    public var prefix:UInt16 = 0x9d00
    public var back_lock:Bool = false
    public var leg_lock:Bool = false
    public var back_leg_lock:Bool = false
    public var high_low_lock:Bool = false
    public var trend_lock:Bool = false
    public var night_lock:Bool = false
    public var chair_lock:Bool = false
    public var light_mode:light_mode = .off
}
let RECEIVED_LEN = 15
