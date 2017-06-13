//
//  UploadInfoSetupViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 6/13/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class UploadInfoSetupViewController: UIViewController
{
    @IBOutlet var videoTitleTxt:UITextField!
    @IBOutlet var videoCategoryTxt:UITextField!
    
    var isCancel=false
    
    override func viewDidLoad()
    {
        
    }
    
    @IBAction func upload()
    {
        navigationController!.popViewController(animated:true)
    }
    
    @IBAction func cancel()
    {
        isCancel=true
        navigationController!.popViewController(animated:true)
    }
    
    func textFieldShouldReturn(_ textField:UITextField)->Bool
    {
        textField.resignFirstResponder()
        return true
    }
}
