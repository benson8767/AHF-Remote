//
//  SettingsViewController.swift
//  AHF MEDIFIT
//
//  Created by benson chan on 2021/11/8.
//

import UIKit
import ActionSheetPicker_3_0
var ahfSetting = _ahfSetting()
class SettingsViewController: UIViewController {
    private let saveTool = SaveTool.sharedInstance
    @IBOutlet weak var automatic_lock_time: UILabel!
    @IBOutlet weak var unlock_press_time: UILabel!
    @IBOutlet weak var hapticsSw: UISwitch!
    @IBOutlet weak var version_info: UILabel!
    @IBOutlet weak var settings: UILabel!
    @IBOutlet weak var application: UILabel!
    @IBOutlet weak var system_haptics: UILabel!
    @IBOutlet weak var system_haptics_info: UILabel!
    @IBOutlet weak var security: UILabel!
    @IBOutlet weak var automatic_lock_after: UILabel!
    @IBOutlet weak var unlock_after_pressing: UILabel!
    @IBOutlet weak var about: UILabel!
    @IBOutlet weak var version: UILabel!
    var acp = ActionSheetStringPicker()
    @IBAction func hapticsAction(_ sender: Any) {
        if (sender as AnyObject).isOn {
            print("ON")
            ahfSetting.system_haptics = true
        } else {
            print("OFF")
            ahfSetting.system_haptics = false
        }
    }
    func getCurrentTimeIndex(timeArray:[String],time:String)->Int
    {
        for i in 0..<timeArray.count
        {
            if timeArray[i] == time
            {
                return i
            }
        }
        return 0
    }
    @IBAction func automatic_lock_action(_ sender: Any) {
        //print("automatic_lock_action")
        let timeArray:[String] = ["10s","15s","20s","25s","30s"]
        let currentTimeIndex = getCurrentTimeIndex(timeArray:timeArray,time:"\(ahfSetting.auto_lock_time)s")
        acp = ActionSheetStringPicker(title: "Automatic Lock After1".localized,
                                     
                                     rows: timeArray,
                                     initialSelection: currentTimeIndex,
                                          doneBlock: { [self] picker, value, index in
                                        print("picker = \(String(describing: picker))")
                                        print("value = \(timeArray[value])")
                                        print("index = \(String(describing: index))")
            ahfSetting.auto_lock_time = UInt16(timeArray[value].prefix(2))!
            self.automatic_lock_time.text = "\(ahfSetting.auto_lock_time)s"
            var sec_value = value
            if sec_value == 0 {sec_value = 10} else {sec_value = (sec_value + 2) * 5}
            ahfSetting.auto_lock_time = UInt16(sec_value)
            print("auto_lock_time = \(ahfSetting.auto_lock_time)")
            self.saveTool.writeParams(name: "ahfSetting", data: ahfSetting)
                                        return
                                     },
                                     cancel: { picker in
                                        return
                                     },
                                     origin: self.view)
        
        let font = UIFont.boldSystemFont(ofSize: 22*scaleW)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.firstLineHeadIndent = 10.0
        acp.pickerTextAttributes = [NSAttributedString.Key.font:font,
                                    NSAttributedString.Key.foregroundColor: Color.picker_text,
                                    NSAttributedString.Key.paragraphStyle: paragraphStyle]
        acp.pickerBackgroundColor = UIColor.white
        acp.toolbarBackgroundColor = UIColor.white
        //acp.toolbarButtonsColor = UIColor.white
        
        // custom button
       let okButton = UIButton()
        okButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18*scaleW)
       okButton.setTitle("OK".localized, for: .normal)
        okButton.setTitleColor(Color.dialog_button_text, for: .normal)
       let customDoneButton = UIBarButtonItem.init(customView: okButton)
       acp.setDoneButton(customDoneButton)
        let cancelButton = UIButton()
        cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18*scaleW)
        cancelButton.setTitle("CANCEL".localized, for: .normal)
        cancelButton.setTitleColor(Color.dialog_button_text, for: .normal)
        let customCancelButton = UIBarButtonItem.init(customView: cancelButton)
        acp.setCancelButton(customCancelButton)
        acp.show()
    }
    @IBAction func unlock_press_action(_ sender: Any) {
        //print("unlock_press_action")
        let timeArray:[String] = ["1s","2s","3s","4s","5s","6s"]
        let currentTimeIndex = getCurrentTimeIndex(timeArray:timeArray,time:"\(ahfSetting.unlock_press_time)s")
        acp = ActionSheetStringPicker.init(title: "Unlock After Pressing1".localized,
                                     rows: timeArray,
                                     initialSelection: currentTimeIndex,
                                     doneBlock: { picker, value, index in
                                        print("picker = \(String(describing: picker))")
                                        print("value = \(timeArray[value])")
                                        print("index = \(String(describing: index))")
            ahfSetting.unlock_press_time = UInt16(timeArray[value].prefix(1))!
            self.unlock_press_time.text = "\(ahfSetting.unlock_press_time)s"
            ahfSetting.unlock_press_time = UInt16(value+1)
            print("unlock_press_time = \(value+1)")
            self.saveTool.writeParams(name: "ahfSetting", data: ahfSetting)
                                        return
                                     },
                                     cancel: { picker in
                                        return
                                     },
                                     origin: self.view)
        let font = UIFont.boldSystemFont(ofSize: 22*scaleW)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.firstLineHeadIndent = 10.0
        acp.pickerTextAttributes = [NSAttributedString.Key.font:font,
                                    NSAttributedString.Key.foregroundColor: Color.picker_text,
                                    NSAttributedString.Key.paragraphStyle: paragraphStyle]
        acp.pickerBackgroundColor = UIColor.white
        acp.toolbarBackgroundColor = UIColor.white
        //acp.toolbarButtonsColor = UIColor.white
        // custom button
       let okButton = UIButton()
        okButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18*scaleW)
       okButton.setTitle("OK".localized, for: .normal)
        okButton.setTitleColor(Color.dialog_button_text, for: .normal)
       let customDoneButton = UIBarButtonItem.init(customView: okButton)
        acp.setDoneButton(customDoneButton)
        let cancelButton = UIButton()
        cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18*scaleW)
        cancelButton.setTitle("CANCEL".localized, for: .normal)
        cancelButton.setTitleColor(Color.dialog_button_text, for: .normal)
        let customCancelButton = UIBarButtonItem.init(customView: cancelButton)
        acp.setCancelButton(customCancelButton)
        acp.show()
    }
    @IBAction func backAction(_ sender: Any) {
//dump(ahfSetting)
        saveTool.writeParams(name: "ahfSetting", data: ahfSetting)
        goToControl()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        version_info.text = "\(String(describing: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String))";
        tools.tuneUI(view: self.view)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        currentVC = .SettingsViewControllerNum
        settings.text = "Settings".localized
        application.text = "APPLICATION".localized
        system_haptics.text = "System Haptics".localized
        system_haptics_info.text = "Play haptics for bed control".localized
        system_haptics_info.sizeToFit()
        security.text = "SECURITY".localized
        automatic_lock_after.text = "Automatic Lock After".localized
        unlock_after_pressing.text = "Unlock After Pressing".localized
        about.text = "ABOUT".localized
        version.text = "Version".localized
        if ahfSetting.system_haptics
        {
            hapticsSw.isOn = true
        }else
        {
            hapticsSw.isOn = false
        }
        automatic_lock_time.text = "\(ahfSetting.auto_lock_time)s"
        unlock_press_time.text = "\(ahfSetting.unlock_press_time)s"
    }
    func goToControl()
    {
        var hasData = false
        let viewControllers:[UIViewController] = self.navigationController!.viewControllers
        for vc in viewControllers {
            if vc.isKind(of: ControlViewController.classForCoder())
            {
                print("ControlViewController is in stack")
                let vc = vc as! ControlViewController
                self.navigationController?.popToViewController(vc , animated: false)
                hasData = true
                break;
            }
        }
        if !hasData
        {
            print("push ControlViewController")
            let window = UIApplication.shared.windows[0]
            var name:String = "Main"
            if window.safeAreaInsets.bottom == 0 {name = "MainSe"}
            let storyboard = UIStoryboard(name: name, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ControlViewController") as! ControlViewController
            self.navigationController?.pushViewController(vc,animated: false)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
