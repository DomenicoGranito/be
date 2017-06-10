//
//  LegalViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 17/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

enum LegalViewControllerType:Int
{
    case termsOfService=0
    case privacyPolicy
}

class LegalViewController: BaseViewController, UIWebViewDelegate
{
    @IBOutlet var webView:UIWebView!
    
    var type:LegalViewControllerType?
    
    // MARK: - Orientation Handling.
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad()
    {
        navigationController?.isNavigationBarHidden=false
        
        let urlString:String
        
        switch type!
        {
        case .termsOfService:
            urlString=Config.shared.legal().termsOfService
            self.title=NSLocalizedString("profile_terms", comment:"")
        case .privacyPolicy:
            urlString=Config.shared.legal().privacyPolicy
            self.title=NSLocalizedString("profile_privacy", comment:"")
        }
        
        webView.loadRequest(URLRequest(url:URL(string:urlString)!))
    }
    
    func webView(_ webView:UIWebView, shouldStartLoadWith request:URLRequest, navigationType:UIWebViewNavigationType)->Bool
    {
        if navigationType == .linkClicked
        {
            UIApplication.shared.openURL(request.url!)
            return false
        }
        
        return true
    }
}
