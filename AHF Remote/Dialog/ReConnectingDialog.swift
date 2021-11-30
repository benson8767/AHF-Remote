//
//  ConnectingDialog.swift
//  AHF Remote
//
//  Created by benson chan on 2021/11/15.
//

import Foundation
import UIKit
import Malert

@objc public protocol ReConnectingDialogViewDelegate  {
    func dismissReConnectingDialog()
}
class ReConnectingDialogView: UIView {
    public var alert:Malert?
    var timer: Timer?
    @objc open weak var reConnectingDialogViewDelegate: ReConnectingDialogViewDelegate?
    @IBOutlet weak var connectingIcon: UIImageView!
    @IBOutlet weak var dialogTitle: UILabel!
    @IBOutlet weak var devName: UILabel!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var desc1_1: UILabel!
    @IBOutlet weak var desc1_2: UILabel!
    @IBOutlet weak var desc1_3: UILabel!
    @IBOutlet weak var desc1_4: UILabel!
    @IBOutlet weak var desc2: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBAction func cancelAction(_ sender: Any) {
        alert?.dismiss(animated: true, completion: {
            self.reConnectingDialogViewDelegate!.dismissReConnectingDialog()
        })
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        applyLayout()
    }
    
    private func applyLayout() {
        print("ReConnectingDialogView applyLayout")
        //TODO PUT AN IMAGE
        devName.textColor = Color.dialog_button_text
        cancelBtn.tintColor = Color.dialog_button_text
        dialogTitle.text = "Re-Connecting to".localized
        if tools.getLang() == "fr"
        {
         desc1_1.text = "Press buttons 1 and 3 on handset for".localized
         desc1_2.text = "3s".localized
         desc1_3.text = "to broadcast".localized
         desc1_4.isHidden = true
        }else
        {
        desc1_1.text = "Press buttons 1 and 3 on handset for".localized
        desc1_2.text = "3s".localized
            desc1_3.text = "to broadcast".localized
            desc1_4.text = "signal.".localized
            desc1_4.isHidden = false
        }
        desc2.text = "Move your mobile close to TRF2 (a Bluetooth device by the bed).".localized
        cancelBtn.setTitle("CANCEL".localized, for: .normal)
    }
    
    class func instantiateFromNib() -> ReConnectingDialogView {
        if tools.getLang() == "fr"
        {
            return Bundle.main.loadNibNamed("ReConnecting_fr", owner: nil, options: nil)!.first as! ReConnectingDialogView
        }
        return Bundle.main.loadNibNamed("ReConnecting", owner: nil, options: nil)!.first as! ReConnectingDialogView
    }
}
