//
//  MotorControlViewController.swift
//  SpectroDevice
//
//  Created by Ming-En Liu on 20/07/18.
//  Copyright © 2018 Vedas labs. All rights reserved.
//

import UIKit
import DropDown
struct MotorControl {
    
    var motorControlTitle:String
    var isClockWise:Bool
    var stepCountName:String
    var stepCountValue:String
    var stepCountSliderMinValue:String
    var stepCountSliderMaxValue:String
    var waitTimeName:String
    var waitTimeValue:String
    var waitTimeSliderMinValue:String
    var waitTimeSliderMaxValue:String
    
}
var motorControlArray = [MotorControl]()

class MotorControlViewController: UIViewController {

    @IBOutlet weak var motorControlTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
       
       motorControlArray.removeAll()
        
       let objMotorControl1 = MotorControl(motorControlTitle: "Motor Control 1", isClockWise: true, stepCountName: "Step Count ", stepCountValue: "0", stepCountSliderMinValue: "0", stepCountSliderMaxValue: "5000", waitTimeName: "Wait Time(sec)", waitTimeValue: "0", waitTimeSliderMinValue: "0", waitTimeSliderMaxValue: "10")
        motorControlArray.append(objMotorControl1)
        
        
        let objMotorControl2 = MotorControl(motorControlTitle: "Motor Control 2", isClockWise: true, stepCountName: "Step Count ", stepCountValue: "0", stepCountSliderMinValue: "0", stepCountSliderMaxValue: "5000", waitTimeName: "Wait Time(sec)", waitTimeValue: "0", waitTimeSliderMinValue: "0", waitTimeSliderMaxValue: "10")
        motorControlArray.append(objMotorControl2)
        
        
        let objMotorControl3 = MotorControl(motorControlTitle: "Motor Control 3", isClockWise: true, stepCountName: "Step Count ", stepCountValue: "0", stepCountSliderMinValue: "0", stepCountSliderMaxValue: "5000", waitTimeName: "Wait Time(sec)", waitTimeValue: "0", waitTimeSliderMinValue: "0", waitTimeSliderMaxValue: "10")
        motorControlArray.append(objMotorControl3)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            motorControlTableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height+100, 0)
        }
    }
    @objc func keyboardWillHide(_ notification:Notification) {
        
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            motorControlTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
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

extension MotorControlViewController: UITableViewDataSource,UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return motorControlArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //SignalProcessCell
        let cell   = tableView.dequeueReusableCell(withIdentifier: "MotorControl") as! MotorControlTableViewCell
        let objMotorControl = motorControlArray[indexPath.row]
        cell.fillData(motorControlObj: objMotorControl,indexPath:indexPath)
        return cell
        
    }
    
    
}

