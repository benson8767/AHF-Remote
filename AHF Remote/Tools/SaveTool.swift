//
//  tools.swift
//  Stand Up Pls Simple
//
//  Created by Jia-Xing Li on 2019/12/3.
//  Copyright © 2019 Jia-Xing Li. All rights reserved.
//

import UIKit


class SaveTool: NSObject {
    
    static let sharedInstance = SaveTool()
    private let userDefaults = UserDefaults.standard
    
    private override init(){
        
    }
    
    //write part
    func writeParams(name:String,data:[UInt16]){
        do {
            let res = try JSONEncoder().encode(data)
            userDefaults.set(res,forKey: name)
        }
        catch { print("cannot write file", error) }
    }
    
    func writeParams(name:String,data:String){
        do {
            let res = try JSONEncoder().encode(data)
            userDefaults.set(res,forKey: name)
        }
        catch { print("cannot write file", error) }
        
    }
    
    func writeParams(name:String,data:Bool){
        do {
            let res = try JSONEncoder().encode(data)
            userDefaults.set(res,forKey: name)
        }
        catch { print("cannot write file", error) }
        
    }
    
    func writeParams(name:String,data:_ahfSetting){
        do {
            let res = try JSONEncoder().encode(data)
            userDefaults.set(res,forKey: name)
        }
        catch { print("cannot write file", error) }
        
    }
    
   /*func writeParams(name:String,data:[DeviceName]){
        do {
            let res = try JSONEncoder().encode(data)
            userDefaults.set(res,forKey: name)
        }
        catch { print("cannot write file", error) }
        
    }
    */
    //read part
    func readParams(name:String)-> [UInt16]{
        var data: [UInt16] = []
        do {
            if let userD =  userDefaults.data(forKey:name) {
                let res = try JSONDecoder().decode([UInt16].self,from:userD)
                data = res
            } else {
                print("No saved file")
            }
        }
        catch { print("cannot read file", error) }
        
        return data
    }
    
    func readParams(name:String)->String{
        var data: String = ""
        do {
            if let userD =  userDefaults.data(forKey:name) {
                let res = try JSONDecoder().decode(String.self,from:userD)
                data = res
            } else {
                print("No saved file")
            }
        }
        catch { print("cannot read file", error) }
        
        return data
    }
    
    func readParams(name:String)->Bool{
        var data: Bool = false
        do {
            if let userD =  userDefaults.data(forKey:name) {
                let res = try JSONDecoder().decode(Bool.self,from:userD)
                data = res
            } else {
                print("No saved file")
            }
        }
        catch { print("cannot read file", error) }
        
        return data
    }
    
    func readParams(name:String) -> _ahfSetting?{
        var data: _ahfSetting? = nil
        do {
            if let userD =  userDefaults.data(forKey:name) {
                let res = try JSONDecoder().decode(_ahfSetting.self,from:userD)
                data = res
            } else {
                print("No saved file")
            }
        }
        catch { print("cannot read file", error) }
        
        return data
    }
    /*
    func readParams(name:String)->[DeviceName]{
        var data: [DeviceName] = []
        do {
            if let userD =  userDefaults.data(forKey:name) {
                let res = try JSONDecoder().decode([DeviceName].self,from:userD)
                data = res
            } else {
                print("No saved file")
            }
        }
        catch { print("cannot read file", error) }
        
        return data
    }*/
    
}
