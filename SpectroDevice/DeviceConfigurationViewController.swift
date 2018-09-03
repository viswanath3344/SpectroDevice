//
//  DeviceConfigurationViewController.swift
//  SpectroDevice
//
//  Created by Ming-En Liu on 19/07/18.
//  Copyright © 2018 Vedas labs. All rights reserved.
//

import UIKit
import PageMenu

class DeviceConfigurationViewController: UIViewController {

    var pageMenu : CAPSPageMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Device Configuration"
        
      let leftButton =  UIBarButtonItem(image:#imageLiteral(resourceName: "ic_home"), landscapeImagePhone: #imageLiteral(resourceName: "ic_home"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(tappedOnBackButton))
        
        self.navigationItem.leftBarButtonItem = leftButton
        setUpPageMenu()
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpPageMenu()  {
        
        // Array to keep track of controllers in page menu
        var controllerArray : [UIViewController] = []
        
        // Create variables for all view controllers you want to put in the
        // page menu, initialize them, and add each to the controller array.
        // (Can be any UIViewController subclass)
        // Make sure the title property of all view controllers is set
        // Example:
        
        let controller1 : UIViewController = (self.storyboard?.instantiateViewController(withIdentifier: "SignalProcessViewController"))!
        controller1.title = "Signal Process"
        controllerArray.append(controller1)
        
        let controller2 : UIViewController = (self.storyboard?.instantiateViewController(withIdentifier: "MotorControlViewController"))!
        
        controller2.title = "Motor Control"
        controllerArray.append(controller2)
        
        let controller3 : UIViewController = (self.storyboard?.instantiateViewController(withIdentifier: "LEDControlViewController"))!
        controller3.title = "LED Control"
        controllerArray.append(controller3)
        
        
        // Customize page menu to your liking (optional) or use default settings by sending nil for 'options' in the init
        // Example:
        let parameters: [CAPSPageMenuOption] = [
            .menuItemSeparatorWidth(2),
            .useMenuLikeSegmentedControl(true),
            .scrollMenuBackgroundColor(UIColor.white),
            .viewBackgroundColor(UIColor.white),
            .unselectedMenuItemLabelColor(UIColor.gray),
            .selectedMenuItemLabelColor(menuThemeColor),
            .menuHeight(60),
            .menuItemFont(UIFont.systemFont(ofSize: 16)),
            .selectionIndicatorColor(menuThemeColor),
            .menuMargin(20)
            
        ]
        
        // Initialize page menu with controller array, frame, and optional parameters
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame:    CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), pageMenuOptions: parameters)
        
        
        // Lastly add page menu as subview of base view controller view
        // or use pageMenu controller in you view hierachy as desired
        self.view.addSubview(pageMenu!.view)
        self.pageMenu?.currentPageIndex = 0
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func tappedOnBackButton()
    {
        
       self.navigationController?.popToRootViewController(animated: true)
        
    }

}
