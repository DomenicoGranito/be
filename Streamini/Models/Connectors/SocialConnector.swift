//
//  SocialConnector.swift
//  Streamini
//
//  Created by Vasily Evreinov on 22/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class SocialConnector: Connector
{
    func users(_ data: NSDictionary, _ success: @escaping (_ top: [User], _ featured: [User]) -> (), _ failure: @escaping (_ error: NSError) -> ())
    {
        let path = "social"
        
        var params=self.sessionParams()
        
        if let page=data.value(forKey:"p")
        {
            params!["p"]=page as AnyObject
        }
        
        let responseMapping = UserMappingProvider.userResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.successful)
        
        let topResponseDescriptor = RKResponseDescriptor(mapping: responseMapping, method:.GET, pathPattern: nil, keyPath: "data.top", statusCodes: statusCode)
        manager.addResponseDescriptor(topResponseDescriptor)
        
        let featuresResponseDescriptor = RKResponseDescriptor(mapping: responseMapping, method:.GET, pathPattern: nil, keyPath: "data.featured", statusCodes: statusCode)
        manager.addResponseDescriptor(featuresResponseDescriptor)
        
        manager.getObjectsAtPath(path, parameters: params, success: { (operation, mappingResult) -> Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status
            {
                if error.code==CustomError.kLoginExpiredCode
                {
                    self.relogin({ () -> () in
                        self.users(data, success, failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                }
                else
                {
                    failure(error.toNSError())
                }
            }
            else
            {
                let top         = mappingResult?.dictionary()["data.top"] as! [User]
                let featured    = mappingResult?.dictionary()["data.featured"] as! [User]
                success(top, featured)
            }
        }, failure:{(operation, error)->Void in
            failure(error! as NSError)
        })
    }
    
    func search(_ data: NSDictionary, _ success: @escaping (_ users: [User]) -> (), _ failure: @escaping (_ error: NSError) -> ())
    {
        let path = "social/search"
        
        var params=self.sessionParams()
        
        if let page=data.value(forKey:"p")
        {
            params!["p"]=page as AnyObject
        }
        
        if let query=data.value(forKey:"q")
        {
            params!["q"]=query as AnyObject
        }

        let responseMapping = UserMappingProvider.userResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.successful)
        
        let responseDescriptor = RKResponseDescriptor(mapping: responseMapping, method:.GET, pathPattern: nil, keyPath: "data.users", statusCodes: statusCode)
        manager.addResponseDescriptor(responseDescriptor)
        
        manager.getObjectsAtPath(path, parameters: params, success: { (operation, mappingResult) -> Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status
            {
                if error.code==CustomError.kLoginExpiredCode
                {
                    self.relogin({ () -> () in
                        self.search(data, success, failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                }
                else
                {
                    failure(error.toNSError())
                }
            }
            else
            {
                let users = mappingResult?.dictionary()["data.users"] as! [User]
                success(users)
            }
            }, failure:{(operation, error)->Void in
                failure(error! as NSError)
        })
    }
    
    func follow(_ userId: UInt, _ success: @escaping () -> (), _ failure: @escaping (_ error: NSError) -> ())
    {
        let path = "social/follow"
        
        var params = self.sessionParams()
        params!["id"] = userId as AnyObject?
        
        manager.post(nil, path: path, parameters: params, success:
            { (operation, mappingResult) -> Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
                
            if !error.status
            {
                if error.code==CustomError.kLoginExpiredCode
                {
                    self.relogin({ () -> () in
                        self.follow(userId, success, failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                }
                else
                {
                    failure(error.toNSError())
                }
            }
            else
            {
                success()                
            }
            }, failure:{(operation, error)->Void in
                failure(error! as NSError)
        })
    }
    
    func unfollow(_ userId: UInt, _ success: @escaping () -> (), _ failure: @escaping (_ error: NSError) -> ())
    {
        let path = "social/unfollow"
        
        var params = self.sessionParams()
        params!["id"] = userId as AnyObject?
        
        manager.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status
            {
                if error.code==CustomError.kLoginExpiredCode
                {
                    self.relogin({ () -> () in
                        self.unfollow(userId, success, failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                }
                else
                {
                    failure(error.toNSError())
                }
            }
            else
            {
                success()
            }
            }, failure: { (operation, error) -> Void in
                failure(error! as NSError)
        })
    }
    
    func block(_ userId: UInt, _ success: @escaping () -> (), _ failure: @escaping (_ error: NSError) -> ())
    {
        let path = "social/block"
        
        var params = self.sessionParams()
        params!["id"] = userId as AnyObject?
        
        manager.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status
            {
                if error.code==CustomError.kLoginExpiredCode
                {
                    self.relogin({ () -> () in
                        self.block(userId, success, failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                }
                else
                {
                    failure(error.toNSError())
                }
            }
            else
            {
                success()
            }
            }, failure:{ (operation, error) -> Void in
                failure(error! as NSError)
        })
    }
    
    func unblock(_ userId: UInt, _ success: @escaping () -> (), _ failure: @escaping (_ error: NSError) -> ())
    {
        let path = "social/unblock"
        
        var params = self.sessionParams()
        params!["id"] = userId as AnyObject?
        
        manager.post(nil, path:path, parameters:params, success:{(operation, mappingResult)->Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status
            {
                if error.code == CustomError.kLoginExpiredCode
                {
                    self.relogin({ () -> () in
                        self.unblock(userId, success, failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                }
                else
                {
                    failure(error.toNSError())
                }
            }
            else
            {
                success()
            }
            }, failure: { (operation, error) -> Void in
                failure(error! as NSError)
        })
    }
}
