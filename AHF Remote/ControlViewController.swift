//
//  ViewController.swift
//  AHF Remote
//
//  Created by benson chan on 2021/10/26.
//

import UIKit
import CoreBluetooth
import AudioToolbox
import KDCircularProgress
import Malert
enum CurrentDialog:Int {
    case none = 0
    case connectingDialog = 1
    case reConnectingDialog = 2
    case manualDisconnectDialog = 3
    case disconnectDialog = 4
    case allowBtAccessDialog = 5
}
enum CurrentVC:Int {
    case none = 0
    case ControlViewControllerNum = 1
    case SettingsViewControllerNum = 2
    case LockViewControllerNum = 3
}
var connectingPopupDialog = PopupDialog(title: "",
                                        message: "",
                                        image: UIImage(named: ""),
                                        buttonAlignment: .horizontal,
                                        transitionStyle: .zoomIn,
                                        tapGestureDismissal: true,
                                        panGestureDismissal: true,
                                        hideStatusBar: true){}
var currentVC:CurrentVC = .none
class ControlViewController: UIViewController,ConnectingDialogViewDelegate,ReConnectingDialogViewDelegate,ManualDisconnectDialogDismissDelegate,DisconnectDialogDismissDelegate,AllowBtAccessDialogDismissDelegate {
    var tag = "ControlViewController"
    private let saveTool = SaveTool.sharedInstance
    @IBOutlet weak var BT_title: UILabel!
    @IBOutlet weak var backUpBtn: UIButton!
    @IBOutlet weak var backDownBtn: UIButton!
    @IBOutlet weak var backIcon: UIButton!
    @IBOutlet weak var legUpBtn: UIButton!
    @IBOutlet weak var legDownBtn: UIButton!
    @IBOutlet weak var legIcon: UIButton!
    @IBOutlet weak var backLegUpBtn: UIButton!
    @IBOutlet weak var backLegDownBtn: UIButton!
    @IBOutlet weak var backLegIcon: UIButton!
    @IBOutlet weak var hiLowUpBtn: UIButton!
    @IBOutlet weak var hiLowDownBtn: UIButton!
    @IBOutlet weak var hiLowIcon: UIButton!
    @IBOutlet weak var trendUpBtn: UIButton!
    @IBOutlet weak var trendDownBtn: UIButton!
    @IBOutlet weak var trendIcon: UIButton!
    @IBOutlet weak var nightBtn: UIButton!
    @IBOutlet weak var chairBtn: UIButton!
    @IBOutlet weak var lightBtn: UIButton!
    @IBOutlet weak var btConnectionBtn: UIButton!
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var backBk: UIView!
    @IBOutlet weak var legBk: UIView!
    @IBOutlet weak var backLegBk: UIView!
    @IBOutlet weak var hiLowBk: UIView!
    @IBOutlet weak var trendBk: UIView!
    @IBOutlet weak var below_bk: UIImageView!
    
    @IBOutlet weak var back_lock: UIButton!
    @IBOutlet weak var leg_lock: UIButton!
    @IBOutlet weak var back_leg_lock: UIButton!
    @IBOutlet weak var high_low_lock: UIButton!
    @IBOutlet weak var trend_lock: UIButton!
    @IBOutlet weak var night_lock: UIButton!
    @IBOutlet weak var chair_lock: UIButton!
        
    @IBOutlet weak var ahf_logo: UIImageView!
    private var controlViewModel = ControlViewModel.sharedInstance
    private let ahfViewModel = AHFViewModel.sharedInstance
    private var ahfData: _ahfInfo = _ahfInfo()
    private var ahfDataOrg: _ahfInfo = _ahfInfo()
    private var last_device:String = ""
    var currentDialog:CurrentDialog = .none
    let reConnectingDialogView = ReConnectingDialogView.instantiateFromNib()
    let connectingDialogView = ConnectingDialogView.instantiateFromNib()
    let manualDisconnectDialogView = ManualDisconnectDialogView.instantiateFromNib()
    let disconnectDialogView = DisconnectDialogView.instantiateFromNib()
    let allowBtAccessDialogView = AllowBtAccessDialogView.instantiateFromNib()

