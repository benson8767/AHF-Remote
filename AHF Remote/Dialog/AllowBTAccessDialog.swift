//
//  isBoundDialog.swift
//  My office mate
//
//  Created by benson chan on 2021/5/28.
//  Copyright © 2021 benson. All rights reserved.
//
import UIKit
import Malert

@objc public protocol AllowBtAccessDialogDismissDelegate  {
    func closeAction()
    func settingsAction()
}
class AllowBtAccessDialogView: UIView {
    @objc open weak var allowBtAccessDialogDismissDelegate: AllowBtAccessDialogDismissDelegate?
    public var alert:Malert?
    @IBOutlet weak var dialogTitle: UILabel!
    @IBOutlet weak var dialogDescription: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var settingBtn: UIButton!
    public var MAC_address:String = ""
    var timer: Timer?

    @IBAction func closeAction(_ sender: Any) {
        alert?.dismiss(animated: true, completion: {
            self.allowBtAccessDialogDismissDelegate!.closeAction()
        })
    }

    @IBAction func settingsAction(_ sender: Any) {
        alert?.dismiss(animated: true, completion: { [self] in
            self.allowBtAccessDialogDismissDelegate!.settingsAction()
        })
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        applyLayout()
    }
    
    private func applyLayout() {
        print("applyLayout dialogTitle")
        dialogTitle.text = "\"AHF Remote\"\nWould Need You to Allow Bluetooth Access".localized;
        //dialogTitle.text = "Autoriser la connexion Bluetooth avec \"AHFaaaaa\u{00a0}Remotebbbb\"";
        dialogDescription.text = "To control the bed.".localized;
        closeBtn.setTitle("CLOSE".localized, for: .normal)
        settingBtn.setTitle("SETTINGS".localized, for: .normal)
        //dialogDescription.numberOfLines=0
        //dialogDescription.lineBreakMode = NSLineBreakMode.byWordWrapping
       /* self.timer?.invalidate()
        self.timer=Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] (ktimer) in
            if rest.updateSeatInfoFlag == .ok || rest.updateSeatInfoFlag == .failure || rest.updateSeatInfoFlag == .data_already_exists
            {
                self.isUnbindDialogDismissDelegate!.unbindUpdateSeatAction(alert:alert!,status:rest.updateSeatInfoFlag.rawValue)
                self.timer?.invalidate()
            }
            if currentBindDialogFlag == .none
            {
                alert?.dismiss(animated: true, completion: {
                    //print("isBound dismiss:\(currentBindDialogFlag)")
                })
                self.timer?.invalidate()
            }else
            {
                //print("isBound timer:\(currentBindDialogFlag)")
            }
        }*/
        //descriptionLabel.text = "MAC address: \(String(describing: infoDesk!.mac_addr))"
    }
    
    class func instantiateFromNib() -> AllowBtAccessDialogView {
        return Bundle.main.loadNibNamed("AllowBTAccess", owner: nil, options: nil)!.first as! AllowBtAccessDialogView
    }
}
