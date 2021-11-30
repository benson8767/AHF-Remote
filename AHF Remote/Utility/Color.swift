//
//  Color.swift
//  Motti
//
//  Created by benson chan on 2021/1/7.
//  Copyright © 2021 Benson. All rights reserved.
//

import UIKit
import Foundation
extension UIColor {
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
//example #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
enum Color {
    static let white:UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)               //FFFFFFFF
    static let black:UIColor = #colorLiteral(red: 0.1254901961, green: 0.1254901961, blue: 0.1254901961, alpha: 1)               //202020FF
    static let btn_black:UIColor = #colorLiteral(red: 0.3019607843, green: 0.3019607843, blue: 0.3019607843, alpha: 1)           //4d4d4dFF
    static let btn_select_gray:UIColor = #colorLiteral(red: 0, green: 0.7764705882, blue: 0.7098039216, alpha: 1)           //00c6b5FF
    static let background:UIColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1)          //E6E6E6FF
    static let enableBk:UIColor = #colorLiteral(red: 0.7215686275, green: 0.7411764706, blue: 0.7254901961, alpha: 1)           //B8BDB9FF
    static let disableBk:UIColor = #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9137254902, alpha: 1)          //E9E9E9FF
    static let btn_blue:UIColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)          //007AFFFFF
    static let unlock_bk:UIColor = #colorLiteral(red: 0.8588235294, green: 0.8588235294, blue: 0.8588235294, alpha: 1)          //DBDBDBFF
    static let dialog_button_text:UIColor = #colorLiteral(red: 0.1411764706, green: 0.5960784314, blue: 0.1607843137, alpha: 1)   //249829FF
    static let picker_text:UIColor = #colorLiteral(red: 0.2431372549, green: 0.2509803922, blue: 0.2549019608, alpha: 1)          //3E4041FF
    static let picker_backgriund:UIColor = #colorLiteral(red: 0.1411764706, green: 0.5960784314, blue: 0.1607843137, alpha: 1)   //249829FF
}
