//
//  PubNubMessenger.swift
//  Streamini
//
//  Created by Vasily Evreinov on 07/07/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import UIKit

class PubNubMessenger: NSObject, PNDelegate
{
    func receive(_ handler:@escaping (_ message: Message)->())
    {
        pubNub.observationCenter.removeMessageReceiveObserver(self)
        pubNub.observationCenter.addMessageReceiveObserver(self, with: { (message) -> Void in
            self.logMessage("Received message: \(message?.description)")
            let dictionary: NSDictionary = message!.message as! NSDictionary
            let chatMessage = Message.deserialize(dictionary)
            handler(chatMessage)
        })
    }

    var pubNub: PubNub = PubNub()
    var logger = false
    
    override init() {
        super.init()
        let (publishKey, subscribeKey) = Config.shared.pubNub()
        let configuration = PNConfiguration(publishKey: publishKey, subscribeKey: subscribeKey, secretKey: nil)
        
        pubNub.setConfiguration(configuration)
        logMessage("Set configuration.")
        
        pubNub.setDelegate(self)
        
        pubNub.connect()
        logMessage("Connecting to PubNub..")
    }
    
    // Subscribe to stream channel
    func connect(_ streamId: UInt) {
        logMessage("Subscribe to \(streamId)..")
        let channel: AnyObject! = PNChannel.channel(withName: "\(streamId)") as AnyObject!
        pubNub.subscribe(on: [channel], withCompletionHandling: { (state, channels, error) -> Void in
        })
    }
    
    // Disconnect from PubNub service
    func disconnect(_ streamId: UInt)
    {
        logMessage("Disconnecting..")
        pubNub.disconnect()
    }
        
    // Send message to channel
    func send(_ message: Message, streamId: UInt) {
        logMessage("Send message: \(message.description) to \(streamId)..")
        let channel: PNChannel = PNChannel.channel(withName: "\(streamId)") as! PNChannel
        pubNub.sendMessage(Message.serialize(message), to: channel) { (state, data) -> Void in
        }
    }
        
    func logMessage(_ message: String) {
        if logger {
            print("PubNubMessenger: \(message)")
        }
    }
    
    func shouldRunClientInBackground() -> Bool {
        return true
    }
}
