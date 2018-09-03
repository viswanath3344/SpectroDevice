//
//  LEDControlTableViewCell.swift
//  SpectroDevice
//
//  Created by Ming-En Liu on 23/07/18.
//  Copyright © 2018 Vedas labs. All rights reserved.
//

import UIKit
import SwiftSocket
import  Toast_Swift


protocol LEDTableviewCellDelegate: class { // the name of the protocol you can put any
    func updateTableView()
}


class LEDControlTableViewCell: UITableViewCell {
    
    weak var delegate: LEDTableviewCellDelegate?
    
    
    @IBOutlet weak private var ledControlType: UILabel!
    @IBOutlet weak private var ledControlSwitch: UISwitch!
    @IBOutlet weak private var configureButton: UIButton!
    @IBOutlet weak private var ledControlIntensitySlider: UISlider!
    @IBOutlet weak private var ledControlIntensitySliderMinValue: UILabel!
    @IBOutlet weak private var ledControlIntensitySliderMaxValue: UILabel!
    @IBOutlet weak private var ledIntensityTextFiled: UITextField!
    @IBOutlet weak private var ledIntensityView: UIView!
    @IBOutlet weak var ledControlSubType: UILabel!
    var requestCommand:String!
    var requestPosition:Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
          NotificationCenter.default.addObserver(self, selector: #selector(dataRecieved(_:)), name: responseNotification.name, object: nil)
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    public func fillData(ledControlObj:LEDContol,indexPath:IndexPath)
    {
        self.ledControlType.text = ledControlObj.ledControlTitle
        self.ledControlSubType.text = ledControlObj.ledControlSubTitle
        self.ledControlSwitch.isOn = ledControlObj.isON
        self.ledControlIntensitySlider.minimumValue = Float(ledControlObj.ledControlMinValue)!
        self.ledControlIntensitySlider.maximumValue = Float(ledControlObj.ledControlMaxValue)!
        self.ledControlIntensitySlider.value = Float(ledControlObj.value)!
        self.ledIntensityTextFiled.text = ledControlObj.value
        /*   if !ledControlObj.isEnabled {
         ledIntensityView.isHidden = true
         }
         */
        ledIntensityView.isHidden = false
        
        selectionStyle = .none
        self.ledControlSwitch.tag = indexPath.row
        self.ledControlSwitch.addTarget(self, action: #selector(switchValueChanged(sender:)), for: UIControlEvents.valueChanged)
        self.ledControlIntensitySlider.addTarget(self, action: #selector(sliderValueChanged(sender:)), for: UIControlEvents.valueChanged)
    }
    
    
    @objc func switchValueChanged(sender:Any)
    {
        if let switchToggle  = sender as? UISwitch
        {
            let position = switchToggle.tag
        
            ledControlCommndsProcess1(switchToggle, position)
        
        }
        
    }
    
    
    fileprivate func ledControlCommndsProcess1(_ switchToggle: UISwitch, _ position: Int)
    {
        var ledCommandString:String!
        
        
        if self.ledControlType.text == LEDControlType.whiteLED.rawValue
        {
            ledCommandString = LED_TURN_OFF
            
            if switchToggle.isOn
            {
                ledCommandString = LED_TURN_ON
            }
            
        }
        else if self.ledControlType.text == LEDControlType.uv.rawValue
        {
            ledCommandString = UV_TURN_OFF
            
            if switchToggle.isOn
            {
                ledCommandString = UV_TURN_ON
            }
            
            
        }
        else if self.ledControlType.text == LEDControlType.reflectionLED.rawValue
        {
             ledCommandString = REFLECTION_TURN_OFF
            
            if switchToggle.isOn
            {
                ledCommandString = REFLECTION_TURN_ON
            }
            
           
            
        }
        
        requestCommand = ledCommandString
        requestPosition = position
        print(requestCommand)
        SocketController.sharedInstance.writeMessage(msg: requestCommand!)
        
         // ledControlCommandProcess2(position, ledCommandString, switchToggle)
        
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
                    var ledObject  = ledControlArray[requestPosition]
                    //   hideProgressActivityWithSuccess()
                    DispatchQueue.main.async {
                            rootView?.makeToast("\(self.requestCommand!) command Success")
                            self.requestCommand = ""
                            ledObject.isON = self.ledControlSwitch.isOn
                            ledControlArray[self.requestPosition] = ledObject
                            self.delegate?.updateTableView()  // Need to check error when change
                        }
                    }
                    
                }
            }
        
    }
    

   
    
