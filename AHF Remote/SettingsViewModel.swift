//
//  SettingsViewModel.swift
//  AHF MEDIFIT
//
//  Created by benson chan on 2021/11/8.
//

import Foundation

class SettingsViewModel: NSObject {
    var tag = "SettingsViewModel"
    
    func setObserver(){
        print(tag,"setObserver")
    }
    override init(){
        super.init()
        setObserver()
    }
}
