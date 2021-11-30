//
//  SettingsModel.swift
//  AHF MEDIFIT
//
//  Created by benson chan on 2021/11/8.
//

import Foundation

class SettingsModel: NSObject {
    var tag = "SettingsModel"
    
    func setObserver(){
        print(tag,"setObserver")
    }
    override init(){
        super.init()
        setObserver()
    }
}
