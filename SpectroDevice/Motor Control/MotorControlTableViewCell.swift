//
//  MotorControlTableViewCell.swift
//  SpectroDevice
//
//  Created by Ming-En Liu on 24/07/18.
//  Copyright © 2018 Vedas labs. All rights reserved.
//

import UIKit
import DropDown


class MotorControlTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var motorControlTitle: UILabel!
    @IBOutlet weak private var dropDowButton: UIButton!
    @IBOutlet weak private var stepsCountLabel: UILabel!
    @IBOutlet weak private var stepsValueTextField: UITextField!
    
    @IBOutlet weak private var stepsCountSlider: UISlider!
    @IBOutlet weak private var stepsCountMinValue: UILabel!
    @IBOutlet weak private var stepsCountMaxValue: UILabel!
    
    @IBOutlet weak private var waitTimeLabel: UILabel!
    @IBOutlet weak private var waitTimeTextField: UITextField!
    @IBOutlet weak private var waitTimeMinValue: UILabel!
    @IBOutlet weak private var waitTimeMaxValue: UILabel!
    @IBOutlet weak private var waitTimeSlider: UISlider!
    @IBOutlet weak private var configureButton:UIButton!
    let dropDown = DropDown()
     var requestCommand:String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
         NotificationCenter.default.addObserver(self, selector: #selector(dataRecieved(_:)), name: responseNotification.name, object: nil)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    public func fillData(motorControlObj:MotorControl,indexPath:IndexPath)
    {
        self.motorControlTitle.text = motorControlObj.motorControlTitle
        self.selectionStyle = .none
        
      
        
        // The view to which the drop down will appear on
        dropDown.anchorView = dropDowButton // UIView or UIBarButtonItem
        dropDown.bottomOffset = CGPoint(x: 0, y: dropDowButton.bounds.height)
        // The list of items to display. Can be changed dynamically
        dropDown.dataSource = ["CLOCKWISE","COUNTER-CLOCKWISE"]
    
        if motorControlObj.isClockWise
        {
           dropDowButton.setTitle("CLOCKWISE", for: .normal)
        }
        else
        {
           dropDowButton.setTitle("COUNTER-CLOCKWISE", for: .normal)
        }
        
        

        dropDowButton.addTarget(self, action: #selector(tapOnClockWiseSelection(sender:)), for: .touchUpInside)
        
        dropDowButton.semanticContentAttribute = UIApplication.shared
            .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft

//        dropDowButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
//        dropDowButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
//        dropDowButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
//        dropDowButton.contentHorizontalAlignment = .left
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
             self.dropDowButton.setTitle(item, for: .normal)
            var motorControlObject  = motorControlArray[indexPath.row]
            switch index {
            case ClockDirection.clockWise.rawValue:
                motorControlObject.isClockWise = true
            case ClockDirection.counterClockwise.rawValue:
                motorControlObject.isClockWise = false
            default:
                break
            }
            motorControlArray[indexPath.row] = motorControlObject
        }
        
        // Will set a custom width instead of the anchor view width
    
        
        self.stepsCountLabel.text = motorControlObj.stepCountName
        
        self.stepsValueTextField.delegate = self
        self.stepsValueTextField.tag = indexPath.row
        self.stepsValueTextField.text = motorControlObj.stepCountValue
        self.stepsCountSlider.minimumValue = Float(motorControlObj.stepCountSliderMinValue)!
        self.stepsCountSlider.maximumValue = Float(motorControlObj.stepCountSliderMaxValue)!
        self.stepsCountSlider.value = Float(motorControlObj.stepCountValue)!
        
        self.stepsCountSlider.tag = indexPath.row
        self.stepsCountSlider.addTarget(self, action: #selector(stepSliderValueChanged(sender:)), for: UIControlEvents.valueChanged)
        
        self.waitTimeLabel.text = motorControlObj.waitTimeName
        self.waitTimeTextField.tag = indexPath.row
        self.waitTimeTextField.delegate = self
        self.waitTimeTextField.text = motorControlObj.waitTimeValue
        
        self.waitTimeSlider.minimumValue = Float(motorControlObj.waitTimeSliderMinValue)!
        self.waitTimeSlider.maximumValue = Float(motorControlObj.waitTimeSliderMaxValue)!
        self.waitTimeSlider.value = Float(motorControlObj.waitTimeValue)!
        
        self.waitTimeSlider.tag = indexPath.row
        self.waitTimeSlider.addTarget(self, action: #selector(waitTimeSliderValueChanged(sender:)), for: UIControlEvents.valueChanged)
        self.waitTimeSlider.addTarget(self, action: #selector(waitTimeSliderValueChanged(sender:)), for: UIControlEvents.valueChanged)
        
        self.configureButton.tag = indexPath.row
        self.configureButton.layer.masksToBounds = true
        self.configureButton.layer.cornerRadius = 5
        self.configureButton.layer.borderColor = appThemeColor.cgColor
        self.configureButton.layer.borderWidth = 2
        self.configureButton.addTarget(self, action: #selector(configureButtonTapped(sender:)), for: UIControlEvents.touchUpInside)
        
        
        self.stepsValueTextField.addDoneButtonOnKeyboard()
        self.waitTimeTextField.addDoneButtonOnKeyboard()
        self.backgroundColor = UIColor.lightText
    }
    
      @objc func tapOnClockWiseSelection(sender:Any)
      {
       
        dropDown.show()
    }
    
    
    
    @objc func segementSelected(sender:Any)
    {
        if let segmentedControl  = sender as? UISegmentedControl
        {
            let position = segmentedControl.tag
            var motorControlObject  = motorControlArray[position]
            
            switch segmentedControl.selectedSegmentIndex {
            case ClockDirection.clockWise.rawValue:
                motorControlObject.isClockWise = true
            case ClockDirection.counterClockwise.rawValue:
                motorControlObject.isClockWise = false
            default:
                break
            }
            
            motorControlArray[position] = motorControlObject
        }
        
    }
    
    
    @objc func configureButtonTapped(sender:Any)
    {
        if let button  = sender as? UIButton
        {
            let position = button.tag
            let motorControlObject  = motorControlArray[position]
            
            if Int(motorControlObject.stepCountValue)! > 0
            {
                var commandForMotorControl = START_TAG
                
                if motorControlObject.isClockWise
                {
                    commandForMotorControl = commandForMotorControl + MOVE_STRIP_CLOCKWISE_TAG
                }
                else
                {
                    commandForMotorControl = commandForMotorControl + MOVE_STRIP_COUNTER_CLOCKWISE_TAG
                }
                
                commandForMotorControl = commandForMotorControl+motorControlObject.stepCountValue
                
                commandForMotorControl = commandForMotorControl+END_TAG
                
                print(commandForMotorControl)
                requestCommand = commandForMotorControl
                print(commandForMotorControl)
                SocketController.sharedInstance.writeMessage(msg: requestCommand!)
                
                //motorControlCommandProcess(commandString: commandForMotorControl)
                
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
    
    func  motorControlCommandProcess(commandString:String)  {
        
        let rootView = UIApplication.shared.keyWindow
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
                            DispatchQueue.main.async {
                                rootView?.makeToast("Motor Control command Success")
                            }
                            
                        }
                    }
                }
            }, failure: {error  in
                print(error ?? "")
//                DispatchQueue.main.async {
//                    rootView?.makeToast("Motor Control command Failure")
//                }
            })
            
        }
    }
    
    @objc func stepSliderValueChanged(sender:Any)
    {
        if let slider  = sender as? UISlider
        {
            let position = slider.tag
            var motorControlObject  = motorControlArray[position]
            motorControlObject.stepCountValue = "\(Int(slider.value))"
            self.stepsValueTextField.text = "\(Int(slider.value))"
            motorControlArray[position] = motorControlObject
        }
        
    }
    
    @objc func waitTimeSliderValueChanged(sender:Any)
    {
        if let slider  = sender as? UISlider
        {
            let position = slider.tag
            
            var motorControlObject  = motorControlArray[position]
            motorControlObject.waitTimeValue = "\(Int(slider.value))"
            self.waitTimeTextField.text = "\(Int(slider.value))"
            motorControlArray[position] = motorControlObject
        }
        
        
    }
    
}

extension MotorControlTableViewCell:UITextFieldDelegate
{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
      
        let position = textField.tag
        if textField == stepsValueTextField
        {
            var motorControlObject  = motorControlArray[position]
            if (Int(textField.text!)! >= Int(motorControlObject.stepCountSliderMinValue)!) && (Int(textField.text!)! <= Int(motorControlObject.stepCountSliderMaxValue)!)
            {
                self.stepsCountSlider.value = Float(textField.text!)!
                motorControlObject.stepCountValue = textField.text!
            }
            else
            {
                UIApplication.shared.keyWindow?.makeToast("Step Count range: \(motorControlObject.stepCountSliderMinValue) ~ \(motorControlObject.stepCountSliderMaxValue)")
                textField.text = motorControlObject.stepCountValue
            }
            motorControlArray[position] = motorControlObject
            
        }
        else if textField == waitTimeTextField
        {
            var motorControlObject  = motorControlArray[position]
            if (Int(textField.text!)! >= Int(motorControlObject.waitTimeSliderMinValue)!) && (Int(textField.text!)! <= Int(motorControlObject.waitTimeSliderMaxValue)!)
            {
                self.waitTimeSlider.value = Float(textField.text!)!
                motorControlObject.waitTimeValue = textField.text!
            }
            else
            {
                UIApplication.shared.keyWindow?.makeToast("Timer Count range: \(motorControlObject.waitTimeSliderMinValue) ~ \(motorControlObject.waitTimeSliderMaxValue)")
                textField.text = motorControlObject.waitTimeValue
            }
            motorControlArray[position] = motorControlObject
        }
       
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    
}




