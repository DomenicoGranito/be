//
//  TabBarViewController.swift
//  BEINIT
//
//  Created by Dominic Granito on 29/12/2016.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

import MessageUI

class myProfileViewController: BaseViewController,
    UINavigationControllerDelegate, UserHeaderViewDelegate, MFMailComposeViewControllerDelegate,
UserSelecting, ProfileDelegate {
    @IBOutlet weak var userHeaderView: UserHeaderView!
  
    var userStatisticsDelegate:UserStatisticsDelegate?
    var userStatusDelegate:UserStatusDelegate?
    
    var user: User?
    var profileDelegate: ProfileDelegate?
    
    func userDidSelected(_ user:User)
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewController(withIdentifier: "UserViewControllerId") as! UserViewController
        vc.user=user
        navigationController?.pushViewController(vc, animated:true)
    }
    
    func configureView()
    {
        self.title = NSLocalizedString("profile_title", comment: "")
        
        userHeaderView.delegate = self
    }
    
    func successGetUser(_ user: User) {
        self.user = user
        userHeaderView.update(user)
        
       self.navigationItem.rightBarButtonItem = nil
    }
    
    override func prepare(for segue:UIStoryboardSegue, sender:Any?)
    {
        if let sid=segue.identifier
        {
            if sid=="UserToLinkedUsers"
            {
                let controller=segue.destination as! LinkedUsersViewController
                controller.profileDelegate=self
                self.userStatisticsDelegate=controller
            }
        }
    }

    func successFailure(_ error: NSError) {
        handleError(error)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool)
    {
        navigationController.navigationBar.tintColor = UIColor.blue
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blue]
    }
        
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.configureView()
        
        let activator=UIActivityIndicatorView(activityIndicatorStyle:.white)
        activator.startAnimating()
        
        self.navigationItem.rightBarButtonItem=UIBarButtonItem(customView:activator)
        UserConnector().get(nil, success:successGetUser, failure:successFailure)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController!.setNavigationBarHidden(false, animated: false)
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
        UINavigationBar.setCustomAppereance()
    }
        
     func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if (indexPath as NSIndexPath).section == 2 && (indexPath as NSIndexPath).row == 0 { // share
            UINavigationBar.resetCustomAppereance()
            let shareMessage = NSLocalizedString("profile_share_message", comment: "")
            let activityController = UIActivityViewController(activityItems: [shareMessage], applicationActivities: nil)
            self.present(activityController, animated: true, completion: nil)
        }
        
        if (indexPath as NSIndexPath).section == 2 && (indexPath as NSIndexPath).row == 1 { // feedback
            UINavigationBar.resetCustomAppereance()
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                let alert = UIAlertView.mailUnavailableErrorAlert()
                alert.show()
            }
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([Config.shared.feedback()])
        mailComposerVC.setSubject(NSLocalizedString("feedback_title", comment: ""))
        
        let appVersion  = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let appBuild    = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        let deviceName  = UIDevice.current.name
        let iosVersion  = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        let userId      = user!.id
        
        var message = "\n\n\n"
        message = message + "App Version: \(appVersion)\n"
        message = message + "App Build: \(appBuild)\n"
        message = message + "Device Name: \(deviceName)\n"
        message = message + "iOS Version: \(iosVersion)\n"
        message = message + "User Id: \(userId)"
        
        mailComposerVC.setMessageBody(message, isHTML: false)
        
        mailComposerVC.delegate = self
        
        return mailComposerVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        //controller.dismissViewControllerAnimated(true, completion: nil)
        controller.dismiss(animated: true, completion: { () -> Void in
            // if result.rawValue == MFMailComposeResultFailed.rawValue {
            //   let alert = UIAlertView.sendMailErrorAlert()
            // alert.show()
            //}
        })
    }
    
    func reload() {
        UserConnector().get(nil, success: successGetUser, failure: successFailure)
    }
    
    func close() {
    }
    
    func usernameLabelPressed()
    {
        
    }
    
    func descriptionWillStartEdit()
    {
        let doneBarButtonItem=UIBarButtonItem(barButtonSystemItem:.done, target:self, action:#selector(doneButtonPressed))
        self.navigationItem.rightBarButtonItem=doneBarButtonItem
    }
    
    func doneButtonPressed(_ sender: AnyObject) {
        let text: String
        if userHeaderView.userDescriptionTextView.text == NSLocalizedString("profile_description_placeholder", comment: "") {
            text = " "
        } else {
            text = userHeaderView.userDescriptionTextView.text
        }
        
        let activator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        activator.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activator)
        
        UserConnector().userDescription(text, success: userDescriptionTextSuccess, failure: userDescriptionTextFailure)
    }
    
    func userDescriptionTextSuccess() {
        self.navigationItem.rightBarButtonItem = nil
        userHeaderView.userDescriptionTextView.resignFirstResponder()
        
        if let delegate = profileDelegate {
            delegate.reload()
        }
    }
    
    func userDescriptionTextFailure(_ error:NSError)
    {
        handleError(error)
        let doneBarButtonItem=UIBarButtonItem(barButtonSystemItem:.done, target:self, action:#selector(doneButtonPressed))
        self.navigationItem.rightBarButtonItem=doneBarButtonItem
    }
}
