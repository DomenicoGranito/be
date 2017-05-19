//
//  StreamConnector.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class StreamConnector: Connector {
    
    func cities(_ success: @escaping (_ cities: [String]) -> (), failure: @escaping (_ error:NSError) -> ()) {
        let path = "stream/cities"
        
        let mapping = StreamMappingProvider.cityResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.successful)
        
        let responseDescriptor = RKResponseDescriptor(mapping: mapping, method:.GET, pathPattern: nil, keyPath: "data.cities", statusCodes: statusCode)
        
        manager?.addResponseDescriptor(responseDescriptor)
        
        manager?.getObjectsAtPath(path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status
            {
                if error.code == Error.kLoginExpiredCode
                {
                    self.relogin({ () -> () in
                        self.cities(success, failure: failure)
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
            //failure(error)
        })
    }
    
    func categories(_ success: @escaping (_ cats: [Category]) -> (), failure: @escaping (_ error: NSError) -> ()) {
   
    //let path = "stream/categories"
        let path = "category/categories"
        
        let mapping = CategoryMappingProvider.categoryResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.successful)
        
        let responseDescriptor = RKResponseDescriptor(mapping: mapping, method:.GET, pathPattern: nil, keyPath: "data.categories", statusCodes: statusCode)
        
        manager?.addResponseDescriptor(responseDescriptor)
        
        manager?.getObjectsAtPath(path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            // success code
            let error:Error = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.categories(success, failure: failure)
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
            //failure(error)
        })
    }
    
    func streams(_ getGlobal: Bool, success: @escaping (_ live: [Stream], _ recent: [Stream]) -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = (getGlobal) ? "stream/global" : "stream/followed"
        
        let streamMapping = StreamMappingProvider.streamResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.successful)
        
        let liveStreamResponseDescriptor = RKResponseDescriptor(mapping: streamMapping, method:.GET, pathPattern: nil, keyPath: "data.live", statusCodes: statusCode)
        
        let recentStreamResponseDescriptor = RKResponseDescriptor(mapping: streamMapping, method: RKRequestMethod.GET, pathPattern: nil, keyPath: "data.recent", statusCodes: statusCode)
        
        manager?.addResponseDescriptor(liveStreamResponseDescriptor)
        manager?.addResponseDescriptor(recentStreamResponseDescriptor)
        
        manager?.getObjectsAtPath(path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            // success code
            let error:Error = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.streams(getGlobal, success: success, failure: failure)
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
            //failure(error)
        })
    }
    
    /*** WRITTEN BY ANKIT GARG ***/
    
    func discover(_ success:@escaping (_ data:NSDictionary)->(), failure:@escaping (_ error:NSError)->())
    {
        let path="category/discover"
        
        manager?.getObjectsAtPath(path, parameters:sessionParams(), success:{ (operation, mappingResult)->Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status
            {
                if error.code==Error.kLoginExpiredCode
                {
                    self.relogin({()->() in
                        self.discover(success, failure:failure)
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
            //failure(error)
        })
    }
    
    func homeStreams(_ success:@escaping (_ data:NSDictionary)->(), failure:@escaping (_ error:NSError)->())
    {
        let path="category/streams"
        
        manager?.getObjectsAtPath(path, parameters:sessionParams(), success:{ (operation, mappingResult)->Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status
            {
                if error.code==Error.kLoginExpiredCode
                {
                    self.relogin({()->() in
                        self.homeStreams(success, failure:failure)
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
            //failure(error)
        })
    }
    
    func categoryStreams(_ categoryID:Int, pageID:Int, success:@escaping (_ data:NSDictionary)->(), failure:@escaping (_ error:NSError)->())
    {
        let path="category/streamscategory?c=\(categoryID)&p=\(pageID)"
        
        manager?.getObjectsAtPath(path, parameters:sessionParams(), success:{ (operation, mappingResult)->Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status
            {
                if error.code==Error.kLoginExpiredCode
                {
                    self.relogin({()->() in
                        self.categoryStreams(categoryID, pageID:pageID, success:success, failure:failure)
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
            //failure(error)
        })
    }
    
    func search(_ query:String, success:@escaping (_ brands:[User], _ agencies:[User], _ venues:[User], _ talents:[User], _ profiles:[User], _ streams:[Stream])->(), failure:@escaping (_ error:NSError)->())
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
        
        manager?.addResponseDescriptor(brandsResponseDescriptor)
        manager?.addResponseDescriptor(agenciesResponseDescriptor)
        manager?.addResponseDescriptor(venuesResponseDescriptor)
        manager?.addResponseDescriptor(talentsResponseDescriptor)
        manager?.addResponseDescriptor(profilesResponseDescriptor)
        manager?.addResponseDescriptor(streamsResponseDescriptor)
        
        manager?.getObjectsAtPath(path, parameters:sessionParams(), success:{(operation, mappingResult)->Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status
            {
                if error.code == Error.kLoginExpiredCode
                {
                    self.relogin({()->() in
                        self.search(query, success:success, failure:failure)
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
            //failure(error)
        })
    }
    
    func searchMoreStreams(_ query:String, success:@escaping (_ streams:[Stream])->(), failure:@escaping (_ error:NSError)->())
    {
        let path="stream/searchmore?q=\(query)&t=streams"
        
        let streamMapping=StreamMappingProvider.streamResponseMapping()
        
        let statusCode=RKStatusCodeIndexSetForClass(.successful)
        
        let streamsResponseDescriptor=RKResponseDescriptor(mapping:streamMapping, method:.GET, pathPattern:nil, keyPath:"data.streams", statusCodes:statusCode)
        
        manager?.addResponseDescriptor(streamsResponseDescriptor)
        
        manager?.getObjectsAtPath(path, parameters:sessionParams(), success:{(operation, mappingResult)->Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status
            {
                if error.code == Error.kLoginExpiredCode
                {
                    self.relogin({()->() in
                        self.searchMoreStreams(query, success:success, failure:failure)
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
                                    //failure(error)
        })
    }

    func searchMoreOthers(_ query:String, identifier:String, success:@escaping (_ users:[User])->(), failure:@escaping (_ error:NSError)->())
    {
        let path="stream/searchmore?q=\(query)&t=\(identifier)"
        
        let userMapping=UserMappingProvider.userResponseMapping()
        
        let statusCode=RKStatusCodeIndexSetForClass(.successful)
        
        let usersResponseDescriptor=RKResponseDescriptor(mapping:userMapping, method:.GET, pathPattern:nil, keyPath:"data.\(identifier)", statusCodes:statusCode)
        
        manager?.addResponseDescriptor(usersResponseDescriptor)
        
        manager?.getObjectsAtPath(path, parameters:sessionParams(), success:{(operation, mappingResult)->Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status
            {
                if error.code == Error.kLoginExpiredCode
                {
                    self.relogin({()->() in
                        self.searchMoreOthers(query, identifier:identifier, success:success, failure:failure)
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
            //failure(error)
        })
    }

    /*** WRITTEN BY ANKIT GARG ***/
    
    func recent(_ userId: UInt, success: @escaping (_ streams: [Stream]) -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = ("stream/recent" as NSString).appendingPathComponent("\(userId)")
        
        let streamMapping = StreamMappingProvider.streamResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.successful)
        
        let responseDescriptor = RKResponseDescriptor(mapping: streamMapping, method:.GET, pathPattern: nil, keyPath: "data.recent", statusCodes: statusCode)
        
        manager?.addResponseDescriptor(responseDescriptor)
        
        manager?.getObjectsAtPath(path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            // success code
            let error:Error = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.recent(userId, success: success, failure: failure)
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
                //failure(error)
        })
    }
    
    func my(_ success: @escaping (_ streams: [Stream]) -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "stream/my"
        
        let streamMapping = StreamMappingProvider.streamResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.successful)
        
        let responseDescriptor = RKResponseDescriptor(mapping: streamMapping, method:.GET, pathPattern: nil, keyPath: "data.streams", statusCodes: statusCode)
        
        manager?.addResponseDescriptor(responseDescriptor)
        
        manager?.getObjectsAtPath(path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            // success code
            let error:Error = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.my(success, failure: failure)
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
                //failure(error)
        })
    }
    
    func create(_ data: NSDictionary, success: @escaping (_ stream: Stream) -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "stream/create"
        
        let requestMapping  = StreamMappingProvider.createStreamRequestMapping()
        let streamMapping   = StreamMappingProvider.streamResponseMapping()
        
        let requestDescriptor = RKRequestDescriptor(mapping: requestMapping, objectClass: NSDictionary.self, rootKeyPath: nil, method:.POST)
        manager?.addRequestDescriptor(requestDescriptor)

        let statusCode = RKStatusCodeIndexSetForClass(.successful)
        let streamResponseDescriptor = RKResponseDescriptor(mapping: streamMapping, method:.POST, pathPattern: nil, keyPath: "data", statusCodes: statusCode)
        
        manager?.addResponseDescriptor(streamResponseDescriptor)
        
        manager?.post(data, path: path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            // success code
            let error:Error = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.create(data, success: success, failure: failure)
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
                //failure(error)
        })
    }
    
    func createWithFile(_ filename: String, fileData: NSData, data: NSDictionary, success: @escaping (_ stream: Stream) -> (), failure: @escaping (_ error:NSError) -> ()) {
        let path = "stream/create"
        
        let requestMapping  = StreamMappingProvider.createStreamRequestMapping()
        let streamMapping   = StreamMappingProvider.streamResponseMapping()
        
        let requestDescriptor = RKRequestDescriptor(mapping: requestMapping, objectClass: NSDictionary.self, rootKeyPath: nil, method:.POST)
        manager?.addRequestDescriptor(requestDescriptor)
        
        let statusCode = RKStatusCodeIndexSetForClass(.successful)
        let streamResponseDescriptor = RKResponseDescriptor(mapping: streamMapping, method:.POST, pathPattern: nil, keyPath: "data", statusCodes: statusCode)
        
        manager?.addResponseDescriptor(streamResponseDescriptor)
        
        let request =
        manager?.multipartFormRequest(with:data, method:.POST, path: path, parameters:self.sessionParams())
        { (formData) -> Void in
            formData?.appendPart(withFileData: fileData as Data, name: "image", fileName: filename, mimeType: "image/jpeg")
        }
        
        let operation = manager?.objectRequestOperation(with: request as URLRequest!, success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.createWithFile(filename, fileData: fileData, data: data, success: success, failure: failure)
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
            //failure(error)
        })
        
        manager?.enqueue(operation)
    }
    
    func del(_ streamId: UInt, success: @escaping () -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "stream/delete"
        
        var params = self.sessionParams()
        params!["id"] = streamId as AnyObject?
        
        manager?.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            // success code
            let error:Error = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.del(streamId, success: success, failure: failure)
                        }, failure: { () -> () in
                            failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }            } else {
                success()
            }
            }, failure:{ (operation, error) -> Void in
            //failure(error)
        })
    }

    
    func close(_ streamId: UInt, success: @escaping () -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "stream/close"
        
        var params = self.sessionParams()
        params!["id"] = streamId as AnyObject?
        
        manager?.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            // success code
            let error:Error = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.close(streamId, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }            } else {
                success()
            }
            }, failure: { (operation, error) -> Void in
                //failure(error)
        })
    }
    
    func join(_ streamId: UInt, success: @escaping () -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "stream/join"
        
        var params = self.sessionParams()
        params!["id"] = streamId as AnyObject?
        
        manager?.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.join(streamId, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }            } else {
                success()
            }
            }, failure:{ (operation, error) -> Void in
            //failure(error)
        })
    }
    
    func leave(_ streamId: UInt, likes: UInt, success: @escaping () -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "stream/leave"
        
        var params = self.sessionParams()
        params!["id"] = streamId as AnyObject?
        params!["likes"] = likes as AnyObject?
        
        manager?.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.leave(streamId, likes: likes, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }            } else {
                success()
            }
            }, failure: { (operation, error) -> Void in
                //failure(error)
        })
    }
    
    func viewers(_ data: NSDictionary, success: @escaping (_ likes: UInt, _ viewers: UInt, _ users: [User]) -> (), failure: @escaping (_ error: NSError) -> ()) {
        let streamId = data["streamId"] as! UInt
        let path = ("stream/viewers" as NSString).appendingPathComponent("\(streamId)")
        
        let streamMapping = StreamMappingProvider.viewersResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.successful)
        
        let streamResponseDescriptor = RKResponseDescriptor(mapping: streamMapping, method:.GET, pathPattern: nil, keyPath: "data", statusCodes: statusCode)
        
        manager?.addResponseDescriptor(streamResponseDescriptor)
        
        var params = self.sessionParams()
        if let page: UInt = (data["p"] as? UInt) {
            params!["p"] = page as AnyObject?
        }
        
        manager?.getObjectsAtPath(path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.viewers(data, success: success, failure: failure)
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
            //failure(error)
        })
    }
    
    func replayViewers(_ data: NSDictionary, success: @escaping (_ likes: UInt, _ viewers: UInt, _ users: [User]) -> (), failure: @escaping (_ error: NSError) -> ()) {
        let streamId = data["streamId"] as! UInt
        let path = ("stream/rviewers" as NSString).appendingPathComponent("\(streamId)")
        
        let streamMapping = StreamMappingProvider.viewersResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.successful)
        
        let streamResponseDescriptor = RKResponseDescriptor(mapping: streamMapping, method:.GET, pathPattern: nil, keyPath: "data", statusCodes: statusCode)
        
        manager?.addResponseDescriptor(streamResponseDescriptor)
        
        var params = self.sessionParams()
        if let page: UInt = (data["p"] as? UInt) {
            params!["p"] = page as AnyObject?
        }
        
        manager?.getObjectsAtPath(path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.replayViewers(data, success: success, failure: failure)
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
                //failure(error)
        })
    }
    
    func get(_ streamId: UInt, success: @escaping (_ stream: Stream) -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = ("stream" as NSString).appendingPathComponent("\(streamId)")
        
        let streamMapping = StreamMappingProvider.streamResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.successful)
        
        let streamResponseDescriptor = RKResponseDescriptor(mapping: streamMapping, method:.GET, pathPattern: nil, keyPath: "data", statusCodes: statusCode)
        
        manager?.addResponseDescriptor(streamResponseDescriptor)
        
        manager?.getObjectsAtPath(path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.get(streamId, success: success, failure: failure)
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
                //failure(error)
        })
    }    
    
    func report(_ streamId: UInt, success: @escaping () -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "stream/report"
        
        var params = self.sessionParams()
        params!["id"] = streamId as AnyObject?
        
        manager?.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.report(streamId, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }            } else {
                success()
            }
            }) { (operation, error) -> Void in
                //failure(error)
        }
    }
    
    func share(_ streamId: UInt, usersId: [UInt]?, success: @escaping () -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "stream/share"
        
        var params = self.sessionParams()
        params!["id"] = streamId as AnyObject?
        
        if let users = usersId {
            params!["users"] = users as AnyObject?
        }
        
        manager?.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.share(streamId, usersId: usersId, success: success, failure: failure)
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
    
    func ping(_ streamId: UInt, success: @escaping () -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "stream/ping"
        
        var params = self.sessionParams()
        params!["id"] = streamId as AnyObject?
        
        manager?.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.ping(streamId, success: success, failure: failure)
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
                //failure(error)
        })
    }
}
