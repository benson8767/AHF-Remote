//
//  isBoundDialog.swift
//  My office mate
//
//  Created by benson chan on 2021/5/28.
//  Copyright © 2021 benson. All rights reserved.
//
import UIKit
import Malert

@objc public protocol DisconnectDialogDismissDelegate  {
    func tryLaterAction()
    func reConnectAction()
}
class DisconnectDialogView: UIView {
    @objc open weak var disconnectDialogDismissDelegate: DisconnectDialogDismissDelegate?
    public var alert:Malert?
    @IBOutlet weak var bluetooth_connection_lost: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tryLaterBtn: UIButton!
    @IBOutlet weak var reConnectBtn: UIButton!
    public var MAC_address:String = ""
    var timer: Timer?
    
    @IBAction func tryLaterAction(_ sender: Any) {
        alert?.dismiss(animated: true, completion: {
            self.disconnectDialogDismissDelegate!.tryLaterAction()
        })
    }
    
    @IBAction func reConnectAction(_ sender: Any) {
        alert?.dismiss(animated: true, completion: { [self] in
            self.disconnectDialogDismissDelegate!.reConnectAction()
        })
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        applyLayout()
    }
    
    private func applyLayout() {
        //print("applyLayout")
        bluetooth_connection_lost.text = "Bluetooth Connection\nLost".localized
        descriptionLabel.text = "Please make sure the Bluetooth\ndevice by the bed is turned on and\nin range.".localized
        descriptionLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        descriptionLabel.numberOfLines = 0
        tryLaterBtn.setTitle("TRY LATER".localized, for: .normal)
        reConnectBtn.setTitle("RE-CONNECT".localized, for: .normal)
        //TODO PUT AN IMAGE
        //imageView.image = UIImage.fromColor(color: UIColor(red:0.91, green:0.12, blue:0.39, alpha:1.0))
        /*bindingIcon.image = UIImage(named: "ic_success")
        
        bindingTitle.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.semibold)
        bindingTitle.text = "Light Device is Bound.".localized
        unbindBtn.setTitle("UNBIND".localized, for: .normal)
        okBtn.setTitle("OK".localized, for: .normal)
        seatName.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.light)
        //seatName.text = "Seat 1"
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.regular)
        descriptionLabel.textColor = UIColor.black
        descriptionLabel.numberOfLines = 0
        
        self.timer?.invalidate()
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
    
    class func instantiateFromNib() -> DisconnectDialogView {
        return Bundle.main.loadNibNamed("Disconnect", owner: nil, options: nil)!.first as! DisconnectDialogView
    }
}
