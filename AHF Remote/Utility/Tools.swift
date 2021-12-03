//
//  Utility.swift
//  JMS Medical Bed
//
//  Created by benson chan on 2021/9/29.
//

import UIKit
import Foundation
import DeviceKit

// 取得螢幕的尺寸
var fullScreenSize = UIScreen.main.bounds.size
var scaleW:CGFloat = 1, scaleH:CGFloat = 1
var fix_scale = false
let tools = Tools()
class Tools:NSObject
{
    func scalProcess()
    {
        let device = Device.current
        //var device_size = CGSize(width: device.screenRatio.width, height: device.screenRatio.height)
        var ref_w:CGFloat = 414,ref_h:CGFloat = 896//818
        var pixel_w:CGFloat = UIScreen.main.nativeBounds.width
        var pixel_h:CGFloat = UIScreen.main.nativeBounds.height
        var render:CGFloat = pixel_w / fullScreenSize.width
        let window = UIApplication.shared.windows[0]
        if window.safeAreaInsets.bottom == 0  //no home area
        {
            ref_w = 375
            ref_h = 667
        }
        print("name:\(String(describing: device.name)),device:\(device.description),screen:\(device.screenRatio),pixel_w:\(pixel_w),pixel_h:\(pixel_h),safeArea bottom:\(window.safeAreaInsets.bottom)")
        if fullScreenSize.height < fullScreenSize.width
        {
            var buf = fullScreenSize.width
            fullScreenSize.width = fullScreenSize.height
            fullScreenSize.height = buf
            buf = pixel_w
            pixel_w = pixel_h
            pixel_h = buf
            print("rotate portrait")
        }
        if fix_scale
        {
            print("fix scale:\(scaleW),\(scaleH)")
            return
        }
        render = pixel_w / fullScreenSize.width
        print("render:\(render) height:\(fullScreenSize.height) width:\(fullScreenSize.width) \(ref_h / fullScreenSize.height)X\(ref_w / fullScreenSize.width)")
        //let ref_w1 = ref_w / fullScreenSize.width
        //let ref_h1 = ref_h / fullScreenSize.height
        //if ((ref_h1>ref_w1) && ref_w1 >= 1) || ((ref_h1<ref_w1) && ref_h1 >= 1)
        //{
            scaleW = fullScreenSize.width / ref_w
            scaleH = fullScreenSize.height / ref_h
            print("ref process:\(scaleW),\(scaleH)")
        //}else
        //{
        //    scaleW = 1
        //    scaleH = 1
        //}
        print("scaleH:\(scaleH),scaleW:\(scaleW)")
    }
    func tuneUI(view:UIView)
    {
        for subview in view.subviews {
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
    func getLang()->String
    {
        let array = Bundle.main.preferredLocalizations
        let lang  = String(array.first!)
        return lang
    }
}
extension UIView{
    
    func showToast(text: String){
        
        self.hideToast()
        let toastLb = UILabel()
        toastLb.numberOfLines = 0
        toastLb.lineBreakMode = .byWordWrapping
        toastLb.backgroundColor = UIColor.white.withAlphaComponent(0.85)
        toastLb.textColor = UIColor.black
        toastLb.layer.cornerRadius = 10.0
        toastLb.textAlignment = .center
        toastLb.font = UIFont.systemFont(ofSize: 24)
        toastLb.text = text
        toastLb.layer.masksToBounds = true
        toastLb.tag = 9999//tag：hideToast實用來判斷要remove哪個label
        
        let maxSize = CGSize(width: self.bounds.width - 120*scaleW, height: self.bounds.height)
        var expectedSize = toastLb.sizeThatFits(maxSize)
        var lbWidth = maxSize.width
        var lbHeight = maxSize.height
        if maxSize.width >= expectedSize.width{
            lbWidth = expectedSize.width
        }
        if maxSize.height >= expectedSize.height{
            lbHeight = expectedSize.height
        }
        expectedSize = CGSize(width: lbWidth, height: lbHeight)
        print("expectedSize:\(expectedSize)")
        //toastLb.frame = CGRect(x: ((self.bounds.size.width)/2) - ((expectedSize.width + 20)/2), y: self.bounds.height/2 - expectedSize.height, width: expectedSize.width + 20, height: expectedSize.height + 20)
        toastLb.frame = CGRect(x: 60*scaleW, y: self.bounds.height/2 - expectedSize.height - 60*scaleH, width: self.bounds.size.width - 120*scaleW, height: expectedSize.height + 120*scaleH)
        print("toastLb.frame:\(toastLb.frame)")
        self.addSubview(toastLb)
        
        UIView.animate(withDuration: 1.5, delay: 1.5, animations: {
            toastLb.alpha = 0.0
        }) { (complete) in
            toastLb.removeFromSuperview()
        }
    }
    
    func hideToast(){
        for view in self.subviews{
            if view is UILabel , view.tag == 9999{
                view.removeFromSuperview()
            }
        }
    }
}
// 多國語言
extension String{
    var localized: String {
        let lang = UserDefaults.standard.string(forKey: "lang")
        let bundle = Bundle(path: Bundle.main.path(forResource: lang, ofType: "lproj")!)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}
