//
//  SocketManager.swift
//
//
//  Created by Grimi on 6/21/15.
//
//

import UIKit

@objc protocol SocketStreamDelegate{
    func socketDidConnect(stream:Stream)
    @objc optional func socketDidDisconnet(stream:Stream, message:String)
    @objc optional func socketDidReceiveMessage(data:Data, request:String)
    @objc optional func socketDidEndConnection()
}

class Socket: NSObject {
    var delegate:SocketStreamDelegate?

    private let bufferSize = 1024
    private var _host:String?
    private var _port:Int?
    private var _messagesQueue:Array<String> = [String]()
    private var _streamHasSpace:Bool = false
    private var inputStream: InputStream!
    private var outputStream: OutputStream!
    var isClosed = false
    var isOpen = false
   // var responsedata = Data()
    var requestMsg:String!
    
    var host:String?{
        get{
            return self._host
        }
    }

    var port:Int?{
        get{
            return self._port
        }
    }

    deinit{
        if let inputStr = self.inputStream{
            inputStr.close()
            inputStr.remove(from: .main, forMode: RunLoopMode.defaultRunLoopMode)
        }
        if let outputStr = self.outputStream{
            outputStr.close()
            outputStr.remove(from: .main, forMode: RunLoopMode.defaultRunLoopMode)
        }
    }

    /**
    Opens streaming for both reading and writing, error will be thrown if you try to send a message and streaming hasn't been opened

    :param: host String with host portion
    :param: port Port
    */
    final func open(host:String!, port:Int!){
        self._host = host
        self._port = port
        
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           wifiAddress as CFString,
                                           333,
                                           &readStream,
                                           &writeStream)
        
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        if inputStream != nil && outputStream != nil {
        inputStream.delegate = self
        outputStream.delegate = self
        
        inputStream.schedule(in: .main, forMode: .commonModes)
        outputStream.schedule(in: .main, forMode: .commonModes)
        
        inputStream.open()
        outputStream.open()
        }
          else {
            print("[SCKT]: Failed Getting Streams")
        }
    }

    final func close(){
        if let inputStr = self.inputStream{
            inputStr.delegate = nil
            inputStr.close()
            inputStr.remove(from: .main, forMode: .commonModes)
        }
        if let outputStr = self.outputStream{
            outputStr.delegate = nil
            outputStr.close()
            outputStr.remove(from: .main, forMode: .commonModes)
        }
        isClosed = true
    }
    
    func send(message: String) {
       // responsedata = Data()
        requestMsg = message
        
       if  let writeData = message.data(using: .utf8)
       {
        _ = writeData.withUnsafeBytes { outputStream!.write($0, maxLength: writeData.count) }
       }
        
    }

}

extension Socket: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
          //  print("new message received")
            readAvailableBytes(stream: aStream as! InputStream)
        case Stream.Event.endEncountered:
              close()
        case Stream.Event.errorOccurred:
            print("error occurred")
        case Stream.Event.hasSpaceAvailable:
            print("has space available")
        case Stream.Event.openCompleted:
            openCompleted(stream:aStream)
            print("Stream has opened")
        default:
            print("some other event...")
            break
        }
    }
    
    private  func openCompleted(stream:Stream){
    
        if stream == inputStream || stream == outputStream
        {
            isOpen = true
            self.delegate?.socketDidConnect(stream: stream)
        }
    }
    
    private func readAvailableBytes(stream: InputStream) {
        
         let  resData = getDataFromStream(input: stream)
        
        if resData.count > 0
         {
            self.delegate?.socketDidReceiveMessage!(data: resData, request: requestMsg)
         }
        
    }
    
    func getDataFromStream(input:InputStream) -> Data {
        var tempData = Data()
        input.open()
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        while input.hasBytesAvailable {
             let read = input.read(buffer, maxLength: bufferSize)
            tempData.append(buffer, count: read)
        }
        buffer.deallocate()
        return tempData
    }
    
}
