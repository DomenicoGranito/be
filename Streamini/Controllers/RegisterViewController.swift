//
//  RegisterViewController.swift
//  Streamini
//
//  Created by Ankit Garg on 8/27/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class RegisterViewController: BaseViewController
{
    @IBOutlet var emailTxt:UITextField?
    @IBOutlet var passwordTxt:UITextField?
    @IBOutlet var usernameTxt:UITextField?
    @IBOutlet var emailImageView:UIImageView?
    @IBOutlet var passwordImageView:UIImageView?
    @IBOutlet var usernameImageView:UIImageView?
    @IBOutlet var emailBackgroundView:UIView?
    @IBOutlet var passwordBackgroundView:UIView?
    @IBOutlet var usernameBackgroundView:UIView?
    
    override var supportedInterfaceOrientations:UIInterfaceOrientationMask
    {
        return .portrait
    }
    
    override var shouldAutorotate:Bool
    {
        return false
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        usernameImageView?.image=usernameImageView?.image?.withRenderingMode(.alwaysTemplate)
        passwordImageView?.image=passwordImageView?.image?.withRenderingMode(.alwaysTemplate)
        emailImageView?.image=emailImageView?.image?.withRenderingMode(.alwaysTemplate)
        usernameImageView?.tintColor=UIColor.darkGray
        passwordImageView?.tintColor=UIColor.darkGray
        emailImageView?.tintColor=UIColor.darkGray
    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        navigationController?.isNavigationBarHidden=true
    }
    
    @IBAction func register()
    {
        let loginData=NSMutableDictionary()
        loginData["id"]=emailTxt!.text!
        loginData["username"]=usernameTxt!.text!
        loginData["password"]=passwordTxt!.text!
        loginData["token"]="1"
        loginData["type"]="signup"
        
        A0SimpleKeychain().setString(emailTxt!.text!, forKey:"id")
        A0SimpleKeychain().setString(passwordTxt!.text!, forKey:"password")
        A0SimpleKeychain().setString("signup", forKey:"type")
        
        if let deviceToken=(UIApplication.shared.delegate as! AppDelegate).deviceToken
        {
            loginData["apn"]=deviceToken
        }
        else
        {
            loginData["apn"]=""
        }
        
        let connector=UserConnector()
        connector.login(loginData, loginSuccess, forgotFailure)
    }
    
    func loginSuccess(session:String, user:User)
    {
        SongManager.updateLogin(user)
        UserContainer.shared.setLogged(user)
        
        A0SimpleKeychain().setString(session, forKey:"PHPSESSID")
        A0SimpleKeychain().setString("0", forKey:"WeChatLogin")
        
        let vc=storyBoard.instantiateViewController(withIdentifier:"TabBarViewController")
        navigationController?.pushViewController(vc, animated:true)
    }
    
    func forgotFailure(error:NSError)
    {
        handleError(error)
    }
    
    @IBAction func seeTermsAndConditions()
    {
        let vc=storyBoard.instantiateViewController(withIdentifier:"LegalViewController") as! LegalViewController
        vc.type=LegalViewControllerType(rawValue:0)!
        navigationController?.pushViewController(vc, animated:true)
    }
    
    @IBAction func seePrivacyPolicy()
    {
        let vc=storyBoard.instantiateViewController(withIdentifier:"LegalViewController") as! LegalViewController
        vc.type=LegalViewControllerType(rawValue:1)!
        navigationController?.pushViewController(vc, animated:true)
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
        if(textField==emailTxt)
        {
            emailBackgroundView?.backgroundColor=UIColor(red:34/255, green:35/255, blue:39/255, alpha:1)
            usernameBackgroundView?.backgroundColor=UIColor(red:28/255, green:27/255, blue:32/255, alpha:1)
            passwordBackgroundView?.backgroundColor=UIColor(red:28/255, green:27/255, blue:32/255, alpha:1)
            
            emailImageView?.tintColor=UIColor.white
            usernameImageView?.tintColor=UIColor.darkGray
            passwordImageView?.tintColor=UIColor.darkGray
        }
        else if(textField==usernameTxt)
        {
            usernameBackgroundView?.backgroundColor=UIColor(red:34/255, green:35/255, blue:39/255, alpha:1)
            emailBackgroundView?.backgroundColor=UIColor(red:28/255, green:27/255, blue:32/255, alpha:1)
            passwordBackgroundView?.backgroundColor=UIColor(red:28/255, green:27/255, blue:32/255, alpha:1)
            
            emailImageView?.tintColor=UIColor.darkGray
            usernameImageView?.tintColor=UIColor.white
            passwordImageView?.tintColor=UIColor.darkGray
        }
        else
        {
            passwordBackgroundView?.backgroundColor=UIColor(red:34/255, green:35/255, blue:39/255, alpha:1)
            emailBackgroundView?.backgroundColor=UIColor(red:28/255, green:27/255, blue:32/255, alpha:1)
            usernameBackgroundView?.backgroundColor=UIColor(red:28/255, green:27/255, blue:32/255, alpha:1)
            
            emailImageView?.tintColor=UIColor.darkGray
            usernameImageView?.tintColor=UIColor.darkGray
            passwordImageView?.tintColor=UIColor.white
        }
        
        return true
    }
}
