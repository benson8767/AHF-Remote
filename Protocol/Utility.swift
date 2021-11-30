//
//  Utility.swift
//  Stand Up Pls Simple
//
//  Created by Billy W on 2020/10/23.
//  Copyright © 2020 Jia-Xing Li. All rights reserved.
//
import UIKit
import Foundation

class DeviceName: Codable{
    var originName:String?
    var preferedName:String?
    init(originName:String){
        self.originName = originName
    }
}
enum DialogType {
    case dismiss
    case reset
    case yesNo
    case disconnect
    case exclamation
}
enum ProtocolNumber {
    case none
    case Protocol1
    case Protocol2
    case Protocol3
}
enum DialogDisplayStatus{
    case show
    case inUse
    case dismissed
    case none
}
