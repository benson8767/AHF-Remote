//
//  ConnectingDialog.swift
//  AHF Remote
//
//  Created by benson chan on 2021/11/15.
//

import Foundation
import UIKit
import Malert

@objc public protocol ConnectingDialogViewDelegate  {
    func dismissConnectingDialog()
}
class ConnectingDialogView: UIView {
    public var alert:Malert?
    var timer: Timer?
    @objc open weak var connectingDialogViewDelegate: ConnectingDialogViewDelegate?
    @IBOutlet weak var connectingIcon: UIImageView!
    @IBOutlet weak var dialogTitle: UILabel!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var desc1_1: UILabel!
    @IBOutlet weak var desc1_2: UILabel!
    @IBOutlet weak var desc1_3: UILabel!
    @IBOutlet weak var desc1_4: UILabel!
    @IBOutlet weak var desc2: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBAction func cancelAction(_ sender: Any) {
        alert?.dismiss(animated: true, completion: {
            self.connectingDialogViewDelegate!.dismissConnectingDialog()
        })
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        applyLayout()
    }
    
    private func applyLayout() {
        //print("applyLayout")
        dialogTitle.text = "Connecting".localized
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
        //TODO PUT AN IMAGE
        //imageView.image = UIImage.fromColor(color: UIColor(red:0.91, green:0.12, blue:0.39, alpha:1.0))
       /* connectingIcon.image = UIImage(named: "ic_connect")
        
        dialogTitle.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.semibold)
        dialogTitle.text = "Connecting".localized
        
        devName.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.medium)
        devName.text = "AHF_xxxx"
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        descriptionLabel.textColor = UIColor.black
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = "1. Press the light device on desk to start broadcasting signal.\n2. Move your mobile close to the light \ndevice.".localized
        cancelBtn.setTitle("CANCEL".localized, for: .normal)*/
        /*self.timer?.invalidate()
        self.timer=Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] (ktimer) in
            if rest.updateSeatInfoFlag == .ok || rest.updateSeatInfoFlag == .failure || rest.updateSeatInfoFlag == .data_already_exists
            {
                self.bindDialogViewDelegate!.bindAction(alert:alert!,status:rest.updateSeatInfoFlag.rawValue)
                self.timer?.invalidate()
            }
            if currentBindDialogFlag == .none
            {
                alert?.dismiss(animated: true, completion: {
                    //print("Binding dismiss:\(currentBindDialogFlag)")
                })
                self.timer?.invalidate()
            }else
            {
                //print("Binding timer:\(currentBindDialogFlag)")
            }
        }*/
    }
    
    class func instantiateFromNib() -> ConnectingDialogView {
        if tools.getLang() == "fr"
        {
            return Bundle.main.loadNibNamed("Connecting_fr", owner: nil, options: nil)!.first as! ConnectingDialogView
        }
        return Bundle.main.loadNibNamed("Connecting", owner: nil, options: nil)!.first as! ConnectingDialogView
    }
}
