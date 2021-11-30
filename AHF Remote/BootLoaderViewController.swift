//
//  BootLoaderViewController.swift
//  AHF Remote
//
//  Created by benson chan on 2021/11/12.
//

import UIKit

class BootLoaderViewController: UIViewController {
    private let saveTool = SaveTool.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        language_init()
        goToControl()
        // Do any additional setup after loading the view.
    }
    func language_init()
    {
        //let array   = UserDefaults.standard.object(forKey: "AppleLanguages") //返回的也是陣列
        /*let appLanguages   = Locale.preferredLanguages // 返回一個數組
        let deviceLanguage = Locale.current.languageCode
        let bundleLanguages = Bundle.main.preferredLocalizations // 返回一個數組

        //let availableLanguages = Localize.availableLanguages() // 必須引入第三方庫 import Localize_Swift, 獲取當前 app 所有支援的語言列表
        //let currentLanguage = Localize.currentLanguage() // 引入第三方庫，表示當前 App 使用的語言
        */
        let array = Bundle.main.preferredLocalizations
        let lang  = String(array.first!)
        print("lang:\(lang)")
        UserDefaults.standard.set(lang, forKey: "lang") //儲存語系為基本
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
            print("safeAreaInsets:\(window.safeAreaInsets.bottom),name:\(name)")
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
