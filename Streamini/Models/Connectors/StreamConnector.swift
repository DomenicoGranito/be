//
//  StreamConnector.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class StreamConnector: Connector
{
    func cities(_ success: @escaping (_ cities: [String]) -> (), _ failure: @escaping (_ error:NSError) -> ())
    {
        let path = "stream/cities"
        
        let mapping = StreamMappingProvider.cityResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.successful)
        
        let responseDescriptor = RKResponseDescriptor(mapping: mapping, method:.GET, pathPattern: nil, keyPath: "data.cities", statusCodes: statusCode)
        
        manager.addResponseDescriptor(responseDescriptor)
        
        manager.getObjectsAtPath(path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status
            {
                if error.code == CustomError.kLoginExpiredCode
                {
                    self.relogin({ () -> () in
                        self.cities(success, failure)
                        },
                                 failure:{ () -> () in
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
                let cs = mappingResult?.dictionary()["data.cities"] as! [NSDictionary]
                var cities: [String] = []
                for c in cs {
                    cities.append(c["name"] as! String)
                }
                success(cities)
            }
        }, failure:{(operation, error)->Void in
            failure(error as! NSError)
        })
    }
    
    func categories(_ success: @escaping (_ cats: [Category]) -> (), _ failure: @escaping (_ error: NSError) -> ())
    {
        let path = "category/categories"
        
        let mapping = CategoryMappingProvider.categoryResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.successful)
        
        let responseDescriptor = RKResponseDescriptor(mapping: mapping, method:.GET, pathPattern: nil, keyPath: "data.categories", statusCodes: statusCode)
        
        manager.addResponseDescriptor(responseDescriptor)
        
        manager.getObjectsAtPath(path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status {
                if error.code == CustomError.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.categories(success, failure)
                        }, failure: { () -> () in
                            failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                let cats = mappingResult?.dictionary()["data.categories"] as! [Category]
                success(cats)
            }
        }, failure:{(operation, error) in
            failure(error as! NSError)
        })
    }
    
    func streams(_ getGlobal: Bool, _ success: @escaping (_ live: [Stream], _ recent: [Stream]) -> (), _ failure: @escaping (_ error: NSError) -> ())
    {
        let path = (getGlobal) ? "stream/global" : "stream/followed"
        
        let streamMapping = StreamMappingProvider.streamResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.successful)
        
        let liveStreamResponseDescriptor = RKResponseDescriptor(mapping: streamMapping, method:.GET, pathPattern: nil, keyPath: "data.live", statusCodes: statusCode)
        
        let recentStreamResponseDescriptor = RKResponseDescriptor(mapping: streamMapping, method: RKRequestMethod.GET, pathPattern: nil, keyPath: "data.recent", statusCodes: statusCode)
        
        manager.addResponseDescriptor(liveStreamResponseDescriptor)
        manager.addResponseDescriptor(recentStreamResponseDescriptor)
        
        manager.getObjectsAtPath(path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status {
                if error.code == CustomError.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.streams(getGlobal, success, failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                var live: [Stream] = []
                if let l: AnyObject = mappingResult?.dictionary()["data.live"] as AnyObject? {
                    live = l as! [Stream]
                }
                
                var recent: [Stream] = []
                if let r: AnyObject = mappingResult?.dictionary()["data.recent"] as AnyObject? {
                    recent = r as! [Stream]
                }

                success(live, recent)
            }
            }, failure:{(operation, error) in
            failure(error as! NSError)
        })
    }
    
    func discover(_ success:@escaping (_ data:NSDictionary)->(), _ failure:@escaping (_ error:NSError)->())
    {
        let path="category/discover"
        
        manager.getObjectsAtPath(path, parameters:sessionParams(), success:{ (operation, mappingResult)->Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status
            {
                if error.code==CustomError.kLoginExpiredCode
                {
                    self.relogin({()->() in
                        self.discover(success, failure)
                        },
                        failure:{()->() in
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
                let json=try! JSONSerialization.jsonObject(with: (operation?.httpRequestOperation.responseData)!, options:.mutableLeaves) as! NSDictionary
                
                success(json)
            }
            }, failure:{(operation, error) in
            failure(error as! NSError)
        })
    }
    
    func homeStreams(_ success:@escaping (_ data:NSDictionary)->(), _ failure:@escaping (_ error:NSError)->())
    {
        let path="category/streams"
        
        manager.getObjectsAtPath(path, parameters:sessionParams(), success:{ (operation, mappingResult)->Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status
            {
                if error.code==CustomError.kLoginExpiredCode
                {
                    self.relogin({()->() in
                        self.homeStreams(success, failure)
                        },
                        failure:{()->() in
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
                let json=try! JSONSerialization.jsonObject(with: (operation?.httpRequestOperation.responseData)!, options:.mutableLeaves) as! NSDictionary
                
                success(json)
            }
            },
            failure:{(operation, error) in
            failure(error as! NSError)
        })
    }
    
    func categoryStreams(_ isSubCategory:Bool, _ categoryID:Int, _ pageID:Int, _ success:@escaping (_ data:NSDictionary)->(), _ failure:@escaping (_ error:NSError)->())
    {
        var path=""
        
        if isSubCategory
        {
            path="category/streamssubcategory?c=\(categoryID)&p=\(pageID)"
        }
        else
        {
            path="category/streamscategory?c=\(categoryID)&p=\(pageID)"
        }
        
        manager.getObjectsAtPath(path, parameters:sessionParams(), success:{ (operation, mappingResult)->Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status
            {
                if error.code==CustomError.kLoginExpiredCode
                {
                    self.relogin({()->() in
                        self.categoryStreams(isSubCategory, categoryID, pageID, success, failure)
                        },
                        failure:{()->() in
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
                let json=try! JSONSerialization.jsonObject(with: (operation?.httpRequestOperation.responseData)!, options:.mutableLeaves) as! NSDictionary
                
                success(json)
            }
            },
        failure:{(operation, error)->Void in
            failure(error as! NSError)
        })
    }
    
    func search(_ query:String, _ success:@escaping (_ brands:[User], _ agencies:[User], _ venues:[User], _ talents:[User], _ profiles:[User], _ streams:[Stream])->(), _ failure:@escaping (_ error:NSError)->())
    {
        let path="stream/search?q=\(query)"
        
        let userMapping=UserMappingProvider.userResponseMapping()
        let streamMapping=StreamMappingProvider.streamResponseMapping()
        
        let statusCode=RKStatusCodeIndexSetForClass(.successful)
        
        let brandsResponseDescriptor=RKResponseDescriptor(mapping:userMapping, method:.GET, pathPattern:nil, keyPath:"data.brands", statusCodes:statusCode)
        let agenciesResponseDescriptor=RKResponseDescriptor(mapping:userMapping, method:.GET, pathPattern:nil, keyPath:"data.agencies", statusCodes:statusCode)
        let venuesResponseDescriptor=RKResponseDescriptor(mapping:userMapping, method:.GET, pathPattern:nil, keyPath:"data.venues", statusCodes:statusCode)
        let talentsResponseDescriptor=RKResponseDescriptor(mapping:userMapping, method:.GET, pathPattern:nil, keyPath:"data.talents", statusCodes:statusCode)
        let profilesResponseDescriptor=RKResponseDescriptor(mapping:userMapping, method:.GET, pathPattern:nil, keyPath:"data.profiles", statusCodes:statusCode)
        let streamsResponseDescriptor=RKResponseDescriptor(mapping:streamMapping, method:.GET, pathPattern:nil, keyPath:"data.streams", statusCodes:statusCode)
        
        manager.addResponseDescriptor(brandsResponseDescriptor)
        manager.addResponseDescriptor(agenciesResponseDescriptor)
        manager.addResponseDescriptor(venuesResponseDescriptor)
        manager.addResponseDescriptor(talentsResponseDescriptor)
        manager.addResponseDescriptor(profilesResponseDescriptor)
        manager.addResponseDescriptor(streamsResponseDescriptor)
        
        manager.getObjectsAtPath(path, parameters:sessionParams(), success:{(operation, mappingResult)->Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status
            {
                if error.code==CustomError.kLoginExpiredCode
                {
                    self.relogin({()->() in
                        self.search(query, success, failure)
                        },
                        failure:{()->() in
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
                let brands=mappingResult?.dictionary()["data.brands"] as! [User]
                let agencies=mappingResult?.dictionary()["data.agencies"] as! [User]
                let venues=mappingResult?.dictionary()["data.venues"] as! [User]
                let talents=mappingResult?.dictionary()["data.talents"] as! [User]
                let profiles=mappingResult?.dictionary()["data.profiles"] as! [User]
                let streams=mappingResult?.dictionary()["data.streams"] as! [Stream]
                
                success(brands, agencies, venues, talents, profiles, streams)
            }
            },
        failure:{(operation, error) in
            failure(error as! NSError)
        })
    }
    
    func searchMoreStreams(_ query:String, _ success:@escaping (_ streams:[Stream])->(), _ failure:@escaping (_ error:NSError)->())
    {
        let path="stream/searchmore?q=\(query)&t=streams"
        
        let streamMapping=StreamMappingProvider.streamResponseMapping()
        
        let statusCode=RKStatusCodeIndexSetForClass(.successful)
        
        let streamsResponseDescriptor=RKResponseDescriptor(mapping:streamMapping, method:.GET, pathPattern:nil, keyPath:"data.streams", statusCodes:statusCode)
        
        manager.addResponseDescriptor(streamsResponseDescriptor)
        
        manager.getObjectsAtPath(path, parameters:sessionParams(), success:{(operation, mappingResult)->Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status
            {
                if error.code==CustomError.kLoginExpiredCode
                {
                    self.relogin({()->() in
                        self.searchMoreStreams(query, success, failure)
                        },
                        failure:{()->() in
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
                let streams=mappingResult?.dictionary()["data.streams"] as! [Stream]
                
                success(streams)
            }
            }, failure:{(operation, error)->Void in
                failure(error as! NSError)
        })
    }

    func searchMoreOthers(_ query:String, _ identifier:String, _ success:@escaping (_ users:[User])->(), _ failure:@escaping (_ error:NSError)->())
    {
        let path="stream/searchmore?q=\(query)&t=\(identifier)"
        
        let userMapping=UserMappingProvider.userResponseMapping()
        
        let statusCode=RKStatusCodeIndexSetForClass(.successful)
        
        let usersResponseDescriptor=RKResponseDescriptor(mapping:userMapping, method:.GET, pathPattern:nil, keyPath:"data.\(identifier)", statusCodes:statusCode)
        
        manager.addResponseDescriptor(usersResponseDescriptor)
        
        manager.getObjectsAtPath(path, parameters:sessionParams(), success:{(operation, mappingResult)->Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status
            {
                if error.code==CustomError.kLoginExpiredCode
                {
                    self.relogin({()->() in
                        self.searchMoreOthers(query, identifier, success, failure)
                        },
                        failure:{()->() in
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
                let users=mappingResult?.dictionary()["data.\(identifier)"] as! [User]
                
                success(users)
            }
            },
        failure:{(operation, error)->Void in
            failure(error as! NSError)
        })
    }

    func recent(_ userId: UInt, _ success: @escaping (_ streams: [Stream]) -> (), _ failure: @escaping (_ error: NSError) -> ())
    {
        let path = ("stream/recent" as NSString).appendingPathComponent("\(userId)")
        
        let streamMapping = StreamMappingProvider.streamResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.successful)
        
        let responseDescriptor = RKResponseDescriptor(mapping: streamMapping, method:.GET, pathPattern: nil, keyPath: "data.recent", statusCodes: statusCode)
        
        manager.addResponseDescriptor(responseDescriptor)
        
        manager.getObjectsAtPath(path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status {
                if error.code==CustomError.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.recent(userId, success, failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                let streams = mappingResult?.dictionary()["data.recent"] as! [Stream]                
                success(streams)
            }
            }, failure:{ (operation, error) -> Void in
                failure(error as! NSError)
        })
    }
    
    func my(_ success: @escaping (_ streams: [Stream]) -> (), _ failure: @escaping (_ error: NSError) -> ())
    {
        let path = "stream/my"
        
        let streamMapping = StreamMappingProvider.streamResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.successful)
        
        let responseDescriptor = RKResponseDescriptor(mapping: streamMapping, method:.GET, pathPattern: nil, keyPath: "data.streams", statusCodes: statusCode)
        
        manager.addResponseDescriptor(responseDescriptor)
        
        manager.getObjectsAtPath(path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status {
                if error.code==CustomError.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.my(success, failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                let streams = mappingResult?.dictionary()["data.streams"] as! [Stream]
                success(streams)
            }
            }, failure: { (operation, error) in
                failure(error as! NSError)
        })
    }
    
    func create(_ data: NSDictionary, _ success: @escaping (_ stream: Stream) -> (), _ failure: @escaping (_ error: NSError) -> ())
    {
        let path = "stream/create"
        
        let requestMapping  = StreamMappingProvider.createStreamRequestMapping()
        let streamMapping   = StreamMappingProvider.streamResponseMapping()
        
        let requestDescriptor = RKRequestDescriptor(mapping: requestMapping, objectClass: NSDictionary.self, rootKeyPath: nil, method:.POST)
        manager.addRequestDescriptor(requestDescriptor)

        let statusCode = RKStatusCodeIndexSetForClass(.successful)
        let streamResponseDescriptor = RKResponseDescriptor(mapping: streamMapping, method:.POST, pathPattern: nil, keyPath: "data", statusCodes: statusCode)
        
        manager.addResponseDescriptor(streamResponseDescriptor)
        
        manager.post(data, path: path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
           
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status {
                if error.code==CustomError.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.create(data, success, failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                let stream = mappingResult?.dictionary()["data"] as! Stream
                success(stream)
            }
            }, failure:{ (operation, error) -> Void in
                failure(error as! NSError)
        })
    }
    
    func createWithFile(_ filename: String, _ fileData: NSData, _ data: NSDictionary, _ success: @escaping (_ stream: Stream) -> (), _ failure: @escaping (_ error:NSError) -> ())
    {
        let path = "stream/create"
        
        let requestMapping  = StreamMappingProvider.createStreamRequestMapping()
        let streamMapping   = StreamMappingProvider.streamResponseMapping()
        
        let requestDescriptor = RKRequestDescriptor(mapping: requestMapping, objectClass: NSDictionary.self, rootKeyPath: nil, method:.POST)
        manager.addRequestDescriptor(requestDescriptor)
        
        let statusCode = RKStatusCodeIndexSetForClass(.successful)
        let streamResponseDescriptor = RKResponseDescriptor(mapping: streamMapping, method:.POST, pathPattern: nil, keyPath: "data", statusCodes: statusCode)
        
        manager.addResponseDescriptor(streamResponseDescriptor)
        
        let request =
        manager.multipartFormRequest(with:data, method:.POST, path: path, parameters:self.sessionParams())
        { (formData) -> Void in
            formData?.appendPart(withFileData: fileData as Data, name: "image", fileName: filename, mimeType: "image/jpeg")
        }
        
        let operation = manager.objectRequestOperation(with: request as URLRequest!, success: { (operation, mappingResult) -> Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status {
                if error.code==CustomError.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.createWithFile(filename, fileData, data, success, failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                let stream = mappingResult?.dictionary()["data"] as! Stream
                success(stream)
            }
        },
        failure:{(operation, error)->Void in
            failure(error as! NSError)
        })
        
        manager.enqueue(operation)
    }
    
    func del(_ streamId: UInt, _ success: @escaping () -> (), _ failure: @escaping (_ error: NSError) -> ())
    {
        let path = "stream/delete"
        
        var params = self.sessionParams()
        params!["id"] = streamId as AnyObject?
        
        manager.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status {
                if error.code==CustomError.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.del(streamId, success, failure)
                        }, failure: { () -> () in
                            failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }            } else {
                success()
            }
            }, failure:{ (operation, error) -> Void in
            failure(error as! NSError)
        })
    }

    
    func close(_ streamId: UInt, _ success: @escaping () -> (), _ failure: @escaping (_ error: NSError) -> ())
    {
        let path = "stream/close"
        
        var params = self.sessionParams()
        params!["id"] = streamId as AnyObject?
        
        manager.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
        
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status {
                if error.code==CustomError.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.close(streamId, success, failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }            } else {
                success()
            }
            }, failure: { (operation, error) -> Void in
                failure(error as! NSError)
        })
    }
    
    func join(_ streamId: UInt, _ success: @escaping () -> (), _ failure: @escaping (_ error: NSError) -> ())
    {
        let path = "stream/join"
        
        var params = self.sessionParams()
        params!["id"] = streamId as AnyObject?
        
        manager.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status {
                if error.code==CustomError.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.join(streamId, success, failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }            } else {
                success()
            }
            }, failure:{ (operation, error) -> Void in
            failure(error as! NSError)
        })
    }
    
    func leave(_ streamId: UInt, _ likes: UInt, _ success: @escaping () -> (), _ failure: @escaping (_ error: NSError) -> ())
    {
        let path = "stream/leave"
        
        var params = self.sessionParams()
        params!["id"] = streamId as AnyObject?
        params!["likes"] = likes as AnyObject?
        
        manager.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status {
                if error.code==CustomError.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.leave(streamId, likes, success, failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }            } else {
                success()
            }
            }, failure: { (operation, error) -> Void in
                failure(error as! NSError)
        })
    }
    
    func viewers(_ data: NSDictionary, _ success: @escaping (_ likes: UInt, _ viewers: UInt, _ users: [User]) -> (), _ failure: @escaping (_ error: NSError) -> ())
    {
        let streamId = data["streamId"] as! UInt
        let path = ("stream/viewers" as NSString).appendingPathComponent("\(streamId)")
        
        let streamMapping = StreamMappingProvider.viewersResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.successful)
        
        let streamResponseDescriptor = RKResponseDescriptor(mapping: streamMapping, method:.GET, pathPattern: nil, keyPath: "data", statusCodes: statusCode)
        
        manager.addResponseDescriptor(streamResponseDescriptor)
        
        var params = self.sessionParams()
        if let page: UInt = (data["p"] as? UInt) {
            params!["p"] = page as AnyObject?
        }
        
        manager.getObjectsAtPath(path, parameters: params, success: { (operation, mappingResult) -> Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status {
                if error.code==CustomError.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.viewers(data, success, failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }            } else {
                let data = mappingResult?.dictionary()["data"] as! NSDictionary
                let likes: UInt     = data["likes"] as! UInt
                let viewers: UInt   = data["viewers"] as! UInt
                let users:[User]    = data["users"] as! [User]
                success(likes, viewers, users)
            }
            }, failure:{ (operation, error) -> Void in
            failure(error as! NSError)
        })
    }
    
    func replayViewers(_ data: NSDictionary, _ success: @escaping (_ likes: UInt, _ viewers: UInt, _ users: [User]) -> (), _ failure: @escaping (_ error: NSError) -> ())
    {
        let streamId = data["streamId"] as! UInt
        let path = ("stream/rviewers" as NSString).appendingPathComponent("\(streamId)")
        
        let streamMapping = StreamMappingProvider.viewersResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.successful)
        
        let streamResponseDescriptor = RKResponseDescriptor(mapping: streamMapping, method:.GET, pathPattern: nil, keyPath: "data", statusCodes: statusCode)
        
        manager.addResponseDescriptor(streamResponseDescriptor)
        
        var params = self.sessionParams()
        if let page: UInt = (data["p"] as? UInt) {
            params!["p"] = page as AnyObject?
        }
        
        manager.getObjectsAtPath(path, parameters: params, success: { (operation, mappingResult) -> Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status {
                if error.code==CustomError.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.replayViewers(data, success, failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }            } else {
                let data = mappingResult?.dictionary()["data"] as! NSDictionary
                let likes: UInt     = data["likes"] as! UInt
                let viewers: UInt   = data["viewers"] as! UInt
                let users:[User]    = data["users"] as! [User]
                success(likes, viewers, users)
            }
            }, failure: { (operation, error) -> Void in
                failure(error as! NSError)
        })
    }
    
    func get(_ streamId: UInt, _ success: @escaping (_ stream: Stream) -> (), _ failure: @escaping (_ error: NSError) -> ()) {
        let path = ("stream" as NSString).appendingPathComponent("\(streamId)")
        
        let streamMapping = StreamMappingProvider.streamResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.successful)
        
        let streamResponseDescriptor = RKResponseDescriptor(mapping: streamMapping, method:.GET, pathPattern: nil, keyPath: "data", statusCodes: statusCode)
        
        manager.addResponseDescriptor(streamResponseDescriptor)
        
        manager.getObjectsAtPath(path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status {
                if error.code==CustomError.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.get(streamId, success, failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }            } else {
                let stream = mappingResult?.dictionary()["data"] as! Stream
                success(stream)
            }
            }, failure: { (operation, error) -> Void in
                failure(error as! NSError)
        })
    }    
    
    func report(_ streamId: UInt, _ success: @escaping () -> (), _ failure: @escaping (_ error: NSError) -> ()) {
        let path = "stream/report"
        
        var params = self.sessionParams()
        params!["id"] = streamId as AnyObject?
        
        manager.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status {
                if error.code==CustomError.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.report(streamId, success, failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }            } else {
                success()
            }
            }) { (operation, error) -> Void in
                failure(error as! NSError)
        }
    }
    
    func share(_ streamId:UInt, _ usersId:[UInt]?, _ success:@escaping () -> (), _ failure: @escaping (_ error: NSError) -> ())
    {
        let path = "stream/share"
        
        var params = self.sessionParams()
        params!["id"] = streamId as AnyObject?
        
        if let users = usersId {
            params!["users"] = users as AnyObject?
        }
        
        manager.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status {
                if error.code==CustomError.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.share(streamId, usersId, success, failure)
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
            failure(error as! NSError)
        })
    }
    
    func ping(_ streamId: UInt, _ success: @escaping () -> (), _ failure: @escaping (_ error: NSError) -> ()) {
        let path = "stream/ping"
        
        var params = self.sessionParams()
        params!["id"] = streamId as AnyObject?
        
        manager.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status {
                if error.code==CustomError.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.ping(streamId, success, failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                success()
            }
            },
            failure:{(operation, error)->Void in
                failure(error as! NSError)
        })
    }
}
