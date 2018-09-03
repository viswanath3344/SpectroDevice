//
//  WifiViewController.swift
//  SpectroDevice
//
//  Created by Ming-En Liu on 19/07/18.
//  Copyright © 2018 Vedas labs. All rights reserved.
//

import UIKit

class WifiViewController: UIViewController {

    @IBOutlet weak var wifiImageView: UIImageView!
    @IBOutlet weak var connectingLabel: UILabel!
    var alertView:UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.wifiConnectionStatus(notification:)), name: wifiConnectionNotification, object: nil)
          self.connectingLabel.text = "Waiting for Spectrum Device Connection"
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        connectingLabel.startBlink()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func wifiConnectionStatus(notification:NSNotification){
        
        if notification.name == wifiConnectionNotification
        {
            if let isWificonnected = notification.object as? Bool
            {
                if isWificonnected{
                    
                    // dismiss wifi controller
                    deviceConnnectedAction()
                  
                    
                }
                else
                {
                  deviceDisconnnectedAction()
                }
            }
            
        }
    }
    
    
    
    func deviceConnnectedAction() {
        DispatchQueue.main.async {
            print("This is run on the main queue, after the previous code in outer block")

            if self.alertView != nil
            {
                self.alertView.dismiss(animated: true, completion: nil)
            }
            
            self.connectingLabel.stopBlink()
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func deviceDisconnnectedAction() {
        
        DispatchQueue.main.async {
             self.connectingLabel.stopBlink()
             self.connectingLabel.text = "No Spectrum Device connected"
            //  hideProgress()
            self.showWifiAlert()
            
        }
    }
    
    func showWifiAlert()  {
        
        alertView = UIAlertController.init(title: "How to connect to device", message: "Phone settings -> wifi  settings  -> Select the wifi from device", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction.init(title: "Go to Settings", style: UIAlertActionStyle.default) { (action) in
            
            self.moveToPhoneWifiSettings()
            
        }
        
        let cancelAction = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel ) { (action) in
            
        }
        alertView.addAction(okAction)
        alertView.addAction(cancelAction)
        self.present(alertView, animated: true) {
            
        }
        
        
    }
    
    func moveToPhoneWifiSettings(){
        let url = URL(string: "App-Prefs:root=WIFI") //for WIFI setting app
        let app = UIApplication.shared
        if app.canOpenURL(url!)
        {
            if #available(iOS 10.0, *) {
                app.open(url!, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
            }
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