    fileprivate func ledControlCommandProcess2(_ position: Int, _ ledCommandString: String, _ switchToggle: UISwitch) {
       
        var ledObject  = ledControlArray[position]
        
        // Communicating with WIfi Device
        DispatchQueue.global(qos: .background).async {
        WifiController.sharedInstance.sendData(dataInString:ledCommandString , completion: { data in
            
            if data.count > 0
            {
                
                if let response = String(bytes: data, encoding: .utf8) {
                    print(ledCommandString)
                    print(response)
                    if response.contains("OK")
                    {
                        
                        DispatchQueue.main.async {
                        ledObject.isON = switchToggle.isOn
                        ledControlArray[position] = ledObject
                        self.makeToastForResponse(ledCommandString: ledCommandString, status: "success")
                        self.delegate?.updateTableView()  // Need to check error when change
                        }
                        
                    }
                }
            }
        }, failure: {error  in
            print(error ?? "")
              DispatchQueue.main.async {
//                ledObject.isON = !switchToggle.isOn
//                ledControlArray[position] = ledObject
//                self.delegate?.updateTableView()
          //  self.makeToastForResponse(ledCommandString: ledCommandString, status: "failure")
         //   self.delegate?.updateTableView()
            }
        })
    }
    }
    
    fileprivate func makeToastForResponse(ledCommandString:String,status:String) {
        // self.ledIntensityView.isHidden = !switchToggle.isOn
        //  self.delegate?.updateTableView()
        
        
        
        let rootView = UIApplication.shared.keyWindow
        
        if ledCommandString == LED_TURN_ON
        {
            rootView?.makeToast("White LED ON \(status) ", duration: 2.0, position: .bottom, style: ToastStyle())
            
        }
        else if ledCommandString == LED_TURN_OFF
        {
            rootView?.makeToast("White LED OFF \(status) ", duration: 2.0, position: .bottom, style: ToastStyle())
            
        }
        else if ledCommandString == UV_TURN_ON
        {
            rootView?.makeToast("UV LED ON \(status) ", duration: 2.0, position: .bottom, style: ToastStyle())
            
        }
        else if ledCommandString == UV_TURN_OFF
        {
            rootView?.makeToast("UV LED OFF \(status) ", duration: 2.0, position: .bottom, style: ToastStyle())
            
        }
        else if ledCommandString == REFLECTION_TURN_ON
        {
            rootView?.makeToast("Reflection turn ON \(status) ", duration: 2.0, position: .bottom, style: ToastStyle())
            
        }
        else if ledCommandString == REFLECTION_TURN_OFF
        {
            rootView?.makeToast("Reflection turn OFF \(status) ", duration: 2.0, position: .bottom, style: ToastStyle())
            
        }
    }
    
    
   
    
    @objc func sliderValueChanged(sender:Any)
    {
        if let slider  = sender as? UISlider
        {
            let position = slider.tag
            var ledObject  = ledControlArray[position]
            ledObject.value = "\(Int(slider.value))"
            self.ledIntensityTextFiled.text = "\(Int(ledControlIntensitySlider.value))"
            ledControlArray[position] = ledObject
        }
        
        
    }
    
    
    
    
}


extension LEDControlTableViewCell:UITextFieldDelegate
{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
}
