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
    
    override func viewDidLoad()
    {
        currentPassword.placeholder=NSLocalizedString("current_password", comment:"")
        newPassword.placeholder=NSLocalizedString("new_password", comment:"")
        confirmPassword.placeholder=NSLocalizedString("confirm_password", comment:"")
    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        currentPassword.text=""
        newPassword.text=""
        confirmPassword.text=""
    }
    
    @IBAction func doneButtonPressed()
    {
        if let _=A0SimpleKeychain().string(forKey: "password")
        {
            if(A0SimpleKeychain().string(forKey: "password") != currentPassword.text)
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
        
        UserConnector().password(newPassword.text!, success:passwordSuccess, failure:passwordFailure)
    }
    
    func passwordSuccess()
    {
        let alertView=UIAlertView.notAuthorizedAlert(NSLocalizedString("password_changed", comment:""))
        alertView.show()
        A0SimpleKeychain().setString(newPassword.text!, forKey:"password")
    }
    
    func passwordFailure(_ error:NSError)
    {
        handleError(error)
    }
}
