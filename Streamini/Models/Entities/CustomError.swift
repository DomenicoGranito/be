//
//  Error.swift
//  Streamini
//
//  Created by Vasily Evreinov on 08/02/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import Foundation

class CustomError : NSObject {
    static let kLoginExpiredCode: Int  = 100
    static let kUnsuccessfullPing: Int = 202
    static let kUserBlocked: Int       = 201

    var status             = false
    var code: Int         = 0
    var message: NSString  = ""

    func toNSError() -> NSError {
        let userInfo = NSMutableDictionary()
        userInfo[NSLocalizedDescriptionKey] = self.message
        userInfo["code"] = self.code
        
        let error = NSError(domain: "com.uniprogy.streamini", code: 1, userInfo: (userInfo as NSDictionary) as! [AnyHashable : Any])
        return error
    }
}
