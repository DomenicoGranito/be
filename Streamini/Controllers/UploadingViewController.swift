//
//  UploadingViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 6/12/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

import MobileCoreServices

class UploadingViewController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    override func viewDidLoad()
    {
        
    }
    
    override func viewWillDisappear(_ animated:Bool)
    {
        
    }
    
    @IBAction func addTapped()
    {
        let actionSheet=UIActionSheet(title:"Select", delegate:self, cancelButtonTitle:nil, destructiveButtonTitle:"Cancel", otherButtonTitles:"Select From Album")
        
        actionSheet.show(in:view)
    }
    
    func actionSheet(_ actionSheet:UIActionSheet, clickedButtonAt buttonIndex:Int)
    {
        if buttonIndex==1
        {
            let imagePicker=DWVideoCompressController(quality:.medium, andSourceType:.photoLibrary, andMediaType:.movieAndImage)!
            imagePicker.delegate=self
            present(imagePicker, animated:true)
        }
    }
    
    func imagePickerController(_ picker:UIImagePickerController, didFinishPickingMediaWithInfo info:[String:Any])
    {
        let mediaType=info[UIImagePickerControllerMediaType] as! String
        
        if mediaType==kUTTypeMovie as String
        {
            let videoURL=info[UIImagePickerControllerMediaURL]
            picker.dismiss(animated:true)
        }
        else
        {
            let alertController=UIAlertController(title:"Message", message:"Please select movie only", preferredStyle:.alert)
            alertController.addAction(UIAlertAction(title:"OK", style:.cancel, handler:nil))
            present(alertController, animated:true)
        }
    }
}