    var timer: Timer?
    var btn_timer: Timer?
    var connecting_cnt = 0
    var bt_stage:BtStage = .init_value
    var bt_stage_org:BtStage = .init_value
    var bt_state: CBManagerState = CBManagerState.unknown
    var buttonPress = _buttonPress()
    var buttonPressOrg = _buttonPress()
    var buttonPressUI = _buttonPress()
    var move_background_flag = false
    var first_reconnection = false
    var background_flag_timer: Timer?
    func setObserver(){
        print(tag,"setObserver")
        self.last_device = controlViewModel.get_last_device()
        controlViewModel.ahfData.observe{ [self] (structuredData) in
            self.ahfData = structuredData
            //print(self.tag,"bt_stage1:\(bt_stage),isDataReady:\(self.jmsData.isDataReady)")
            if bt_stage == .is_connect && self.ahfData.isDataReady
            {
                print(self.tag,"function_ok")
                self.bt_stage = .function_ok
                self.controlViewModel.set_bt_stage(data: self.bt_stage)
            }
            self.refreshUI()
        }
        controlViewModel.refreshFlag.observe { (refreshFlag) in
            let list_cnt = self.controlViewModel.btListCnt()
            //print("btListCnt:\(list_cnt)")
            self.last_device = self.controlViewModel.get_last_device()
            for i in 0..<list_cnt
            {
                let title = self.controlViewModel.btListGetName(index: i)
                if self.last_device.count > 0 //direct connect
                {
                    print("direct connect:\(self.last_device)")
                    self.controlViewModel.connect(name: self.last_device)
                    break
                }else  //near connect
                {
                    //if prefix_check == "AHF_MEDIFIT" || prefix_check1 == "stand UP-"
                    //let prefix_check1 = title.prefix(9)
                    //if prefix_check1 == "stand UP-"
                    let prefix_check = title.prefix(11)
                    if prefix_check == "AHF_MEDIFIT" || prefix_check == "AHF MEDIFIT"
                    {
                        if self.connecting_cnt > 0
                        {
                            print("find name:\(title)")
                            self.controlViewModel.connect(index:i)
                            self.connecting_cnt = 0
                        }
                    }else
                    {
                        print("skip name:\(title)")
                    }
                }
            }
        }
        controlViewModel.bt_stage.observe { (bt_stage) in
            self.bt_stage = bt_stage
            print(self.tag,"callback currentVC:\(currentVC),self.bt_stage:\(self.bt_stage)")
            if self.move_background_flag {print(self.tag,"callback bt_stage return");return}
            if currentVC == .SettingsViewControllerNum
            {
                if self.bt_stage == .disconnected
                {
                    self.first_reconnection = false
                }
                print(self.tag,"callback skip check SettingsViewControllerNum. self.bt_stage:\(self.bt_stage),self.connecting_cnt:\(self.connecting_cnt),first_reconnection:\(self.first_reconnection)")
            }else
            {
            if self.bt_state == .poweredOff
            {
                self.alert_dialog_dismiss()
                self.view.showToast(text: "callback Device bluetooth is \nturned off.".localized)
            }else
            {
                if self.bt_stage == .disconnected
                {
                    self.last_device = self.controlViewModel.get_last_device()
                    print(self.tag,"callback disconnected :\(self.last_device)")
                    if self.last_device.count > 0
                    {
                        self.disconnectDialog()
                    }
                }else if self.bt_stage == .notify_ok || self.bt_stage == .function_ok
                {
                    print(self.tag,"callback notify_ok to function_ok..")
                    self.last_device = self.controlViewModel.get_last_device()
                    let show_text = "\(self.last_device) \("connected.".localized)"
                    print(self.tag,"callback show_text:\(show_text)")
                    self.view.showToast(text: show_text)
                    self.bt_stage = .function_ok
                    self.alert_dialog_dismiss()
                    self.refreshUI()
                    self.connecting_cnt = 0
                }else if (self.bt_stage == .connecting || self.bt_stage == .is_connect)
                {
                    print(self.tag,"callback connecting or is_connect")
                    if self.first_reconnection
                    {
                        self.reConnectingDialog()
                        self.first_reconnection = false
                    }else
                    {
                        self.disconnectDialog()
                    }
                }
                print(self.tag,"callback bt_stage:\(bt_stage),isDataReady:\(self.ahfData.isDataReady)")
            }
            }
            self.refreshUI()
        }
        controlViewModel.bt_state.observe { (bt_state) in
            print(self.tag,"callback bt_state:\(bt_state.rawValue)")
            self.bt_state = bt_state
            /*if self.bt_state == .unauthorized
            {
                self.allowBtAccessDialog()
            }else */if self.bt_state == .poweredOff
            {
                self.view.showToast(text: "callback Device bluetooth is \nturned off.".localized)
                self.disconnection()
            }
            self.refreshUI()
        }
    }
    public func removeObserver(){
        print(tag,"removeObserver")
        controlViewModel.ahfData.observe(listener: nil)
        controlViewModel.refreshFlag.observe(listener: nil)
        controlViewModel.bt_stage.observe(listener: nil)
        controlViewModel.bt_state.observe(listener: nil)
    }
    func testDialog(){
        //let show_text = "\("Connection failed.".localized)\n\(self.last_device) \("not in range.".localized)"
        //self.view.showToast(text: show_text)
        //self.view.showToast(text: "Connection failed.".localized)
        //self.view.showToast(text: "Device bluetooth is \nturned off.".localized)
        //let show_text = "\(self.last_device) \("connected.".localized)"
        //self.view.showToast(text: show_text)
        //let show_text = "\("Connection failed.".localized)\n\(self.last_device) \("not in range.".localized)"
        //self.view.showToast(text: show_text)
        //allowBtAccessDialog()
        //manualDisconnectDialog()
        //disconnectDialog()
        //self.last_device = ""
        //reConnectingDialog()
    }
    @IBAction func backUpAction(_ sender: Any) {
        //print("backUpAction back_up_press:\(buttonPress.back_up_press)")
        testDialog()
        if self.ahfData.back_lock {return}
        buttonPress.back_up_press = true
        if !self.allKeyRelease() {return}
        ahfViewModel.execute(action: .back_up)
        buttonProcess(buttonPress)
    }
    @IBAction func backUpReleaseAction(_ sender: Any) {
        if self.ahfData.back_lock || self.bt_stage != .function_ok {return}
        buttonPress.back_up_press = false
        //print("backUpReleaseAction Cnt:\(chkMutliKeyPressCnt(buttonPress)),back_up_press:\(buttonPress.back_up_press)")
        if chkMutliKeyPressCnt(buttonPress) > 0 {return}
        ahfViewModel.execute(action: .release)
        buttonProcess(buttonPress)
    }
    @IBAction func backDownAction(_ sender: Any) {
        //print("backDownAction back_down_press:\(buttonPress.back_down_press)")
        if self.ahfData.back_lock {return}
        buttonPress.back_down_press = true
        if !self.allKeyRelease() {return}
        ahfViewModel.execute(action: .back_down)
        buttonProcess(buttonPress)
    }
    @IBAction func backDownReleaseAction(_ sender: Any) {
        if self.ahfData.back_lock || self.bt_stage != .function_ok {return}
        buttonPress.back_down_press = false
        //print("backDownReleaseAction Cnt:\(chkMutliKeyPressCnt(buttonPress)),back_down_press:\(buttonPress.back_down_press)")
        if chkMutliKeyPressCnt(buttonPress) > 0 {return}
        ahfViewModel.execute(action: .release)
        buttonProcess(buttonPress)
    }
    @IBAction func legUpAction(_ sender: Any) {
        if self.ahfData.leg_lock {return}
        buttonPress.leg_up_press = true
        if !self.allKeyRelease() {return}
        ahfViewModel.execute(action: .leg_up)
        buttonProcess(buttonPress)
    }
    @IBAction func legUpReleaseAction(_ sender: Any) {
        if self.ahfData.leg_lock || self.bt_stage != .function_ok {return}
        buttonPress.leg_up_press = false
        if chkMutliKeyPressCnt(buttonPress) > 0 {return}
        ahfViewModel.execute(action: .release)
        buttonProcess(buttonPress)
    }
    @IBAction func legDownAction(_ sender: Any) {
        if self.ahfData.leg_lock {return}
        buttonPress.leg_down_press = true
        if !self.allKeyRelease() {return}
        ahfViewModel.execute(action: .leg_down)
        buttonProcess(buttonPress)
    }
    @IBAction func legDownReleaseAction(_ sender: Any) {
        if self.ahfData.leg_lock || self.bt_stage != .function_ok {return}
        buttonPress.leg_down_press = false
        if chkMutliKeyPressCnt(buttonPress) > 0 {return}
        ahfViewModel.execute(action: .release)
        buttonProcess(buttonPress)
    }
    @IBAction func backLegUpAction(_ sender: Any) {
        if self.ahfData.back_leg_lock {return}
        buttonPress.back_leg_up_press = true
        if !self.allKeyRelease(){return}
        ahfViewModel.execute(action: .back_leg_up)
        buttonProcess(buttonPress)
    }
    @IBAction func backLegUpReleaseAction(_ sender: Any) {
        if self.ahfData.back_leg_lock || self.bt_stage != .function_ok {return}
        buttonPress.back_leg_up_press = false
        if chkMutliKeyPressCnt(buttonPress) > 0 {return}
        ahfViewModel.execute(action: .release)
        buttonProcess(buttonPress)
    }
    @IBAction func backLegDownAction(_ sender: Any) {
        if self.ahfData.back_leg_lock {return}
        buttonPress.back_leg_down_press = true
        if !self.allKeyRelease(){return}
        ahfViewModel.execute(action: .back_leg_down)
        buttonProcess(buttonPress)
    }
    @IBAction func backLegDownReleaseAction(_ sender: Any) {
        if self.ahfData.back_leg_lock || self.bt_stage != .function_ok {return}
        buttonPress.back_leg_down_press = false
        if chkMutliKeyPressCnt(buttonPress) > 0 {return}
        ahfViewModel.execute(action: .release)
        buttonProcess(buttonPress)
    }
    @IBAction func hiLowUpAction(_ sender: Any) {
        if self.ahfData.high_low_lock {return}
        buttonPress.high_low_up_press = true
        if !self.allKeyRelease() {return}
        ahfViewModel.execute(action: .high_low_up)
        buttonProcess(buttonPress)
    }
    @IBAction func hiLowUpReleaseAction(_ sender: Any) {
        if self.ahfData.high_low_lock || self.bt_stage != .function_ok {return}
        buttonPress.high_low_up_press = false
        if chkMutliKeyPressCnt(buttonPress) > 0 {return}
        ahfViewModel.execute(action: .release)
        buttonProcess(buttonPress)
    }
    @IBAction func hiLowDownAction(_ sender: Any) {
        if self.ahfData.high_low_lock {return}
        buttonPress.high_low_down_press = true
        if !self.allKeyRelease() {return}
        ahfViewModel.execute(action: .high_low_down)
        buttonProcess(buttonPress)
    }
    @IBAction func hiLowDownReleaseAction(_ sender: Any) {
        if self.ahfData.high_low_lock || self.bt_stage != .function_ok {return}
        buttonPress.high_low_down_press = false
        if chkMutliKeyPressCnt(buttonPress) > 0 {return}
        ahfViewModel.execute(action: .release)
        buttonProcess(buttonPress)
    }
    @IBAction func trendUpAction(_ sender: Any) {
        if self.ahfData.trend_lock {return}
        buttonPress.trend_up_press = true
        if !self.allKeyRelease(){return}
        ahfViewModel.execute(action: .trend_up)
        buttonProcess(buttonPress)
    }
    @IBAction func trendUpReleaseAction(_ sender: Any) {
        if self.ahfData.trend_lock || self.bt_stage != .function_ok {return}
        buttonPress.trend_up_press = false
        if chkMutliKeyPressCnt(buttonPress) > 0 {return}
        ahfViewModel.execute(action: .release)
        buttonProcess(buttonPress)
    }
    @IBAction func trendDownAction(_ sender: Any) {
        if self.ahfData.trend_lock {return}
        buttonPress.trend_down_press = true
        if !self.allKeyRelease() {return}
        ahfViewModel.execute(action: .trend_down)
        buttonProcess(buttonPress)
    }
    @IBAction func trendDownReleaseAction(_ sender: Any) {
        if self.ahfData.trend_lock || self.bt_stage != .function_ok {return}
        buttonPress.trend_down_press = false
        if chkMutliKeyPressCnt(buttonPress) > 0 {return}
        ahfViewModel.execute(action: .release)
        buttonProcess(buttonPress)
    }
    @IBAction func lightAction(_ sender: Any) {
        buttonPress.light_mode_press = true
        if !allKeyRelease()  {return}
        ahfViewModel.execute(action: .light_mode)
        buttonProcess(buttonPress)
        self.btn_timer=Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [self] (ktimer) in
            print("lightReleaseAction")
            buttonPress.light_mode_press = false
            if chkMutliKeyPressCnt(buttonPress) == 0
            {
                ahfViewModel.execute(action: .release)
                buttonProcess(buttonPress)
            }
        }
    }
    @IBAction func lightReleaseAction(_ sender: Any) {
        buttonPress.light_mode_press = false
    }
    @IBAction func nightAction(_ sender: Any) {
        if self.ahfData.night_lock {return}
        buttonPress.night_mode_press = true
        if !self.allKeyRelease(){return}
        ahfViewModel.execute(action: .night_mode)
        buttonProcess(buttonPress)
    }
    @IBAction func nightReleaseAction(_ sender: Any) {
        if self.ahfData.night_lock || self.bt_stage != .function_ok {return}
        buttonPress.night_mode_press = false
        if chkMutliKeyPressCnt(buttonPress) > 0 {return}
        ahfViewModel.execute(action: .release)
        buttonProcess(buttonPress)
    }
    @IBAction func chairAction(_ sender: Any) {
        if self.ahfData.chair_lock {return}
        buttonPress.chair_mode_press = true
        if !self.allKeyRelease(){return}
        ahfViewModel.execute(action: .chair_mode)
        buttonProcess(buttonPress)
    }
    @IBAction func chairReleaseAction(_ sender: Any) {
        if self.ahfData.chair_lock || self.bt_stage != .function_ok {return}
        buttonPress.chair_mode_press = false
        if chkMutliKeyPressCnt(buttonPress) > 0 {return}
        ahfViewModel.execute(action: .release)
        buttonProcess(buttonPress)
    }
    @IBAction func btConnectionDown(_ sender: Any) {
        buttonPress.connection_press = true
        if !allKeyRelease(true)  {return}
        ahfSetting.auto_lock_time_cnt = 0
        if self.bt_state == .unauthorized
        {
            allowBtAccessDialog()
        }else if self.bt_state == .poweredOff
        {
            self.view.showToast(text: "Device bluetooth is \nturned off.".localized)
            self.alert_dialog_dismiss()
        }else if self.bt_stage == .function_ok || self.bt_stage == .is_connect || self.bt_stage == .notify_ok
        {
            manualDisconnectDialog()
        }else
        {
            self.BT_title.text = "AHF"
            self.controlViewModel.set_bt_stage(data: .init_value)
            self.reConnectingDialog()
        }
    }
    @IBAction func btConnectionReleaseAction(_ sender: Any) {
        buttonPress.connection_press = false
    }
    @IBAction func settingAction(_ sender: Any) {
        buttonPress.setting_press = true
        if !allKeyRelease(true)  {return}
        goToSettings()
        buttonProcess(buttonPress)
    }
    @IBAction func settingReleaseAction(_ sender: Any) {
        buttonPress.setting_press = false
    }
    func isSameButton()->Bool{
        var flag = true
        if buttonPressOrg.back_up_press != buttonPress.back_up_press {buttonPressOrg.back_up_press = buttonPress.back_up_press;flag = false}
        if buttonPressOrg.back_down_press != buttonPress.back_down_press {buttonPressOrg.back_down_press = buttonPress.back_down_press;flag = false}
        if buttonPressOrg.leg_up_press != buttonPress.leg_up_press {buttonPressOrg.leg_up_press = buttonPress.leg_up_press;flag = false}
        if buttonPressOrg.leg_down_press != buttonPress.leg_down_press {buttonPressOrg.leg_down_press = buttonPress.leg_down_press;flag = false}
        if buttonPressOrg.back_leg_up_press != buttonPress.back_leg_up_press {buttonPressOrg.back_leg_up_press = buttonPress.back_leg_up_press;flag = false}
        if buttonPressOrg.back_leg_down_press != buttonPress.back_leg_down_press {buttonPressOrg.back_leg_down_press = buttonPress.back_leg_down_press;flag = false}
        if buttonPressOrg.high_low_up_press != buttonPress.high_low_up_press {buttonPressOrg.high_low_up_press = buttonPress.high_low_up_press;flag = false}
        if buttonPressOrg.high_low_down_press != buttonPress.high_low_down_press {buttonPressOrg.high_low_down_press = buttonPress.high_low_down_press;flag = false}
        if buttonPressOrg.trend_up_press != buttonPress.trend_up_press {buttonPressOrg.trend_up_press = buttonPress.trend_up_press;flag = false}
        if buttonPressOrg.trend_down_press != buttonPress.trend_down_press {buttonPressOrg.trend_down_press = buttonPress.trend_down_press;flag = false}
        if buttonPressOrg.night_mode_press != buttonPress.night_mode_press {buttonPressOrg.night_mode_press = buttonPress.night_mode_press;flag = false}
        if buttonPressOrg.light_mode_press != buttonPress.light_mode_press {buttonPressOrg.light_mode_press = buttonPress.light_mode_press;flag = false}
        if buttonPressOrg.chair_mode_press != buttonPress.chair_mode_press {buttonPressOrg.chair_mode_press = buttonPress.chair_mode_press;flag = false}
        if buttonPressOrg.setting_press != buttonPress.setting_press {buttonPressOrg.setting_press = buttonPress.setting_press;flag = false}
        if buttonPressOrg.connection_press != buttonPress.connection_press {buttonPressOrg.connection_press = buttonPress.connection_press;flag = false}
        return flag
    }
    func isSame()->Bool{
    var flag = true
    if self.ahfDataOrg.back_lock != self.ahfData.back_lock {ahfDataOrg.back_lock = self.ahfData.back_lock;flag = false}
    if self.ahfDataOrg.leg_lock != self.ahfData.leg_lock {ahfDataOrg.leg_lock = self.ahfData.leg_lock;flag = false}
    if self.ahfDataOrg.back_leg_lock != self.ahfData.back_leg_lock {ahfDataOrg.back_leg_lock = self.ahfData.back_leg_lock;flag = false}
    if self.ahfDataOrg.high_low_lock != self.ahfData.high_low_lock {ahfDataOrg.high_low_lock = self.ahfData.high_low_lock;flag = false}
    if self.ahfDataOrg.trend_lock != self.ahfData.trend_lock {ahfDataOrg.trend_lock = self.ahfData.trend_lock;flag = false}
    if self.ahfDataOrg.night_lock != self.ahfData.night_lock {ahfDataOrg.night_lock = self.ahfData.night_lock;flag = false}
    if self.ahfDataOrg.chair_lock != self.ahfData.chair_lock {ahfDataOrg.chair_lock = self.ahfData.chair_lock;flag = false}
    if self.ahfDataOrg.light_mode != self.ahfData.light_mode {ahfDataOrg.light_mode = self.ahfData.light_mode;flag = false}
    if self.bt_stage_org != self.bt_stage {self.bt_stage_org = self.bt_stage;flag = false}
    return flag
    }
    func buttonProcess(_ buttonValue:_buttonPress){
        if isSameButton() {return}
        if self.bt_stage == .function_ok
        {
            if !self.ahfData.back_lock
            {
                if buttonValue.back_up_press {backUpBtn.setImage(UIImage(named:"ic_up_white"), for: .normal)}
                else {backUpBtn.setImage(UIImage(named:"ic_up"), for: .normal)}
                if buttonValue.back_down_press {backDownBtn.setImage(UIImage(named:"ic_down_white"), for: .normal)}
                else {backDownBtn.setImage(UIImage(named:"ic_down"), for: .normal)}
            }
            if !self.ahfData.leg_lock
            {
                if buttonValue.leg_up_press {legUpBtn.setImage(UIImage(named:"ic_up_white"), for: .normal)}
                else {legUpBtn.setImage(UIImage(named:"ic_up"), for: .normal)}
                if buttonValue.leg_down_press {legDownBtn.setImage(UIImage(named:"ic_down_white"), for: .normal)}
                else {legDownBtn.setImage(UIImage(named:"ic_down"), for: .normal)}
            }
            if !self.ahfData.back_leg_lock
            {
                if buttonValue.back_leg_up_press {backLegUpBtn.setImage(UIImage(named:"ic_up_white"), for: .normal)}
                else {backLegUpBtn.setImage(UIImage(named:"ic_up"), for: .normal)}
                if buttonValue.back_leg_down_press {backLegDownBtn.setImage(UIImage(named:"ic_down_white"), for: .normal)}
                else {backLegDownBtn.setImage(UIImage(named:"ic_down"), for: .normal)}
            }
            if !self.ahfData.high_low_lock
            {
                if buttonValue.high_low_up_press {hiLowUpBtn.setImage(UIImage(named:"ic_up_white"), for: .normal)}
                else {hiLowUpBtn.setImage(UIImage(named:"ic_up"), for: .normal)}
                if buttonValue.high_low_down_press {hiLowDownBtn.setImage(UIImage(named:"ic_down_white"), for: .normal)}
                else {hiLowDownBtn.setImage(UIImage(named:"ic_down"), for: .normal)}
            }
            if !self.ahfData.trend_lock
            {
                if buttonValue.trend_up_press {trendUpBtn.setImage(UIImage(named:"ic_up_white"), for: .normal)}
                else {trendUpBtn.setImage(UIImage(named:"ic_up"), for: .normal)}
                if buttonValue.trend_down_press {trendDownBtn.setImage(UIImage(named:"ic_down_white"), for: .normal)}
                else {trendDownBtn.setImage(UIImage(named:"ic_down"), for: .normal)}
            }
            
            if !self.ahfData.night_lock
            {
                if buttonValue.night_mode_press {nightBtn.setImage(UIImage(named:"ic_circle_night_white"), for: .normal)}
                else {nightBtn.setImage(UIImage(named:"ic_circle_night"), for: .normal)}
            }
            //if buttonValue.light_mode_press {lightBtn.setImage(UIImage(named:"ic_circle_bedbottomlamp_white"), for: .normal)}
            //else {lightBtn.setImage(UIImage(named:"ic_circle_bedbottomlamp"), for: .normal)}
            if !self.ahfData.chair_lock
            {
                if buttonValue.chair_mode_press {chairBtn.setImage(UIImage(named:"ic_circle_chair_white"), for: .normal)}
                else {chairBtn.setImage(UIImage(named:"ic_circle_chair"), for: .normal)}
            }
            buttonPressUI = buttonValue
        }
    }
    func refreshUI(){
        if isSame() {return}
        if self.bt_stage == .function_ok
        {
            back_lock.isHidden = !self.ahfData.back_lock
            leg_lock.isHidden = !self.ahfData.leg_lock
            back_leg_lock.isHidden = !self.ahfData.back_leg_lock
            high_low_lock.isHidden = !self.ahfData.high_low_lock
            trend_lock.isHidden = !self.ahfData.trend_lock
            night_lock.isHidden = !self.ahfData.night_lock
            chair_lock.isHidden = !self.ahfData.chair_lock
            self.last_device = controlViewModel.get_last_device()
            self.BT_title.text = self.last_device//.replacingOccurrences(of: "_", with: " ")
            btConnectionBtn.setImage(UIImage(named:"ic_connect_on"), for: .normal)
            if self.ahfData.back_lock
            {
                backUpBtn.setImage(UIImage(named:"ic_up_antiwhite"), for: .normal)
                backDownBtn.setImage(UIImage(named:"ic_down_antiwhite"), for: .normal)
                backIcon.setImage(UIImage(named:"control_chairback_1_antiwhite"), for: .normal)
                backBk.backgroundColor = Color.disableBk
            }else
            {
                backUpBtn.setImage(UIImage(named:"ic_up"), for: .normal)
                backDownBtn.setImage(UIImage(named:"ic_down"), for: .normal)
                backIcon.setImage(UIImage(named:"control_chairback_1"), for: .normal)
                backBk.backgroundColor = Color.enableBk
            }
            if self.ahfData.leg_lock
            {
                legUpBtn.setImage(UIImage(named:"ic_up_antiwhite"), for: .normal)
                legDownBtn.setImage(UIImage(named:"ic_down_antiwhite"), for: .normal)
                legIcon.setImage(UIImage(named:"control_chairback_2_antiwhite"), for: .normal)
                legBk.backgroundColor = Color.disableBk
            }else
            {
                legUpBtn.setImage(UIImage(named:"ic_up"), for: .normal)
                legDownBtn.setImage(UIImage(named:"ic_down"), for: .normal)
                legIcon.setImage(UIImage(named:"control_chairback_2"), for: .normal)
                legBk.backgroundColor = Color.enableBk
            }
            if self.ahfData.back_leg_lock
            {
                backLegUpBtn.setImage(UIImage(named:"ic_up_antiwhite"), for: .normal)
                backLegDownBtn.setImage(UIImage(named:"ic_down_antiwhite"), for: .normal)
                backLegIcon.setImage(UIImage(named:"control_chairback_3_antiwhite"), for: .normal)
                backLegBk.backgroundColor = Color.disableBk
            }else
            {
                backLegUpBtn.setImage(UIImage(named:"ic_up"), for: .normal)
                backLegDownBtn.setImage(UIImage(named:"ic_down"), for: .normal)
                backLegIcon.setImage(UIImage(named:"control_chairback_3"), for: .normal)
                backLegBk.backgroundColor = Color.enableBk
            }
            if self.ahfData.high_low_lock
            {
                hiLowUpBtn.setImage(UIImage(named:"ic_up_antiwhite"), for: .normal)
                hiLowDownBtn.setImage(UIImage(named:"ic_down_antiwhite"), for: .normal)
                hiLowIcon.setImage(UIImage(named:"control_chairback_4_antiwhite"), for: .normal)
                hiLowBk.backgroundColor = Color.disableBk
            }else
            {
                hiLowUpBtn.setImage(UIImage(named:"ic_up"), for: .normal)
                hiLowDownBtn.setImage(UIImage(named:"ic_down"), for: .normal)
                hiLowIcon.setImage(UIImage(named:"control_chairback_4"), for: .normal)
                hiLowBk.backgroundColor = Color.enableBk
            }
            if self.ahfData.trend_lock
            {
                trendUpBtn.setImage(UIImage(named:"ic_up_antiwhite"), for: .normal)
                trendDownBtn.setImage(UIImage(named:"ic_down_antiwhite"), for: .normal)
                trendIcon.setImage(UIImage(named:"control_chairback_5_antiwhite"), for: .normal)
                trendBk.backgroundColor = Color.disableBk
            }else
            {
                trendUpBtn.setImage(UIImage(named:"ic_up"), for: .normal)
                trendDownBtn.setImage(UIImage(named:"ic_down"), for: .normal)
                trendIcon.setImage(UIImage(named:"control_chairback_5"), for: .normal)
                trendBk.backgroundColor = Color.enableBk
            }
            if self.ahfData.night_lock
            {
                nightBtn.setImage(UIImage(named:"ic_circle_night_antiwhite"), for: .normal)
            }else
            {
                nightBtn.setImage(UIImage(named:"ic_circle_night"), for: .normal)
            }
            if self.ahfData.chair_lock
            {
                chairBtn.setImage(UIImage(named:"ic_circle_chair_antiwhite"), for: .normal)
            }else
            {
                chairBtn.setImage(UIImage(named:"ic_circle_chair"), for: .normal)
            }
            if self.ahfData.light_mode == .off
            {
                lightBtn.setImage(UIImage(named:"ic_circle_bedbottomlamp_off"), for: .normal)
            }else if self.ahfData.light_mode == .white
            {
                lightBtn.setImage(UIImage(named:"ic_circle_bedbottomlamp_white"), for: .normal)
            }else if self.ahfData.light_mode == .green
            {
                lightBtn.setImage(UIImage(named:"ic_circle_bedbottomlamp_green"), for: .normal)
            }else if self.ahfData.light_mode == .red
            {
                lightBtn.setImage(UIImage(named:"ic_circle_bedbottomlamp_red"), for: .normal)
            }
        }else
        {
            self.BT_title.text = "AHF"
            btConnectionBtn.setImage(UIImage(named:"ic_connect_on_3seconds"), for: .normal)
            backUpBtn.setImage(UIImage(named:"ic_up_antiwhite"), for: .normal)
            backDownBtn.setImage(UIImage(named:"ic_down_antiwhite"), for: .normal)
            backIcon.setImage(UIImage(named:"control_chairback_1_antiwhite"), for: .normal)
            legUpBtn.setImage(UIImage(named:"ic_up_antiwhite"), for: .normal)
            legDownBtn.setImage(UIImage(named:"ic_down_antiwhite"), for: .normal)
            legIcon.setImage(UIImage(named:"control_chairback_2_antiwhite"), for: .normal)
            backLegUpBtn.setImage(UIImage(named:"ic_up_antiwhite"), for: .normal)
            backLegDownBtn.setImage(UIImage(named:"ic_down_antiwhite"), for: .normal)
            backLegIcon.setImage(UIImage(named:"control_chairback_3_antiwhite"), for: .normal)
            hiLowUpBtn.setImage(UIImage(named:"ic_up_antiwhite"), for: .normal)
            hiLowDownBtn.setImage(UIImage(named:"ic_down_antiwhite"), for: .normal)
            hiLowIcon.setImage(UIImage(named:"control_chairback_4_antiwhite"), for: .normal)
            trendUpBtn.setImage(UIImage(named:"ic_up_antiwhite"), for: .normal)
            trendDownBtn.setImage(UIImage(named:"ic_down_antiwhite"), for: .normal)
            trendIcon.setImage(UIImage(named:"control_chairback_5_antiwhite"), for: .normal)
            nightBtn.setImage(UIImage(named:"ic_circle_night_antiwhite"), for: .normal)
            chairBtn.setImage(UIImage(named:"ic_circle_chair_antiwhite"), for: .normal)
            lightBtn.setImage(UIImage(named:"ic_circle_bedbottomlamp_antiwhite"), for: .normal)
            backBk.backgroundColor = Color.disableBk
            legBk.backgroundColor = Color.disableBk
            backLegBk.backgroundColor = Color.disableBk
            hiLowBk.backgroundColor = Color.disableBk
            trendBk.backgroundColor = Color.disableBk
            back_lock.isHidden = true
            leg_lock.isHidden = true
            back_leg_lock.isHidden = true
            high_low_lock.isHidden = true
            trend_lock.isHidden =  true
            night_lock.isHidden = true
            chair_lock.isHidden = true
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if let cR : _ahfSetting = saveTool.readParams(name: "ahfSetting"){
            ahfSetting = cR
        }
        tools.scalProcess()
        setObserver()
        self.last_device = self.controlViewModel.get_last_device()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        tuneUI()
        AppUtility.lockOrientation(.portrait)
        self.last_device = self.controlViewModel.get_last_device()
        if self.last_device.count > 0
        {
            first_reconnection = true
        }
       // backUpBtn.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
      //  backUpBtn.addTarget(self, action: #selector(didDragInsideButton), for: .touchDragInside)
        //backUpBtn.addTarget(self, action: #selector(backUpReleaseAction), for: .touchDragOutside)
        // Do any additional setup after loading the view.
    }
    func tuneUI(){
    print("below_bk1:\(below_bk.frame)")
    tuneUI(view: self.view)
    backBk.layer.cornerRadius = backBk.frame.size.height / 2
    legBk.layer.cornerRadius = legBk.frame.size.height / 2
    backLegBk.layer.cornerRadius = backLegBk.frame.size.height / 2
    hiLowBk.layer.cornerRadius = hiLowBk.frame.size.height / 2
    trendBk.layer.cornerRadius = trendBk.frame.size.height / 2
    print("below_bk2:\(below_bk.frame)")
}
    func tuneUI(view:UIView){
    for subview in view.subviews {
        if subview == below_bk {continue}
        if subview == ahf_logo {continue}
        if subview == btConnectionBtn {continue}
        if subview == settingBtn {continue}
        
        subview.frame.origin.x = subview.frame.origin.x * scaleW
        subview.frame.origin.y = subview.frame.origin.y * scaleH
        if subview.frame.size.width == subview.frame.size.height
        {
            subview.frame.size.width = subview.frame.size.width * scaleH
        }
        else
        {
            subview.frame.size.width = subview.frame.size.width * scaleW
        }
        subview.frame.size.height = subview.frame.size.height * scaleH
        
        for subview1 in subview.subviews {
                subview1.frame.origin.x = subview1.frame.origin.x * scaleW
                subview1.frame.origin.y = subview1.frame.origin.y * scaleH
                    if subview1.frame.size.width == subview1.frame.size.height
                    {
                        subview1.frame.size.width = subview1.frame.size.width * scaleH
                    }
                    else
                    {
                        subview1.frame.size.width = subview1.frame.size.width * scaleW
                    }
                subview1.frame.size.height = subview1.frame.size.height * scaleH
            }
    }
}
    @objc func appMovedToBackground() {
        print(tag,"App moved to background!:\(self.bt_stage.rawValue)")
        move_background_flag = true
        if currentDialog == .connectingDialog || currentDialog == .reConnectingDialog
        {
            alert_dialog_dismiss()
        }
    }
    @objc func appMovedToForeground() {
        self.bt_state = controlViewModel.get_bt_state()
        //self.BtDialog.isHidden = true
        //let array = Bundle.main.preferredLocalizations
        //let lang  = String(array.first!)
        //print("lang:\(lang)")
        //UserDefaults.standard.set(lang, forKey: "lang") //儲存語系為基本
        print(tag,"App moved to foreground! self.bt_state:\(self.bt_state.rawValue),\(self.bt_stage.rawValue),last_device:\(self.last_device)")
        background_flag_timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (ktimer) in
            self.move_background_flag = false
            print(self.tag,"move_background_flag:\(self.move_background_flag)")
        }
        if self.bt_state == .unauthorized
        {
            allowBtAccessDialog()
        }else if self.bt_state == .poweredOff
        {
            self.connecting_cnt = 0
            self.alert_dialog_dismiss()
            self.view.showToast(text: "Device bluetooth is \nturned off.".localized)
        }
        self.refreshUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        print(self.tag,"viewWillAppear")
        //print(self.tag,"self.bt_stage::\(self.bt_stage)")
        currentVC = .ControlViewControllerNum
        alert_dialog_show()
        self.timer?.invalidate()
        self.timer=Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (ktimer) in   //print(self.tag,"self.bt_stage:\(self.bt_stage),self.bt_state:\(self.bt_state.rawValue),connecting_cnt:\(self.connecting_cnt)")
            //print(self.tag,"currentVC:\(currentVC),self.bt_stage:\(self.bt_stage),self.connecting_cnt:\(self.connecting_cnt)")
            if currentVC == .SettingsViewControllerNum
            {
                //print(self.tag,"skip check SettingsViewControllerNum")
                if self.bt_stage == .notify_ok { self.bt_stage = .function_ok }
            }else
            {
            self.auto_lock_proc()
            if self.connecting_cnt > 0
            {
                print(self.tag,"connecting_cnt:\(self.connecting_cnt)")
                if self.connecting_cnt == 1
                {
                    print(self.tag,"connection fail")
                    if self.last_device.count > 0 //re-connect failure
                    {
                        let show_text = "\("Connection failed.".localized)\n\(self.last_device) \("not in range.".localized)"
                        self.view.showToast(text: show_text)
                    }else
                    {
                        self.view.showToast(text: "Connection failed.".localized)
                    }
                    self.clearConnection()
                    self.bt_stage = .failure
                }else
                {
                    if self.bt_stage == .disconnected
                    {
                        self.last_device = self.controlViewModel.get_last_device()
                        print(self.tag,"timer: disconnected :\(self.last_device)")
                        if self.last_device.count > 0
                        {
                            if self.bt_state == .poweredOff
                            {
                                self.connecting_cnt = 0
                                self.view.showToast(text: "Device bluetooth is \nturned off.".localized)
                                self.alert_dialog_dismiss()
                            }else
                            {
                                self.disconnectDialog()
                            }
                        }
                    }else if self.bt_stage == .notify_ok// || self.bt_stage == .function_ok
                    {
                        print(self.tag,"notify_ok to function_ok..")
                        self.last_device = self.controlViewModel.get_last_device()
                        let show_text = "\(self.last_device) \("connected.".localized)"
                        print(self.tag,"show_text:\(show_text)")
                        self.view.showToast(text: show_text)
                        self.bt_stage = .function_ok
                        self.alert_dialog_dismiss()
                        self.refreshUI()
                        self.connecting_cnt = 0
                    }
                }
                if self.currentDialog != .disconnectDialog  //waitting for user choose disconnect or retry.
                {
                    self.connecting_cnt = self.connecting_cnt - 1
                }
            }else if self.bt_state == .poweredOn && self.last_device.count > 0 && (self.bt_stage == .connecting || self.bt_stage == .is_connect || self.bt_stage == .disconnected)
            {
                print(self.tag,"connecting or is_connect auto connect to last_device:\(self.last_device),\(self.bt_state)")
                if self.first_reconnection
                {
                    self.reConnectingDialog()
                    self.first_reconnection = false
                }else
                {
                    self.disconnectDialog()
                }
            }
            }
        }
        print("get_last_device last device :\(last_device)")
    }
    func auto_lock_proc(){
        print(self.tag,"auto_lock_time_cnt[\(ahfSetting.auto_lock_time)]:\(ahfSetting.auto_lock_time_cnt),last_device:\(last_device),self.bt_stage:\(self.bt_stage),\(self.bt_state.rawValue),currentVC:\(currentVC)")
        if currentVC != .LockViewControllerNum && self.bt_stage == .function_ok
        {
            if ahfSetting.auto_lock_time_cnt < ahfSetting.auto_lock_time
            {
                ahfSetting.auto_lock_time_cnt = ahfSetting.auto_lock_time_cnt + 1
            }else
            {
                goToLockScreen()
                ahfSetting.auto_lock_time_cnt = 0
            }
            if self.chkMutliKeyPressCnt(buttonPressUI) == 1 {ahfSetting.auto_lock_time_cnt = 0}
        }
    }
    override func viewDidAppear(_ animated: Bool) {
    }
    override func viewWillDisappear(_ animated: Bool) {
        print(self.tag,"viewWillDisappear")
        allKeyClear()
        buttonPressOrg = allKeyCopy(buttonSourceData: buttonPress)
        buttonPressUI = allKeyCopy(buttonSourceData: buttonPress)
        //removeObserver()
        //self.timer?.invalidate()
    }
    func chkMutliKeyPressCnt(_ buttonPress:_buttonPress)->Int{
        var keyCnt = 0
        if buttonPress.back_up_press {keyCnt = keyCnt+1}
        if buttonPress.back_down_press {keyCnt = keyCnt+1}
        if buttonPress.leg_up_press {keyCnt = keyCnt+1}
        if buttonPress.leg_down_press {keyCnt = keyCnt+1}
        if buttonPress.back_leg_up_press {keyCnt = keyCnt+1}
        if buttonPress.back_leg_down_press {keyCnt = keyCnt+1}
        if buttonPress.high_low_up_press {keyCnt = keyCnt+1}
        if buttonPress.high_low_down_press {keyCnt = keyCnt+1}
        if buttonPress.trend_up_press {keyCnt = keyCnt+1}
        if buttonPress.trend_down_press {keyCnt = keyCnt+1}
        if buttonPress.night_mode_press {keyCnt = keyCnt+1}
        if buttonPress.light_mode_press {keyCnt = keyCnt+1}
        if buttonPress.chair_mode_press {keyCnt = keyCnt+1}
        if buttonPress.setting_press {keyCnt = keyCnt+1}
        if buttonPress.connection_press {keyCnt = keyCnt+1}
        return keyCnt
    }
    func allKeyClear(){
        print("allKeyClear")
        buttonPress.back_up_press = false
        buttonPress.back_down_press = false
        buttonPress.leg_up_press = false
        buttonPress.leg_down_press = false
        buttonPress.back_leg_up_press = false
        buttonPress.back_leg_down_press = false
        buttonPress.high_low_up_press = false
        buttonPress.high_low_down_press = false
        buttonPress.trend_up_press = false
        buttonPress.trend_down_press = false
        buttonPress.night_mode_press = false
        buttonPress.light_mode_press = false
        buttonPress.chair_mode_press = false
        buttonPress.setting_press = false
        buttonPress.connection_press = false
    }
    func allKeyCopy(buttonSourceData:_buttonPress)->_buttonPress{
        var buttonTargetData = _buttonPress()
        buttonTargetData.back_up_press = buttonSourceData.back_up_press
        buttonTargetData.back_down_press = buttonSourceData.back_down_press
        buttonTargetData.leg_up_press = buttonSourceData.leg_up_press
        buttonTargetData.leg_down_press = buttonSourceData.leg_down_press
        buttonTargetData.back_leg_up_press = buttonSourceData.back_leg_up_press
        buttonTargetData.back_leg_down_press = buttonSourceData.back_leg_down_press
        buttonTargetData.high_low_up_press = buttonSourceData.high_low_up_press
        buttonTargetData.high_low_down_press = buttonSourceData.high_low_down_press
        buttonTargetData.trend_up_press = buttonSourceData.trend_up_press
        buttonTargetData.trend_down_press = buttonSourceData.trend_down_press
        buttonTargetData.night_mode_press = buttonSourceData.night_mode_press
        buttonTargetData.light_mode_press = buttonSourceData.light_mode_press
        buttonTargetData.chair_mode_press = buttonSourceData.chair_mode_press
        buttonTargetData.setting_press = buttonSourceData.setting_press
        buttonTargetData.connection_press = buttonSourceData.connection_press
        return buttonTargetData
    }
    func allKeyRelease(_ skip_haptics:Bool = false)->Bool{
        if self.bt_stage != .function_ok && !buttonPress.connection_press && !buttonPress.setting_press
        {
            allKeyClear()
            print("allKeyRelease bt_stage:\(self.bt_stage)")
            return false
        }
        //print(self.tag,"allKeyRelease back_up_press:\(buttonPress.back_up_press),back_down_press:\(buttonPress.back_down_press)")
        if chkMutliKeyPressCnt(buttonPress) > 1
        {
            ahfViewModel.execute(action: .release)
            let buttonPressBuf = buttonPress
            allKeyClear()
            buttonProcess(buttonPress)
            buttonPress = buttonPressBuf
            return false
        }
        //print("skip_haptics : \(skip_haptics)")
        if skip_haptics
        {
            ahfSetting.auto_lock_time_cnt = 0
            return true
        }else if self.bt_stage == .function_ok
        {
            if ahfSetting.system_haptics {AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)}
            ahfSetting.auto_lock_time_cnt = 0
            return true
        }
        print("allKeyRelease : bt_stage:\(self.bt_stage)")
        return false
    }
    func allowBtAccessDialog(){
    if currentVC != .ControlViewControllerNum {print("currentVC is not control,skip dialog!");return}
    if currentDialog != .none {print("had a dialog,skip!");return}
    currentDialog = .allowBtAccessDialog
    print("allowBtAccessDialog")
    allowBtAccessDialogView.allowBtAccessDialogDismissDelegate = self
    let alert = Malert(customView: allowBtAccessDialogView,tapToDismiss: false)
    allowBtAccessDialogView.alert = alert
    self.present(alert, animated: true)
}
    func closeAction() {
        print("CLOSE")
        self.alert_dialog_dismiss()
    }
    func settingsAction() {
        print("SETTINGS")
        self.alert_dialog_dismiss()
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {return}
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("unauthorized opened: \(success)") })
        }
    }
    func manualDisconnectDialog(){
        if currentVC != .ControlViewControllerNum {print("currentVC is not control,skip dialog!");return}
        if currentDialog != .none {print("had a dialog,skip!");return}
        currentDialog = .manualDisconnectDialog
        print("manualDisconnectAction")
        manualDisconnectDialogView.manualDisconnectDialogDismissDelegate = self
        let alert = Malert(customView: manualDisconnectDialogView,tapToDismiss: false)
        manualDisconnectDialogView.alert = alert
        manualDisconnectDialogView.devName.text = self.last_device
        self.present(alert, animated: true)
    }
    func manualDisconnectAction() {
        print("manualDisconnectAction")
        self.clearConnection()
    }
    func manualDisconnectCancelAction() {
        print("manualDisconnectCancelAction")
        self.alert_dialog_dismiss()
    }
    func disconnectDialog(){
        if currentVC != .ControlViewControllerNum {print("currentVC is not control,skip dialog!");return}
        if currentDialog != .none {print("had a dialog,skip!");return}
        currentDialog = .disconnectDialog
        print("disconnectDialog")
        disconnectDialogView.disconnectDialogDismissDelegate = self
        let alert = Malert(customView: disconnectDialogView,tapToDismiss: false)
        disconnectDialogView.alert = alert
        self.present(alert, animated: true)
    }
    func tryLaterAction() {
        print("TRY LATER")
        self.clearConnection()
    }
    func reConnectAction() {
        print("RE-CONNECT")
        self.alert_dialog_dismiss()
        if self.bt_state == .poweredOff
        {
            self.view.showToast(text: "Device bluetooth is \nturned off.".localized)
        }else
        {
            self.reConnectingDialog()
            self.BT_title.text = "AHF"
            self.controlViewModel.set_bt_stage(data: .init_value)
        }
    }
    func disconnectAction() {
        print("disconnectAction")
        self.alert_dialog_dismiss()
    }
    func disconnectCancelAction() {
        self.clearConnection()
    }
    func reConnectingDialog(){
        if currentVC != .ControlViewControllerNum {print("currentVC is not control,skip dialog!");return}
        if currentDialog != .none {print("had a dialog,skip!");return}
        self.connecting_cnt = 30
        self.controlViewModel.reScanBt()
        if self.last_device.count > 0 //direct connect
        {
            reConnectingDialogView.reConnectingDialogViewDelegate = self
            let alert = Malert(customView: reConnectingDialogView,tapToDismiss: false)
            reConnectingDialogView.alert = alert
            reConnectingDialogView.devName.text = self.last_device
            currentDialog = .reConnectingDialog
            self.present(alert, animated: true)
        }else
        {
            connectingDialogView.connectingDialogViewDelegate = self
            let alert = Malert(customView: connectingDialogView,tapToDismiss: false)
            connectingDialogView.alert = alert
            currentDialog = .connectingDialog
            self.present(alert, animated: true)
        }
    }
    func dismissReConnectingDialog() {
        print(self.tag,"dismissReConnectingDialog")
        self.clearConnection()
    }
    func dismissConnectingDialog() {
        self.clearConnection()
        print(self.tag,"dismissConnectingDialog")
    }
    func clearConnection(){
    print(self.tag,"clearConnection")
    self.controlViewModel.stopScan()
    self.controlViewModel.disconnect()
    self.bt_stage = .disconnected
    self.controlViewModel.set_bt_stage(data: self.bt_stage)
    self.last_device = ""
    self.BT_title.text = "AHF"
    self.controlViewModel.set_last_device(bt_name: "")
    self.alert_dialog_dismiss()
    self.refreshUI()
}
    func disconnection(){
    print(self.tag,"disconnection")
    self.controlViewModel.stopScan()
    self.controlViewModel.disconnect()
    self.bt_stage = .disconnected
    self.controlViewModel.set_bt_stage(data: self.bt_stage)
    self.alert_dialog_dismiss()
    self.refreshUI()
}
    func alert_dialog_dismiss(){
        switch(currentDialog)
        {
        case .none:
            break
        case .connectingDialog:
            connectingDialogView.alert?.dismiss(animated: true, completion: {
                print("connectingDialogView dismiss")})
        case .reConnectingDialog:
            reConnectingDialogView.alert?.dismiss(animated: true, completion: {
                print("reconnectingDialogView dismiss")})
        case .manualDisconnectDialog:
            manualDisconnectDialogView.alert?.dismiss(animated: true, completion: {
                print("manualDisconnectDialogView dismiss")})
        case .disconnectDialog:
            disconnectDialogView.alert?.dismiss(animated: true, completion: {
                print("disconnectDialogView dismiss")})
        case .allowBtAccessDialog:
            allowBtAccessDialogView.alert?.dismiss(animated: true, completion: {
                print("allowBtAccessDialogView dismiss")})
        }
        ahfSetting.auto_lock_time_cnt = 0
        currentDialog = .none
    }
    public func alert_dialog_all_dismiss(){
        let currentDialogBuf = currentDialog
        alert_dialog_dismiss()
        currentDialog = currentDialogBuf
        print("alert_dialog_all_dismiss \(currentDialog)")
    }
    public func alert_dialog_show(){
    switch(currentDialog)
    {
    case .none:
        break
    case .connectingDialog:
        connectingDialogView.connectingDialogViewDelegate = self
        let alert = Malert(customView: connectingDialogView,tapToDismiss: false)
        connectingDialogView.alert = alert
        currentDialog = .connectingDialog
        self.present(alert, animated: true)
        break
    case .reConnectingDialog:
        reConnectingDialogView.reConnectingDialogViewDelegate = self
        let alert = Malert(customView: reConnectingDialogView,tapToDismiss: false)
        reConnectingDialogView.alert = alert
        reConnectingDialogView.devName.text = self.last_device
        currentDialog = .reConnectingDialog
        self.present(alert, animated: true)
        break
    case .manualDisconnectDialog:
        manualDisconnectDialogView.manualDisconnectDialogDismissDelegate = self
        let alert = Malert(customView: manualDisconnectDialogView,tapToDismiss: false)
        manualDisconnectDialogView.alert = alert
        manualDisconnectDialogView.devName.text = self.last_device
        self.present(alert, animated: true)
        break
    case .disconnectDialog:
        disconnectDialogView.disconnectDialogDismissDelegate = self
        let alert = Malert(customView: disconnectDialogView,tapToDismiss: false)
        disconnectDialogView.alert = alert
        self.present(alert, animated: true)
        break
    case .allowBtAccessDialog:
        allowBtAccessDialogView.allowBtAccessDialogDismissDelegate = self
        let alert = Malert(customView: allowBtAccessDialogView,tapToDismiss: false)
        allowBtAccessDialogView.alert = alert
        self.present(alert, animated: true)
        break
    }
    print("alert_dialog_show \(currentDialog)")
}
    func goToSettings(){
    var hasData = false
    let viewControllers:[UIViewController] = self.navigationController!.viewControllers
    for vc in viewControllers {
        if vc.isKind(of: SettingsViewController.classForCoder())
        {
            print("SettingsViewController is in stack")
            let vc = vc as! SettingsViewController
            //vc.btListViewModel.disconnect()
            self.navigationController?.popToViewController(vc , animated: false)
            hasData = true
            break;
        }
    }
    if !hasData
    {
        print("push SettingsViewController")
        let window = UIApplication.shared.windows[0]
        var name:String = "Main"
        if window.safeAreaInsets.bottom == 0 {name = "MainSe"}
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        //vc.btListViewModel.disconnect()
        self.navigationController?.pushViewController(vc,animated: false)
    }
}
    func goToLockScreen(){
    alert_dialog_all_dismiss()
    var hasData = false
    let viewControllers:[UIViewController] = self.navigationController!.viewControllers
    for vc in viewControllers {
        if vc.isKind(of: LockViewController.classForCoder())
        {
            print("LockViewController is in stack")
            let vc = vc as! LockViewController
            self.navigationController?.popToViewController(vc , animated: false)
            hasData = true
            break;
        }
    }
    if !hasData
    {
        print("push LockViewController")
        let window = UIApplication.shared.windows[0]
        var name:String = "Main"
        if window.safeAreaInsets.bottom == 0 {name = "MainSe"}
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LockViewController") as! LockViewController
        self.navigationController?.pushViewController(vc,animated: false)
    }
}
    
}

