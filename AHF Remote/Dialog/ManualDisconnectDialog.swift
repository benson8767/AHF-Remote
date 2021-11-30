//
//  isBoundDialog.swift
//  My office mate
//
//  Created by benson chan on 2021/5/28.
//  Copyright © 2021 benson. All rights reserved.
//
import UIKit
import Malert

@objc public protocol ManualDisconnectDialogDismissDelegate  {
    func manualDisconnectAction()
    func manualDisconnectCancelAction()
}
class ManualDisconnectDialogView: UIView {
    @objc open weak var manualDisconnectDialogDismissDelegate: ManualDisconnectDialogDismissDelegate?
    public var alert:Malert?
    var timer: Timer?
    @IBOutlet weak var disconnect_from: UILabel!
    @IBOutlet weak var devName: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var disconnectBtn: UIButton!
    @IBAction func disconnectAction(_ sender: Any) {
        alert?.dismiss(animated: true, completion: {
            self.manualDisconnectDialogDismissDelegate!.manualDisconnectAction()
        })
    }
    @IBAction func cancelAction(_ sender: Any) {
        alert?.dismiss(animated: true, completion: { [self] in
            self.manualDisconnectDialogDismissDelegate!.manualDisconnectCancelAction()
        })
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        applyLayout()
    }
    
    private func applyLayout() {
        //print("applyLayout")
        disconnect_from.text = "Disconnect from".localized
        descriptionLabel.text = "Will need to manually connect\nagain.".localized
        cancelBtn.setTitle("CANCEL".localized, for: .normal)
        disconnectBtn.setTitle("DISCONNECT".localized, for: .normal)
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
    
    class func instantiateFromNib() -> ManualDisconnectDialogView {
        return Bundle.main.loadNibNamed("ManualDisconnect", owner: nil, options: nil)!.first as! ManualDisconnectDialogView
    }
}
