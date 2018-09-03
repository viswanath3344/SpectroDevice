//
//  WifiController.swift
//  Spectrometer
//
//  Created by Ming-En Liu on 18/07/18.
//  Copyright © 2018 8locations. All rights reserved.
//

import Foundation
import SwiftSocket
import NetworkExtension
import UIKit
import SystemConfiguration.CaptiveNetwork


let devicePortNumber:Int32 = 333
let connectionTimeOut  = 15
let wifiConnectionNotification = Notification.Name("WifiConnectionStatus")

let wifiAddress  = "192.168.4.1"




class WifiController: NSObject
{
    
    var tcpClient:TCPClient!
    var isConnected:Bool!
    var istriedForConnection = false
    var connectedDeviceWifiAddress:String = ""
    
    class var sharedInstance : WifiController
    {
        struct Singleton
        {
            static let instance = WifiController()
        }
        return Singleton.instance
    }
    
    private override init()
    {
        super.init()
        
        isConnected = false
        self.tcpClient = TCPClient(address: wifiAddress, port: 333)
    //    NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        
  //      NotificationCenter.default.addObserver(self, selector: #selector(receiveNotification), name: wifiStatusNotification , object: nil)
        
//        DispatchQueue.global(qos: .background).async {
//
//            _ = self.openConnection()
//        }
        
        
    }
    
    @objc func willEnterForeground() {
        // do stuff
        
       checkDeviceConnection()
    }
    
    
    @objc func receiveNotification(notification:NSNotification)  {
        
       checkDeviceConnection()
        
    }
    func checkDeviceConnection()  {
        
        if !isConnected || (connectedDeviceWifiAddress != fetchSSIDInfo())
        {
            DispatchQueue.global(qos: .background).async {
                self.isConnected = false
                self.istriedForConnection = false
                _ = self.openConnection()
            }
        }
        else
        {
            NotificationCenter.default.post(name: wifiConnectionNotification, object: true)
        }
    }
    
    
    func openConnection() ->Bool {
//        print("This is run on the background queue")
    
        if !isConnected && self.tcpClient != nil && !istriedForConnection
        {
            istriedForConnection = true
        switch self.tcpClient.connect(timeout: 15) {
            
        case .success:
            print("Connection Success")
            isConnected = true
            connectedDeviceWifiAddress = fetchSSIDInfo()
            NotificationCenter.default.post(name: wifiConnectionNotification, object: true)
            return true
            //self.connectButton.setTitle("Disconnect", for: UIControlState.normal)
            // hideProgress()
            
        // Connection successful 🎉
        case .failure(let error):
            // 💩
            print(error)
            istriedForConnection = false
            NotificationCenter.default.post(name: wifiConnectionNotification, object: false)
            isConnected = false
            return false
        }
        }
        return false
        
    }
    
