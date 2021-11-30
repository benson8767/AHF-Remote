//
//  DataStructure.swift
//  LiveSpa
//
//  Created by benson chan on 2020/11/20.
//

import Foundation

class _ahfSetting:Codable {
    public var system_haptics:Bool = false
    public var auto_lock_time:UInt16 = 10
    public var auto_lock_time_cnt:UInt16 = 0
    public var unlock_press_time:UInt16 = 1
    public var unlock_press_time_cnt:UInt16 = 0
}
struct _buttonPress {
    public var back_up_press:Bool = false
    public var back_down_press:Bool = false
    public var leg_up_press:Bool = false
    public var leg_down_press:Bool = false
    public var back_leg_up_press:Bool = false
    public var back_leg_down_press:Bool = false
    public var high_low_up_press:Bool = false
    public var high_low_down_press:Bool = false
    public var trend_up_press:Bool = false
    public var trend_down_press:Bool = false
    public var night_mode_press:Bool = false
    public var chair_mode_press:Bool = false
    public var light_mode_press:Bool = false
    public var bt_press:Bool = false
    public var setting_press:Bool = false
    public var connection_press:Bool = false
}
class LiveData<T> {
    typealias Listener = (T) -> Void
    var listener: Listener?
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func observe(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}
/*
 //add this to AppDelegate
 var orientationLock = UIInterfaceOrientationMask.all

 func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
         return self.orientationLock
 }
*/
