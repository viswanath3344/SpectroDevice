//
//  LEDControlViewController.swift
//  SpectroDevice
//
//  Created by Ming-En Liu on 20/07/18.
//  Copyright © 2018 Vedas labs. All rights reserved.
//

import UIKit


struct LEDContol {
    var ledControlTitle:String
    var ledControlSubTitle:String
    var isON:Bool
    var value : String
    var ledControlMinValue:String
    var ledControlMaxValue:String
    
}
 var ledControlArray  = [LEDContol]()

class LEDControlViewController: UIViewController {

    @IBOutlet weak var ledControlLabel: UILabel!
    @IBOutlet weak var ledControlTableView: UITableView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

         ledControlTableView.tableFooterView = UIView()
         ledControlTableView.backgroundColor = UIColor.groupTableViewBackground
         view.backgroundColor = UIColor.groupTableViewBackground
        
        ledControlArray.removeAll()
        
        let uvLED  = LEDContol(ledControlTitle: LEDControlType.uv.rawValue, ledControlSubTitle: "\(LEDControlType.uv.rawValue) intensity", isON: false, value: "600", ledControlMinValue: "0", ledControlMaxValue: "1000")
        ledControlArray.append(uvLED)
        
        let whiteLED  = LEDContol(ledControlTitle: LEDControlType.whiteLED.rawValue, ledControlSubTitle: "\(LEDControlType.whiteLED.rawValue) intensity", isON: false, value: "400", ledControlMinValue: "0", ledControlMaxValue: "1000")
        ledControlArray.append(whiteLED)
        
        let reflectionLED  = LEDContol(ledControlTitle: LEDControlType.reflectionLED.rawValue, ledControlSubTitle: "\(LEDControlType.reflectionLED.rawValue) intensity", isON: false, value: "900", ledControlMinValue: "0", ledControlMaxValue: "1000")
        ledControlArray.append(reflectionLED)
    
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension LEDControlViewController: UITableViewDataSource,UITableViewDelegate,LEDTableviewCellDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ledControlArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //SignalProcessCell
    
        let cell   = tableView.dequeueReusableCell(withIdentifier: "LEDCell") as! LEDControlTableViewCell
        let objLEDControl = ledControlArray[indexPath.row]
        cell.delegate = self
        cell.fillData(ledControlObj: objLEDControl, indexPath: indexPath)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        /*   let objLEDControl = ledControlArray[indexPath.row]
        
     if objLEDControl.isEnabled
        {
            return 230
        }
        else
        {
            return 80
        }
        */
        return 60
        
    }
    
    
    func updateTableView() {
        ledControlTableView.reloadData() // you do have an outlet of tableView I assume
    }
    
    
    
    
}


extension LEDControlViewController:UITextFieldDelegate
{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
}
