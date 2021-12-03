//
//  LockViewController.swift
//  AHF MEDIFIT
//
//  Created by benson chan on 2021/11/9.
//

import UIKit
import KDCircularProgress

class LockViewController: UIViewController {
    var tag = "LockViewController"
    var progress: KDCircularProgress!
    @IBOutlet weak var unlockBtn: UIButton!
    @IBOutlet weak var unlockCircle: UIView!
    @IBOutlet weak var unlockTitle: UILabel!
    var timer: Timer?
    var step: UInt16 = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        tuneUI(view: self.view)
        //print("unlockCircle.frame1:\(unlockCircle.frame)")
        //progress = KDCircularProgress(frame: CGRect(x:fullScreenSize.width*0.02*scaleW, y: fullScreenSize.height*0.28*scaleH, width: fullScreenSize.width*0.96*scaleW, height: fullScreenSize.width*0.96*scaleH))
        //print("progress.frame:\(progress.frame)")
        /*unlockCircle.frame = progress.frame
        unlockCircle.frame.size.width = progress.frame.size.width * 0.65
        unlockCircle.frame.size.height = progress.frame.size.width * 0.65
        unlockBtn.center = progress.center
        unlockCircle.center = unlockBtn.center
        unlockCircle.layer.cornerRadius = unlockCircle.frame.size.width / 2*/
        //print("unlockCircle.frame:\(unlockCircle.frame)")
        unlockCircle.layer.cornerRadius = unlockCircle.frame.size.width / 2
        progress = KDCircularProgress(frame:unlockCircle.frame)
        progress.frame.size.width = progress.frame.size.width * 1.5
        progress.frame.size.height = progress.frame.size.height * 1.5
        progress.center = unlockCircle.center
        progress.startAngle = -90
        progress.progressThickness = 0.2
        progress.trackThickness = 0.2
        progress.clockwise = true
        progress.gradientRotateSpeed = 0.01
        progress.roundedCorners = true
        progress.glowMode = .forward
        progress.glowAmount = 0.1
        progress.trackColor = .white
        progress.set(colors: Color.dialog_button_text)
        //progress.set(colors: UIColor.cyan ,UIColor.white, UIColor.magenta, UIColor.white, UIColor.orange)
        //progress.center = unlockBtn.center
        view.addSubview(progress)
        self.view.sendSubviewToBack(self.progress)
        unlockCircle.backgroundColor = .white
        // Do any additional setup after loading the view.
    }
    func tuneUI(view:UIView){
    for subview in view.subviews {
        //if subview == progress {continue}
        //if subview == unlockBtn {continue}
        //if subview == unlockBk {continue}
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
        
       /* for subview1 in subview.subviews {
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
            }*/
    }
}
    override func viewWillAppear(_ animated: Bool) {
        print(self.tag,"viewWillAppear")
        currentVC = .LockViewControllerNum
        unlockTitle.text = "Press and hold\nLOCK KEY\nto unlock.".localized
    }
    override func viewWillDisappear(_ animated: Bool) {
        print(self.tag,"viewWillDisappear")
        self.timer?.invalidate()
    }
    
    @IBAction func sliderDidChangeValue(_ sender: UISlider) {
        progress.angle = Double(sender.value)
    }
    
    @IBAction func animateButtonTapped(_ sender: UIButton) {
        progress.animate(fromAngle: 0, toAngle: 360, duration: 5) { completed in
            if completed {
                print("animation stopped, completed")
            } else {
                print("animation stopped, was interrupted")
            }
        }
    }
    
    @IBAction func unlock_down_action(_ sender: Any) {
        print("unlock_down_action:\(ahfSetting.unlock_press_time)")
        step = UInt16((36 / Float(ahfSetting.unlock_press_time)))
        print("unlock_down_action step:\(step)")
        unlockCircle.backgroundColor = Color.unlock_bk
        self.timer=Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (ktimer) in
            print("self.progress.angle:\(self.progress.angle)")
            if self.progress.angle < 360
            {
                self.progress.angle = self.progress.angle + Double(self.step)
            }else
            {
                self.progress.angle = 360
                self.goToControl()
                ahfSetting.unlock_press_time_cnt = ahfSetting.unlock_press_time
                self.timer?.invalidate()
                print("complete")
            }
        }
    }
    
    @IBAction func unlock_release_action(_ sender: Any) {
        print("unlock_release_action")
        unlockCircle.backgroundColor = .white
        self.progress.angle = 0
        self.timer?.invalidate()
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
