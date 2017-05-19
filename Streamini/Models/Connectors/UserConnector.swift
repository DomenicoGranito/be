//
//  UserConnector.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class UserConnector: Connector
{
    func getWeChatAccessToken(_ path:String, success:@escaping (_ data:NSDictionary)->(), failure:@escaping (_ error:NSError)->())
    {
        let manager=RKObjectManager(baseURL:NSURL(string:"https://api.weixin.qq.com/sns/") as URL!)
        RKMIMETypeSerialization.registerClass(RKNSJSONSerialization.self, forMIMEType:"text/plain")
        
        let responseMapping=UserMappingProvider.weChatLoginResponseMapping()
        
        let statusCode=RKStatusCodeIndexSetForClass(.successful)
        
        let userResponseDescriptor=RKResponseDescriptor(mapping:responseMapping, method:.GET, pathPattern:nil, keyPath:"", statusCodes:statusCode)
        manager?.addResponseDescriptor(userResponseDescriptor)
        
        manager?.getObjectsAtPath(path, parameters:nil, success:{(operation, mappingResult)->Void in
            
            let json=try! JSONSerialization.jsonObject(with: (operation?.httpRequestOperation.responseData)!, options:.mutableLeaves) as! NSDictionary
            
            success(json)
            },
        failure:{(operation, error)->Void in
            //failure(error)
        })
    }
    
    func getWeChatUserProfile(_ path:String, success:@escaping (_ data:NSDictionary)->(), failure:@escaping (_ error:NSError)->())
    {
        let manager=RKObjectManager(baseURL:NSURL(string:"https://api.weixin.qq.com/sns/") as URL!)
        
        let responseMapping=UserMappingProvider.weChatLoginResponseMapping()
        
        let statusCode=RKStatusCodeIndexSetForClass(.successful)
        
        let userResponseDescriptor=RKResponseDescriptor(mapping:responseMapping, method:.GET, pathPattern:nil, keyPath:"", statusCodes:statusCode)
        manager?.addResponseDescriptor(userResponseDescriptor)
        
        manager?.getObjectsAtPath(path, parameters:nil, success:{(operation, mappingResult)->Void in
            
            let json=try! JSONSerialization.jsonObject(with: (operation?.httpRequestOperation.responseData)!, options:.mutableLeaves) as! NSDictionary
            
            success(json)
            },
            failure:{(operation, error)->Void in
            //failure(error)
        })
    }

    func logout(_ success: @escaping () -> (), failure: @escaping (_ error: NSError) -> ())
    {
        let path = "user/logout"
        
        manager?.post(nil, path: path, parameters: nil, success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                failure(error.toNSError())
            } else {
                success()
            }
            }, failure:{ (operation, error) -> Void in
                //failure(error)
        })
    }
    
    func get(_ id: UInt?, success: @escaping (_ user: User) -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "user"
        
        let responseMapping = UserMappingProvider.userResponseMapping()
        
        let statusCode = RKStatusCodeIndexSetForClass(.successful)
        
        let userResponseDescriptor = RKResponseDescriptor(mapping: responseMapping, method:.GET, pathPattern: nil, keyPath: "data", statusCodes: statusCode)
        manager?.addResponseDescriptor(userResponseDescriptor)
        
        var params=self.sessionParams()
        
        if let uid=id
        {
            params!["id"] = uid as AnyObject?
        }
        
        manager?.getObjectsAtPath(path, parameters: params, success: { (operation, mappingResult) -> Void in
            // success code
            let error:Error = self.findErrorObject(mappingResult: mappingResult!)!

            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.get(id, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                let user = mappingResult?.dictionary()["data"] as! User
                success(user)
            }
            }, failure: { (operation, error) -> Void in
                //failure(error)
        })
    }
    
    func followers(_ data: NSDictionary, success: @escaping (_ users: [User]) -> (), failure: @escaping (_ error: NSError) -> ()) {
        usersList("user/followers", data: data, success: success, failure: failure)
    }
    
    func following(_ data: NSDictionary, success: @escaping (_ users: [User]) -> (), failure: @escaping (_ error: NSError) -> ()) {
        usersList("user/following", data: data, success: success, failure: failure)
    }
    
    func blocked(_ data: NSDictionary, success: @escaping (_ users: [User]) -> (), failure: @escaping (_ error: NSError) -> ()) {
        usersList("user/blocked", data: data, success: success, failure: failure)
    }
    
    func avatar(_ success: @escaping () -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "user/avatar"
        
        manager?.post(nil, path: path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.avatar(success, failure: failure)
                        }, failure: { () -> () in
                            failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                success()
            }
            }, failure: { (operation, error) -> Void in
                //failure(error)
        })
    }
    
    func uploadAvatar(_ filename: String, data: NSData, success: @escaping () -> (), failure: @escaping (_ error: NSError) -> (), progress: @escaping ((UInt, Int64, Int64) -> Void)) {
        let path = "user/avatar"
        
        let request =
        manager?.multipartFormRequest(with: nil, method:.POST, path: path, parameters: self.sessionParams()) { (formData) -> Void in
            formData?.appendPart(withFileData: data as Data, name: "image", fileName: filename, mimeType: "image/jpeg")
        }
        
        let operation = manager?.objectRequestOperation(with: request as URLRequest!, success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.uploadAvatar(filename, data: data, success: success, failure: failure, progress: progress)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                success()
            }
            }) { (operation, error) -> Void in
                //failure(error)
        }
        
        operation?.httpRequestOperation.setUploadProgressBlock(progress)
        manager?.enqueue(operation)
    }
    
    func userDescription(_ text: String, success:@escaping () -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "user/description"
        
        var params = self.sessionParams()
        params!["text"] = text as AnyObject?
        
        manager?.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.userDescription(text, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                success()
            }
            }, failure: { (operation, error) -> Void in
                //failure(error)
        })
    }
    
    func forgot(_ text: String, success:@escaping () -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "user/forgot"
        
        let params: [AnyHashable: Any] = [ "id" : text ]
        
        manager?.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.forgot(text, success: success, failure: failure)
                        }, failure: { () -> () in
                            failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                success()
            }
            }, failure: { (operation, error) -> Void in
            //failure(error)
        })
    }
    
    func password(_ text: String, success:@escaping () -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "user/password"
        
        var params = self.sessionParams()
        params!["password"] = text as AnyObject?
        
        manager?.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.password(text, success: success, failure: failure)
                        }, failure: { () -> () in
                            failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                success()
            }
            }, failure: { (operation, error) -> Void in
            //failure(error)
        })
    }
    
    fileprivate func usersList(_ path: String, data: NSDictionary, success: @escaping (_ users: [User]) -> (), failure: @escaping (_ error: NSError) -> ()) {
        let responseMapping = UserMappingProvider.userResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.successful)
        
        let userResponseDescriptor = RKResponseDescriptor(mapping: responseMapping, method:.GET, pathPattern: nil, keyPath: "data.users", statusCodes: statusCode)
        manager?.addResponseDescriptor(userResponseDescriptor)
        
        var params=self.sessionParams()
        
        if let id=data.value(forKey:"id")
        {
            params!["id"]=id as AnyObject
        }
        if let page=data.value(forKey:"p")
        {
            params!["p"]=page as AnyObject
        }
        if let query=data.value(forKey:"q")
        {
            params!["q"]=query as AnyObject
        }
        
        manager?.getObjectsAtPath(path, parameters: params, success: { (operation, mappingResult) -> Void in
            // success code
            let error:Error = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.usersList(path, data: data, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                let users = mappingResult?.dictionary()["data.users"] as! [User]
                success(users)
            }
            }, failure:{ (operation, error) -> Void in
                //failure(error)
        })
    }
}
