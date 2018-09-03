//
//  SignalProcessViewController.swift
//  SpectroDevice
//
//  Created by Ming-En Liu on 20/07/18.
//  Copyright © 2018 Vedas labs. All rights reserved.
//

import UIKit
import Toast_Swift
import MBProgressHUD

struct SignalProcess {
    var signalProcessType:String
    var isAutoEnabled:Bool
    var value:String
    var sliderMinValue:String
    var sliderMaxValue:String
    var signalProcessSubType:String
    
}

struct ADObject {
      var signalProcessType:String
      var selectedValue :String
      var valueArray:[String]
}

var signalProcessArray = [SignalProcess]()
var adArray = [ADObject]()
var requestMessageForDeviceName:String!
class SignalProcessViewController: UIViewController {
    
    
    
    @IBOutlet weak var deviceNameTextField: UITextField!
    @IBOutlet weak var signalProcessTableView: UITableView!
    @IBOutlet weak var deviceNameSendButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.deviceNameSendButton.layer.masksToBounds = true
        self.deviceNameSendButton.layer.cornerRadius = 5
        self.deviceNameSendButton.layer.borderColor = appThemeColor.cgColor
        self.deviceNameSendButton.layer.borderWidth = 2
        
        signalProcessTableView.tableFooterView = UIView()
        signalProcessTableView.backgroundColor = UIColor.groupTableViewBackground
        view.backgroundColor = UIColor.groupTableViewBackground
        
        signalProcessArray.removeAll()
        adArray.removeAll()
        
        let expouserSignalProcess = SignalProcess(signalProcessType: SignalProcssType.exposure.rawValue, isAutoEnabled: false, value: "100", sliderMinValue: "0", sliderMaxValue: "65535", signalProcessSubType: "\(SignalProcssType.exposure.rawValue) Value")
        signalProcessArray.append(expouserSignalProcess)
        
        
        let noOfAverageSignalProcess = SignalProcess(signalProcessType: SignalProcssType.noOfAvg.rawValue, isAutoEnabled: false, value: "300", sliderMinValue: "1", sliderMaxValue: "800", signalProcessSubType: "\(SignalProcssType.noOfAvg.rawValue)")
        signalProcessArray.append(noOfAverageSignalProcess)
        
        
        let anaglogGain = ADObject(signalProcessType: SignalProcssType.analogGain.rawValue, selectedValue: "1X", valueArray: ["1X","2X","4X","8X"])
        
        adArray.append(anaglogGain)
        
        let digitalGain = ADObject(signalProcessType: SignalProcssType.digitalGain.rawValue, selectedValue: "0X", valueArray: ["0X","1X","2X","3X","4X","5X","6X","7X"])
        
        adArray.append(digitalGain)
        
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(dataRecieved(_:)), name: responseNotification.name, object: nil)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                    rootView?.makeToast("Device Name has been changed successfully")
                }
                
            }
        }
    }
    @IBAction func deviceNameSendAction(_ sender: Any) {
        
        
        if (deviceNameTextField.text?.count)! > 0
        {
            if deviceNameTextField.text!.trimmingCharacters(in: .whitespaces).count <= 12
            {
                
                var commandForDeviceWifi = START_TAG
                commandForDeviceWifi.append(WIFI_SSID_TAG)
                commandForDeviceWifi.append(deviceNameTextField.text!.trimmingCharacters(in: .whitespaces))
                commandForDeviceWifi.append(WIFI_PASSWORD_TAG)
                commandForDeviceWifi.append("12345678")
                commandForDeviceWifi.append(END_TAG)
                deviceNameTextField.resignFirstResponder()
                requestMessageForDeviceName = commandForDeviceWifi
                SocketController.sharedInstance.writeMessage(msg: requestMessageForDeviceName!)
               // deviceNameCommandProcess(commandString: commandForDeviceWifi)
            }
            else
            {
                self.view.makeToast("Device Name should't excess 12 charecters")
            }
        }
        else
        {
            self.view.makeToast("Enter device Name")
        }
    }

    
    func  deviceNameCommandProcess(commandString:String)  {
        
        let rootView = UIApplication.shared.keyWindow
        // Communicating with WIfi Device
       //   showProgressActivity(view: self.view)
    
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
                          rootView?.makeToast("Device Name has been changed successfully")
                        }
                        
                    }
                }
            }
        }, failure: {error  in
            print(error ?? "")
          //  hideProgressActivityWithFailure()
             DispatchQueue.main.async {
              rootView?.makeToast("Device Name changed Failure")
            }
        })
        
    }
    }
    
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            signalProcessTableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height+80, 0)
        }
    }
    @objc func keyboardWillHide(_ notification:Notification) {
        
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            signalProcessTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension SignalProcessViewController: UITableViewDataSource,UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int {
    
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        if section == 0
        {
         return signalProcessArray.count
        }
        else
        {
            return adArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //SignalProcessCell
       
        if indexPath.section == 0
        {
            let  cell   = tableView.dequeueReusableCell(withIdentifier: "SignalProcessCell") as! SignalProcessTableViewCell
            let objSignalProcess = signalProcessArray[indexPath.row]
            cell.fillData(signalProcessObj: objSignalProcess,indexPath:indexPath)
            return cell
        }
        else
        {
            
            let cell   = tableView.dequeueReusableCell(withIdentifier: "ADCell") as! AnalogAndDigitalGainTableViewCell
            let objAD = adArray[indexPath.row]
            cell.fillData(objAD: objAD, indexPath: indexPath)
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0
        {
            return 242
        }
        else
        {
            return 125
        }
    }
    
    
}

extension SignalProcessViewController:UITextFieldDelegate
{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
}