    func closeConnection()  {
        
        if self.tcpClient != nil
        {
         self.tcpClient.close()
         self.tcpClient = nil
         isConnected = false
        }
    }
    
    
    func sendData(dataInString:String?,completion: @escaping ([Byte]) -> Void,failure: @escaping (Error?) -> Void )  {
        let data: Data = (dataInString?.data(using: .utf8))!
        // ... Bytes you want to send
        
        
        let result = self.tcpClient.send(data: data)
        
      
        
        var timeout  = 0
        
        if (dataInString?.contains(MOVE_STRIP_CLOCKWISE_TAG))! || (dataInString?.contains(MOVE_STRIP_COUNTER_CLOCKWISE_TAG) )!

        {
            sleep(1)
            timeout = 2000
        }
        else if dataInString == INTESITY_VALUES_TAG
        {
            sleep(1)
            timeout = 1000
            
        }
        else
        {
            timeout = 2000
        }
       
        
        switch result {
        case .success:
            var data = [Byte]()
            print("Success")

            while true {
                
                if dataInString == INTESITY_VALUES_TAG
                {
                    guard let response = self.tcpClient.read(1024*10, timeout: timeout) else {
                        failure(nil)
                        break
                    }
                    
                    print(response.count)
                    print("called inside")
                    data += response
                    //   print(String(bytes: data, encoding: .utf8) ?? "")
                    
                    if dataInString == INTESITY_VALUES_TAG
                    {
                        print(data.count)
                        if data.count == 2571
                        {
                            completion(data)
                            data.removeAll()
                        }
                        else
                        {
                            
                            print("Intesity reading bytes not matched")
                            //  failure(nil)
                        }
                        
                    }
                    else
                    {
                        completion(data)
                        data.removeAll()
                    }
                }
                else
                {
                guard let response = self.tcpClient.read(1024*10) else {
                    
                    failure(nil)
                    return }
                    
                    print(response.count)
                    print("called inside")
                    data += response
                    //   print(String(bytes: data, encoding: .utf8) ?? "")
                    
                    if dataInString == INTESITY_VALUES_TAG
                    {
                        print(data.count)
                        if data.count == 2571
                        {
                            completion(data)
                            data.removeAll()
                        }
                        else
                        {
                            
                            print("Intesity reading bytes not matched")
                            //  failure(nil)
                        }
                        
                    }
                    else
                    {
                        completion(data)
                        data.removeAll()
                    }
                }
               
            }
          //  print(data)
             break
        case .failure(let error):
             print("Failure")
            print(error)
            failure(error)
            break
        }
    }
    
    
    
   
    func fetchSSIDInfo() ->  String {
            var currentSSID = ""
            if let interfaces:CFArray = CNCopySupportedInterfaces() {
                for i in 0..<CFArrayGetCount(interfaces){
                    let interfaceName: UnsafeRawPointer = CFArrayGetValueAtIndex(interfaces, i)
                    let rec = unsafeBitCast(interfaceName, to: AnyObject.self)
                    let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)" as CFString)
                    if unsafeInterfaceData != nil {
                        let interfaceData = unsafeInterfaceData! as Dictionary?
                        for dictData in interfaceData! {
                            if dictData.key as! String == "SSID" {
                                currentSSID = dictData.value as! String
                            }
                        }
                    }
                }
            }
            return currentSSID
        }
    
    func getWiFiAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }
    
    
    func rawBuffer2Hex(buf:[Byte]) {
        var str = ""
        //var ui8= new Uint8Array(buf);
        
        for index in 0..<buf.count
        {
            var immedidateData = Data.init(bytes: [buf[index]]).hexEncodedString()
            
            if(immedidateData.count == 1){
                
                immedidateData = "0" + immedidateData;
            }
            str = str+immedidateData;
            print(immedidateData.hexaToInt)
            
        }
        print(str)
        hexToString(hex: str)
    }
    
    func hexToString (hex:String) {
        
        var finalString = ""
        
        var startIndex  = 0
        let readingBytesCount = 2
        
        while (hex.count-readingBytesCount) > startIndex  {
            finalString = finalString + "\(hex.substring(with: startIndex..<startIndex+2).hexaToInt)"
            print(finalString)
            startIndex = startIndex+readingBytesCount
        }
        
        print(finalString)
        
    }
    
    
    
    func floatValue(data: Data) -> Int32 {
        
        return Int32(bitPattern: UInt32(bigEndian: data.withUnsafeBytes { $0.pointee }))
        
    }
    
    
    
    
}


/* JAVASCRIPT METHODS
 
 //utility functions for string processing
 
 function arrayBuffer2str(buf) {
 
 var str= '';
 
 var ui8= new Uint8Array(buf);
 
 for (var i= 0 ; i < ui8.length ; i++) {
 
 str= str+String.fromCharCode(ui8[i]);
 
 }
 
 return str;
 
 }
 
 
 
 function hexToString (hex) {
 
 var string = '';
 
 for (var i = 0; i < hex.length; i += 2) {
 
 string += String.fromCharCode(parseInt(hex.substr(i, 2), 16));
 
 }
 
 return string;
 
 
 }
 
 
 
 function arrayBufferTo16str(buf) {
 
 var str= '';
 
 var ui16= new Uint16Array(buf);
 
 for (var i= 0 ; i < ui16.length ; i++) {
 
 str= str+String.fromCharCode(ui16[i]);
 
 }
 
 return str;
 
 }
 
 
 
 function str2arrayBuffer(str) {
 
 var buf= new ArrayBuffer(str.length);
 
 var bufView= new Uint8Array(buf);
 
 for (var i= 0 ; i < str.length ; i++) {
 
 bufView[i]= str.charCodeAt(i);
 
 }
 
 return buf;
 
 }
 
 
 
 function rawBuffer2Hex(buf) {
 
 var str= '';
 
 //var ui8= new Uint8Array(buf);
 
 for (var i= 0 ; i < buf.length ; i++) {
 
 //str= str+String.fromCharCode(ui8[i]); .toString(16)
 
 //str= str+String.fromCharCode(ui8[i]);
 
 var immedidateData = buf[i].toString(16);
 
 if(immedidateData.length === 1){
 
 immedidateData = '0' + immedidateData;
 
 }
 
 str= str+immedidateData;
 
 }
 
 return str;
 
 }
 
 */


