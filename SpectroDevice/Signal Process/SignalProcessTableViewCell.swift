//
//  SignalProcessTableViewCell.swift
//  SpectroDevice
//
//  Created by Ming-En Liu on 20/07/18.
//  Copyright © 2018 Vedas labs. All rights reserved.
//

import UIKit


class SignalProcessTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.expousureValueTextFiled.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(dataRecieved(_:)), name: responseNotification.name, object: nil)
        // Initialization code
    }
    
    
    
    @IBOutlet weak private var signalprocessType: UILabel!
    @IBOutlet weak private var signalProcessAutoSwitch: UISwitch!
    @IBOutlet weak private var signalProcessSlider: UISlider!
    @IBOutlet weak private var signalProcessSliderMinValue: UILabel!
    @IBOutlet weak private var signalProcessSilderMaxValue: UILabel!
    @IBOutlet weak private var expousureValueTextFiled: UITextField!
    @IBOutlet weak private var configureButton: UIButton!
    @IBOutlet weak var signalProcessSubType: UILabel!
    var requestCommand:String!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    
        // Configure the view for the selected state
    }
    
    public func fillData(signalProcessObj:SignalProcess,indexPath:IndexPath)
    {
       self.signalprocessType.text = signalProcessObj.signalProcessType
       self.signalProcessSubType.text = signalProcessObj.signalProcessSubType
       self.signalProcessAutoSwitch.isOn = signalProcessObj.isAutoEnabled
       self.signalProcessSlider.minimumValue = Float(signalProcessObj.sliderMinValue)!
       self.signalProcessSlider.maximumValue = Float(signalProcessObj.sliderMaxValue)!
       self.signalProcessSlider.value = Float(signalProcessObj.value)!
       self.expousureValueTextFiled.text = signalProcessObj.value
       self.expousureValueTextFiled.tag = indexPath.row
       self.signalProcessSliderMinValue.text = signalProcessObj.sliderMinValue
       self.signalProcessSilderMaxValue.text = signalProcessObj.sliderMaxValue
        
        selectionStyle = .none
        signalProcessAutoSwitch.tag = indexPath.row
        signalProcessAutoSwitch.addTarget(self, action: #selector(switchValueChanged(sender:)), for: UIControlEvents.valueChanged)
        signalProcessSlider.tag = indexPath.row
        signalProcessSlider.addTarget(self, action: #selector(sliderValueChanged(sender:)), for: UIControlEvents.valueChanged)
       
        configureButton.tag = indexPath.row
        self.configureButton.layer.masksToBounds = true
        self.configureButton.layer.cornerRadius = 5
        self.configureButton.layer.borderColor = appThemeColor.cgColor
        self.configureButton.layer.borderWidth = 2
        configureButton.addTarget(self, action: #selector(configureButtonTapped(sender:)), for: .touchUpInside)
        self.expousureValueTextFiled.addDoneButtonOnKeyboard()
    }
    
    
    @objc func configureButtonTapped(sender:Any)
    {
        if let button  = sender as? UIButton
        {
            let position = button.tag
            let signalProcessObject  = signalProcessArray[position]
            
            if Int(signalProcessObject.value)! > 0
            {
                var commandForMotorControl = START_TAG
                
                if signalProcessObject.signalProcessType == SignalProcssType.exposure.rawValue
                {
                    commandForMotorControl = commandForMotorControl + EXPOUSURE_TAG
                    commandForMotorControl = commandForMotorControl+signalProcessObject.value
                }
                else if signalProcessObject.signalProcessType == SignalProcssType.noOfAvg.rawValue
                {
                    commandForMotorControl = commandForMotorControl + AVG_FRAME_TAG
                    let hexaString = String(format:"%2X", Int(signalProcessObject.value)!)
                    commandForMotorControl = commandForMotorControl+hexaString
                    
                }
                
               
                commandForMotorControl = commandForMotorControl+END_TAG
                requestCommand = commandForMotorControl
                print(commandForMotorControl)
                SocketController.sharedInstance.writeMessage(msg: requestCommand!)
               // signalProcessCommandProcess(commandString: commandForMotorControl, commandType: signalProcessObject.signalProcessType)
                
                
            }
            else
            {
                let rootView = UIApplication.shared.keyWindow
                rootView?.makeToast("Step Count value not valid")
            }
            
        }
    }
    
    @objc func dataRecieved(_ notification: NSNotification)  {
        
        if  let messageDict = notification.userInfo as? Dictionary<String, Any>
        {
            if let request =  messageDict["request"] as? String
            {
                if request == requestCommand
                {
                    if let response = messageDict["response"] as? Data
                    {
                        //  let socketData = SocketController.sharedInstance.readMessage()
                
                        processResponseData(data: response)
                       
                    }
                }
            }
        }
        
    }
    
    func processResponseData(data:Data)  {
        let rootView = UIApplication.shared.keyWindow
        if data.count > 0
        {
            
            if let response = String(bytes: data, encoding: .utf8) {
                print(response)
                if response.contains("OK")
                {
                 //   hideProgressActivityWithSuccess()
                    DispatchQueue.main.async {
                        rootView?.makeToast("\(self.requestCommand!) command Success")
                        self.requestCommand = ""
                    }
                    
                }
    }
        
        }
    }
    
    func  signalProcessCommandProcess(commandString:String,commandType:String)  {
        
        let rootView = UIApplication.shared.keyWindow
        
       // showProgressActivity(view: rootView!)
        
        // Communicating with WIfi Device
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
          //  hideProgressActivityWithFailure()
             DispatchQueue.main.async {
              rootView?.makeToast("\(commandType) command Failure")
            }
        })
        
    }
    }
    
    
    
    @objc func switchValueChanged(sender:Any)
    {
        if let switchToggle  = sender as? UISwitch
        {
            let position = switchToggle.tag
            var signalProcessObject  = signalProcessArray[position]
            signalProcessObject.isAutoEnabled = switchToggle.isOn
            signalProcessArray[position] = signalProcessObject
        }
       
    }
    
    @objc func sliderValueChanged(sender:Any)
    {
        if let slider  = sender as? UISlider
        {
            let position = slider.tag
            var signalProcessObject  = signalProcessArray[position]
            signalProcessObject.value = "\(Int(slider.value))"
            self.expousureValueTextFiled.text = "\(Int(slider.value))"
            signalProcessArray[position] = signalProcessObject
        }
        
    }

}

extension SignalProcessTableViewCell:UITextFieldDelegate
{
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let position = textField.tag
        if textField == expousureValueTextFiled
        {
            var signalProcessObject  = signalProcessArray[position]
            if (Int(textField.text!)! >= Int(signalProcessObject.sliderMinValue)!) && (Int(textField.text!)! <= Int(signalProcessObject.sliderMaxValue)!)
            {
                self.signalProcessSlider.value = Float(textField.text!)!
                signalProcessObject.value = textField.text!
            }
            else
            {
            UIApplication.shared.keyWindow?.makeToast("\(signalProcessObject.signalProcessType) range: \(signalProcessObject.sliderMinValue) ~ \(signalProcessObject.sliderMaxValue)")
                textField.text = signalProcessObject.value
            }
             signalProcessArray[position] = signalProcessObject
        }
        
    }
}
