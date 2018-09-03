//
//  InternetStatusClass.swift
//  Impulse8050
//
//  Created by VedsAshk on 28/09/16.
//  Copyright © 2016 Holux. All rights reserved.
//

import UIKit


class InternetStatusClass: NSObject
{
    var reachability:Reachability!
    var isConnected = true
  
    
    class var sharedInstance : InternetStatusClass
    {
        struct Singleton
        {
            static let instance = InternetStatusClass()
        }
        return Singleton.instance
    }
    
    private override init()
    {
        super.init()
         reachability = Reachability()
        
        if reachability.currentReachabilityStatus == .notReachable
        {
            
           
        }
        else
        {
        
        
        }
        reachability.whenReachable = { reachability in
           
            print("reachable")
            
        }
        reachability.whenUnreachable = { _ in
            print("Not reachable")
        }
        
        
        
        // Initialize central manager on load
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    @objc func reachabilityChanged(_ note: NSNotification) {
        
        
         NotificationCenter.default.post(Notification.init(name: wifiStatusNotification))
        
        if reachability.currentReachabilityStatus == .notReachable
        {
            
            isConnected = false
        }
        else
        {
            isConnected = true
          
       
        }

    }
    
}
