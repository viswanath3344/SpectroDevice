//
//  ProgressActivity.swift
//  SpectroDevice
//
//  Created by Ming-En Liu on 03/08/18.
//  Copyright © 2018 Vedas labs. All rights reserved.
//

import Foundation
import MBProgressHUD
import UIKit



var hud:MBProgressHUD!

func showProgressActivity(view:UIView){
    DispatchQueue.main.async {
      hud = MBProgressHUD.showAdded(to: view, animated: true)
      hud.label.text = "In progress"
        
    }
}

func hideProgressActivityWithSuccess(){
    DispatchQueue.main.async {
        sleep(2)
        let image = #imageLiteral(resourceName: "Right")
        let imaageView = UIImageView(image: image)
        hud.customView = imaageView
        hud.mode = MBProgressHUDMode.customView
        hud.label.text = "Success"
        sleep(2)
        hud.hide(animated: true)
    }

    
}

func hideProgressActivityWithFailure(){
    DispatchQueue.main.async {
        let image = #imageLiteral(resourceName: "Wrong")
        let imaageView = UIImageView(image: image)
        hud.customView = imaageView
        hud.mode = MBProgressHUDMode.customView
        hud.label.text = "Failure"
        sleep(2)
        hud.hide(animated: true)
    }
    
    
}
