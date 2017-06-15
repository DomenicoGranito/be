//
//  LoginViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 22/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class LoginViewController: BaseViewController
{
    @IBOutlet var usernameTxt:UITextField?
    @IBOutlet var passwordTxt:UITextField?
    @IBOutlet var usernameImageView:UIImageView?
    @IBOutlet var passwordImageView:UIImageView?
    @IBOutlet var usernameBackgroundView:UIView?
    @IBOutlet var passwordBackgroundView:UIView?
    
    let storyBoard=UIStoryboard(name:"Main", bundle:nil)
    var username:String!
    var password:String!
    var email:String!
    let (appID, appSecret)=Config.shared.weChat()
    
    override var supportedInterfaceOrientations:UIInterfaceOrientationMask
    {
        return .portrait
    }
    
    override var shouldAutorotate:Bool
    {
        return false
    }
    
    func buildAccessTokenLink(_ code:String)->String
    {
        return "oauth2/access_token?appid="+appID+"&secret="+appSecret+"&code="+code+"&grant_type=authorization_code"
    }
    
    override func viewDidLoad()
    {
        NotificationCenter.default.addObserver(self, selector:#selector(onResp), name:Notification.Name("getCode"), object:nil)
        
        usernameImageView?.image=usernameImageView?.image?.withRenderingMode(.alwaysTemplate)
        passwordImageView?.image=passwordImageView?.image?.withRenderingMode(.alwaysTemplate)
        usernameImageView?.tintColor=UIColor.darkGray
        passwordImageView?.tintColor=UIColor.darkGray
    }
    
    @IBAction func wechatLogin()
    {
        if WXApi.isWXAppInstalled()
        {
            let req=SendAuthReq()
            req.scope="snsapi_userinfo"
            req.state="123"
            
            WXApi.send(req)
        }
        else
        {
            SCLAlertView().showSuccess("MESSAGE", subTitle:"Please install WeChat application")
        }
    }
    
    func onResp(_ notification:NSNotification)
    {
        let code=notification.object as! String
        
        let accessTokenLinkString=buildAccessTokenLink(code)
        UserConnector().getWeChatAccessToken(accessTokenLinkString, successAccessToken, forgotFailure)
    }
    
    func successAccessToken(_ data:NSDictionary)
    {
        let accessToken=data["access_token"] as! String
        let openID=data["openid"] as! String
        
        let userProfileLinkString="userinfo?access_token="+accessToken+"&openid="+openID
        UserConnector().getWeChatUserProfile(userProfileLinkString, successUserProfile, forgotFailure)
    }
    
    func successUserProfile(_ data:NSDictionary)
    {
        username=data["openid"] as! String
        password="beinitpass"
        email=username+"@WeChat.com"
        
        A0SimpleKeychain().setString(data["nickname"] as! String, forKey:"nickname")
        A0SimpleKeychain().setString(data["headimgurl"] as! String, forKey:"headimgurl")
        
        signupWithBEINIT()
    }
    
    func signupWithBEINIT()
    {
        let loginData=NSMutableDictionary()
        
        loginData["id"]=email
        loginData["username"]=username
        loginData["password"]=password
        loginData["token"]="1"
        loginData["type"]="signup"
        
        A0SimpleKeychain().setString(email, forKey:"id")
        A0SimpleKeychain().setString(password, forKey:"password")
        A0SimpleKeychain().setString("signup", forKey:"type")
        A0SimpleKeychain().setString("1", forKey:"WeChatLogin")
        
        if let deviceToken=(UIApplication.shared.delegate as! AppDelegate).deviceToken
        {
            loginData["apn"]=deviceToken
        }
        else
        {
            loginData["apn"]=""
        }
        
        UserConnector().login(loginData, loginSuccess, signupFailure)
    }
    
    func signupFailure(error:NSError)
    {
        let errorMessage=error.userInfo[NSLocalizedDescriptionKey] as! String
        
        if errorMessage=="Username is already taken."
        {
            loginWithBEINIT()
        }
    }
    
    func loginWithBEINIT()
    {
        let loginData=NSMutableDictionary()
        
        loginData["id"]=username
        loginData["password"]=password
        loginData["token"]="2"
        loginData["type"]="signup"
        
        A0SimpleKeychain().setString(username, forKey:"id")
        A0SimpleKeychain().setString(password, forKey:"password")
        A0SimpleKeychain().setString("signup", forKey:"type")
        
        if let deviceToken=(UIApplication.shared.delegate as! AppDelegate).deviceToken
        {
            loginData["apn"]=deviceToken
        }
        else
        {
            loginData["apn"]=""
        }
        
        UserConnector().login(loginData, loginSuccess, forgotFailure)
    }
    
    @IBAction func login()
    {
        A0SimpleKeychain().setString("0", forKey:"WeChatLogin")
        
        username=usernameTxt!.text!
        password=passwordTxt!.text!
        
        loginWithBEINIT()
    }
    
    func loginSuccess(session:String, user:User)
    {
        SongManager.updateLogin(user)
        UserContainer.shared.setLogged(user)
        
        A0SimpleKeychain().setString(session, forKey:"PHPSESSID")
        
        let vc=storyBoard.instantiateViewController(withIdentifier:"TabBarViewController")
        navigationController?.pushViewController(vc, animated:true)
    }
    
    @IBAction func forgotPassword()
    {
        if(usernameTxt?.text=="")
        {
            UIAlertView.notAuthorizedAlert("Please enter your username").show()
        }
        else
        {
            UserConnector().forgot(username, forgotSuccess, forgotFailure)
        }
    }
    
    func forgotSuccess()
    {
        UIAlertView.notAuthorizedAlert("Password reset").show()
    }
    
    func forgotFailure(error:NSError)
    {
        handleError(error)
    }
    
    @IBAction func back()
    {
        navigationController!.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField:UITextField)->Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField:UITextField)->Bool
    {
        if(textField==usernameTxt)
        {
            usernameBackgroundView?.backgroundColor=UIColor(red:34/255, green:35/255, blue:39/255, alpha:1)
            passwordBackgroundView?.backgroundColor=UIColor(red:28/255, green:27/255, blue:32/255, alpha:1)
            
            usernameImageView?.tintColor=UIColor.white
            passwordImageView?.tintColor=UIColor.darkGray
        }
        else
        {
            passwordBackgroundView?.backgroundColor=UIColor(red:34/255, green:35/255, blue:39/255, alpha:1)
            usernameBackgroundView?.backgroundColor=UIColor(red:28/255, green:27/255, blue:32/255, alpha:1)
            
            usernameImageView?.tintColor=UIColor.darkGray
            passwordImageView?.tintColor=UIColor.white
        }
        
        return true
    }
}
