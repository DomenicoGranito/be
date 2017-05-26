//
//  PasswordViewController.swift
//  Streamini
//
//  Created by Vasiliy Evreinov on 07.06.16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class PasswordViewController: BaseViewController
{
    @IBOutlet var currentPassword:UITextField!
    @IBOutlet var newPassword:UITextField!
    @IBOutlet var confirmPassword:UITextField!
    @IBOutlet var imageView1:UIImageView!
    @IBOutlet var imageView2:UIImageView!
    @IBOutlet var imageView3:UIImageView!
    @IBOutlet var view1:UIView!
    @IBOutlet var view2:UIView!
    @IBOutlet var view3:UIView!
    
    override func viewDidLoad()
    {
        imageView1?.image=imageView1?.image?.withRenderingMode(.alwaysTemplate)
        imageView2?.image=imageView2?.image?.withRenderingMode(.alwaysTemplate)
        imageView3?.image=imageView3?.image?.withRenderingMode(.alwaysTemplate)
        imageView1?.tintColor=UIColor.darkGray
        imageView2?.tintColor=UIColor.darkGray
        imageView3?.tintColor=UIColor.darkGray
    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        currentPassword.text=""
        newPassword.text=""
        confirmPassword.text=""
    }
    
    @IBAction func doneButtonPressed()
    {
        if let _=A0SimpleKeychain().string(forKey:"password")
        {
            if(A0SimpleKeychain().string(forKey:"password") != currentPassword.text)
            {
                let alertView=UIAlertView.notAuthorizedAlert(NSLocalizedString("current_password_wrong", comment:""))
                alertView.show()
                return
            }
        }
        
        if(newPassword.text != confirmPassword.text||newPassword.text=="")
        {
            let alertView=UIAlertView.notAuthorizedAlert(NSLocalizedString("passwords_do_not_match", comment:""))
            alertView.show()
            return
        }
        
        UserConnector().password(newPassword.text!, passwordSuccess, passwordFailure)
    }
    
    func passwordSuccess()
    {
        let alertView=UIAlertView.notAuthorizedAlert(NSLocalizedString("password_changed", comment:""))
        alertView.show()
        A0SimpleKeychain().setString(newPassword.text!, forKey:"password")
    }
    
    func passwordFailure(error:NSError)
    {
        handleError(error)
    }
    
    func textFieldShouldBeginEditing(_ textField:UITextField)->Bool
    {
        if(textField==currentPassword)
        {
            view1?.backgroundColor=UIColor(colorLiteralRed:34/255, green:35/255, blue:39/255, alpha:1)
            view2?.backgroundColor=UIColor(colorLiteralRed:28/255, green:27/255, blue:32/255, alpha:1)
            view3?.backgroundColor=UIColor(colorLiteralRed:28/255, green:27/255, blue:32/255, alpha:1)
            
            imageView1?.tintColor=UIColor.white
            imageView2?.tintColor=UIColor.darkGray
            imageView3?.tintColor=UIColor.darkGray
        }
        else if(textField==newPassword)
        {
            view2?.backgroundColor=UIColor(colorLiteralRed:34/255, green:35/255, blue:39/255, alpha:1)
            view1?.backgroundColor=UIColor(colorLiteralRed:28/255, green:27/255, blue:32/255, alpha:1)
            view3?.backgroundColor=UIColor(colorLiteralRed:28/255, green:27/255, blue:32/255, alpha:1)
            
            imageView1?.tintColor=UIColor.darkGray
            imageView2?.tintColor=UIColor.white
            imageView3?.tintColor=UIColor.darkGray
        }
        else
        {
            view3?.backgroundColor=UIColor(colorLiteralRed:34/255, green:35/255, blue:39/255, alpha:1)
            view1?.backgroundColor=UIColor(colorLiteralRed:28/255, green:27/255, blue:32/255, alpha:1)
            view2?.backgroundColor=UIColor(colorLiteralRed:28/255, green:27/255, blue:32/255, alpha:1)
            
            imageView1?.tintColor=UIColor.darkGray
            imageView2?.tintColor=UIColor.darkGray
            imageView3?.tintColor=UIColor.white
        }
        
        return true
    }
}
