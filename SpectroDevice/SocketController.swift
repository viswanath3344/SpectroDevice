//
//  SocketController.swift
//  SpectroDevice
//
//  Created by Ming-En Liu on 13/08/18.
//  Copyright © 2018 Vedas labs. All rights reserved.
//

import UIKit

 let responseNotification = Notification(name: Notification.Name(rawValue: "DataAvaialble"))

class SocketController: NSObject {
    
   private var socket:Socket!
   private var socketresponseData:Data!
   private var isConnected:Bool!
    
    class var sharedInstance : SocketController
    {
        struct Singleton
        {
            static let instance = SocketController()
        }
        return Singleton.instance
    }
    
    private override init()
    {
        super.init()
        
        socketresponseData = Data()
        socket = Socket()
        socket.delegate = self
        socket.open(host: wifiAddress, port: 333)
        
    }
    
    func clearCache()  {
        
        socketresponseData.removeAll()
    }
    
    func writeMessage(msg:String)  {
        
        socket.send(message: msg)
        
    }
    
     func getConnectionStatus() -> Bool{
        return isConnected
    }
    
//    func readMessage()  -> Data {
//
//        return socketresponseData
//    }
    
}

extension SocketController:SocketStreamDelegate
{
    func socketDidConnect(stream: Stream) {
        
        print("socket is connected")
        isConnected = true
    }
    func socketDidDisconnet(stream: Stream, message: String) {
        print("disconnected socket \(message)")
        isConnected = false
    }
    
    func socketDidReceiveMessage(data: Data, request: String) {
        
        print(data.count)
        if request == INTESITY_VALUES_TAG
        {
            socketresponseData.append(data)
            
            if socketresponseData.count == 2571
            {
               
                var dictionary = Dictionary<String, Any>()
                dictionary["request"] = request
                dictionary["response"] = socketresponseData
                NotificationCenter.default.post(name: responseNotification.name, object: self, userInfo:dictionary)
                socketresponseData.removeAll()
                
                print("Intesnisty Data Recieved")
            }
        }
        else
        {
            socketresponseData.append(data)
            var dictionary = Dictionary<String, Any>()
            dictionary["request"] = request
            dictionary["response"] = socketresponseData
            NotificationCenter.default.post(name: responseNotification.name, object: self, userInfo:dictionary)
            socketresponseData.removeAll()
            
        }
        
        
    }
    
    
}



