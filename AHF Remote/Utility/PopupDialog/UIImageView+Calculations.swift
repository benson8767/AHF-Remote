//
//  UIImageView+Calculations.swift
//
//  Copyright (c) 2016 Orderella Ltd. (http://orderella.co.uk)
//  Author - Martin Wildfeuer (http://www.mwfire.de)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import UIKit

extension UIImage {
    //生成圆形图片
    func toCircle() -> UIImage {
        //取最短边长
        let shotest = min(self.size.width, self.size.height)
        //输出尺寸
        let outputRect = CGRect(x: 0, y: 0, width: shotest, height: shotest)
        //开始图片处理上下文（由于输出的图不会进行缩放，所以缩放因子等于屏幕的scale即可）
        UIGraphicsBeginImageContextWithOptions(outputRect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        //添加圆形裁剪区域
        context.addEllipse(in: outputRect)
        context.clip()
        //绘制图片
        self.draw(in: CGRect(x: (shotest-self.size.width)/2,
                              y: (shotest-self.size.height)/2,
                              width: self.size.width,
                              height: self.size.height))
        //获得处理后的图片
        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return maskedImage
    }
}
internal extension UIImageView {

    /*!
     Calculates the height of the the UIImageView has to
     have so the image is displayed correctly
     - returns: Height to set on the imageView
     */
    func pv_heightForImageView() -> CGFloat {
        guard let image = image, image.size.height > 0 else {
            return 0.0
        }
        let width = bounds.size.width
        let ratio = image.size.height / image.size.width//CGFloat(0.1911)//image.size.height / image.size.width
        
        /*let widths = image.size.width / 2
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: widths, height: widths))
        let x = -(image.size.width - width) / 2
        let y = -(image.size.height - width) / 2
        image = renderer.image { (context) in image.draw(at: CGPoint(x: x, y: y))}
        
        self.contentMode = .scaleAspectFill
        self.layer.masksToBounds = true
        self.layer.cornerRadius = width / 2*/
        
        //standardView.imageView.frame.size.width = CGFloat(64)
        //standardView.imageView.frame.size.height = CGFloat(64)
        //print("standardView.imageView.frame:\(standardView.imageView.frame)")
        //print("width:\(width) ratio:\(ratio)")
        
        return width * ratio
    }
}
