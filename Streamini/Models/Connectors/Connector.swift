//
//  Connector.swift
//  Test
//
//  Created by Vasily Evreinov on 1/27/15.
//  Copyright (c) 2015 Direct Invent. All rights reserved.
//

class Connector: NSObject
{
    var manager=RKObjectManager(baseURL:Connector.baseUrl())!
    var errorDescriptor:RKResponseDescriptor?
    
    class func baseUrl()->URL
    {
        let (host)=Config.shared.api()
        return URL(string:host)!
    }
    
    override init ()
    {
        super.init()
        manager.requestSerializationMIMEType = RKMIMETypeFormURLEncoded
        addErrorResponseDescriptor()
    }
    
    func sessionParams()->[String:AnyObject]?
    {
        if let session=A0SimpleKeychain().string(forKey:"PHPSESSID")
        {
            return ["PHPSESSID":session as AnyObject]
        }
        else
        {
            return nil
        }
    }
    
    func loginData()->NSDictionary?
    {
        let data=NSMutableDictionary()
        
        if let _=A0SimpleKeychain().string(forKey:"id")
        {
            data["id"]=A0SimpleKeychain().string(forKey:"id")
        }
        if let _=A0SimpleKeychain().string(forKey:"password")
        {
            data["password"]=A0SimpleKeychain().string(forKey:"password")
        }
        if let _=A0SimpleKeychain().string(forKey:"type")
        {
            data["type"]=A0SimpleKeychain().string(forKey:"type")
        }
        
        data["token"]="2"
        
        return data.count==4 ? data : nil
    }
    
    func login(_ loginData:NSDictionary, _ success:@escaping(_ session:String)->(), _ failure:@escaping(_ error:NSError)->())
    {
        let path="user/login"
        
        let requestMapping=UserMappingProvider.loginRequestMapping()
        let responseMapping=UserMappingProvider.loginResponseMapping()
        
        let requestDescriptor=RKRequestDescriptor(mapping:requestMapping, objectClass:NSDictionary.self, rootKeyPath:nil, method:.POST)
        
        manager.addRequestDescriptor(requestDescriptor)
        
        let statusCode=RKStatusCodeIndexSetForClass(.successful)
        
        let loginResponseDescriptor=RKResponseDescriptor(mapping:responseMapping, method:.POST, pathPattern:nil, keyPath:"data", statusCodes:statusCode)
        manager.addResponseDescriptor(loginResponseDescriptor)
        
        manager.post(loginData, path:path, parameters:nil, success:{(operation, mappingResult)->Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult!)!
            
            if !error.status
            {
                failure(error.toNSError())
            }
            else
            {
                let data=mappingResult?.dictionary()["data"] as! NSDictionary
                let session=data["session"] as! String
                success(session)
            }
            }, failure:{(operation, error)->Void in
                //failure(error)
        })
    }
    
    func relogin(_ success:@escaping()->(), failure:@escaping()->())
    {
        func loginSuccess(_ session:String)
        {
            success()
        }
        
        func loginFailure(_ error:NSError)
        {
            failure()
        }
        
        if let data=loginData()
        {
            self.login(data, loginSuccess, loginFailure)
        }
        else
        {
            failure()
        }
    }

    func addErrorResponseDescriptor()
    {
        let mapping=ErrorMappingProvider.errorObjectMapping()

        let statusCode=RKStatusCodeIndexSetForClass(.successful)
        errorDescriptor=RKResponseDescriptor(mapping:mapping, method:.any, pathPattern:nil, keyPath:"", statusCodes:statusCode)
        manager.addResponseDescriptor(errorDescriptor)
    }
    
    func findErrorObject(mappingResult:RKMappingResult)->Error?
    {
        for obj in mappingResult.array()
        {
            if obj is Error
            {
                return obj as? Error
            }
        }
        
        return nil
    }
}
