//
//  AnalogAndDigitalGainTableViewCell.swift
//  SpectroDevice
//
//  Created by Ming-En Liu on 30/07/18.
//  Copyright © 2018 Vedas labs. All rights reserved.
//

import UIKit
import DropDown

class AnalogAndDigitalGainTableViewCell: UITableViewCell {

    @IBOutlet weak private var signalprocessType: UILabel!
    @IBOutlet weak private var dropDowButton: UIButton!
    @IBOutlet weak private var configureButton: UIButton!
    var requestCommand:String!
    let dropDown = DropDown()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
         NotificationCenter.default.addObserver(self, selector: #selector(dataRecieved(_:)), name: responseNotification.name, object: nil)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func fillData(objAD:ADObject,indexPath:IndexPath)
    {
        self.signalprocessType.text = objAD.signalProcessType
        selectionStyle = .none
     
        // The view to which the drop down will appear on
        dropDown.anchorView = dropDowButton // UIView or UIBarButtonItem
        dropDown.bottomOffset = CGPoint(x: 0, y: dropDowButton.bounds.height)
        // The list of items to display. Can be changed dynamically
        dropDown.dataSource = objAD.valueArray
        
        dropDowButton.setTitle(objAD.selectedValue, for: .normal)
        
        dropDowButton.addTarget(self, action: #selector(tapOnMenu(sender:)), for: .touchUpInside)
        
        dropDowButton.semanticContentAttribute = UIApplication.shared
            .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        

      
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.dropDowButton.setTitle(item, for: .normal)
            var adObject  = adArray[indexPath.row]
            adObject.selectedValue = item
            adArray[indexPath.row] = adObject
      }
        
        self.configureButton.tag = indexPath.row
        self.configureButton.layer.masksToBounds = true
        self.configureButton.layer.cornerRadius = 5
        self.configureButton.layer.borderColor = appThemeColor.cgColor
        self.configureButton.layer.borderWidth = 2
        
        self.configureButton.addTarget(self, action: #selector(configureButtonTapped(sender:)), for: UIControlEvents.touchUpInside)
    }
    
    @objc func tapOnMenu(sender:Any)
    {
        
        dropDown.show()
    }
    
    @objc func configureButtonTapped(sender:Any)
    {
        if let button  = sender as? UIButton
        {
            let position = button.tag
            let adObject  = adArray[position]
            var commandForMotorControl = START_TAG
            
        if adObject.signalProcessType == SignalProcssType.digitalGain.rawValue
        {
            commandForMotorControl = commandForMotorControl + DIGITAL_GAIN_TAG
        
            var commandValue = "0000"
            switch adObject.selectedValue {
            case "0X":
                commandValue = "0000"
            case "1X":
                commandValue = "0032"
            case "2X":
                commandValue = "0064"
            case "3X":
                commandValue = "0096"
            case "4X":
                commandValue = "0128"
            case "5X":
                commandValue = "0160"
            case "6X":
                commandValue = "0192"
            case "7X":
                commandValue = "0224"
            default:
                break
            }
            commandForMotorControl = commandForMotorControl+commandValue
        }
        else if adObject.signalProcessType == SignalProcssType.analogGain.rawValue
        {
            commandForMotorControl = commandForMotorControl + ANALOG_GAIN_TAG
            commandForMotorControl = commandForMotorControl+adObject.selectedValue
            
        }
        commandForMotorControl = commandForMotorControl+END_TAG
        requestCommand = commandForMotorControl
        print(commandForMotorControl)
        SocketController.sharedInstance.writeMessage(msg: requestCommand!)
        
      //  aDSignalProcessCommandProcess(commandString: commandForMotorControl, commandType: adObject.signalProcessType)
        
        }
        
    }
    
    
    @objc func dataRecieved(_ notification: NSNotification)  {
        
        if  let messageDict = notification.userInfo as? Dictionary<String, Any>
        {
            if let request =  messageDict["request"] as? String
            {
                if request == requestMessageForDeviceName
                {
                    if let response = messageDict["response"] as? Data
                    {
                        //  let socketData = SocketController.sharedInstance.readMessage()
                        processResonseData(data: response)
                        
                    }
                }
            }
        }
        
    }
    
    
    func processResonseData(data:Data)  {
        let rootView = UIApplication.shared.keyWindow
        if let response = String(bytes: data, encoding: .utf8) {
            print(response)
            if response.contains("OK")
            {
                hideProgressActivityWithSuccess()
                DispatchQueue.main.async {
                 rootView?.makeToast("\(self.requestCommand!) command Success")
                }
                
            }
        }
    }
    
    func  aDSignalProcessCommandProcess(commandString:String,commandType:String)  {
        
        let rootView = UIApplication.shared.keyWindow
        // Communicating with WIfi Device
       // showProgressActivity(view: rootView!)
        DispatchQueue.global(qos: .background).async {
            WifiController.sharedInstance.sendData(dataInString:commandString , completion: { data in
                
                if data.count > 0
                {
                    
                    if let response = String(bytes: data, encoding: .utf8) {
                        print(commandString)
                        print(response)
                        if response.contains("OK")
                        {
                            hideProgressActivityWithSuccess()
                            DispatchQueue.main.async {
                                rootView?.makeToast("\(commandType) command Success")
                            }
                            
                        }
                    }
                }
            }, failure: {error  in
                print(error ?? "")
             //   hideProgressActivityWithFailure()
//                DispatchQueue.main.async {
//                    rootView?.makeToast("\(commandType) command Failure")
//                }
            })
            
        }
    }
        

}
extension AnalogAndDigitalGainTableViewCell:UITextFieldDelegate
{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
}
