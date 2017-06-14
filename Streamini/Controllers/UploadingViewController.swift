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
    @IBOutlet var tableView:UITableView!
    
    var timer:Timer!
    var videoPath:String!
    var uploadItems:DWUploadItems!
    var uploadInfoSetupViewController:UploadInfoSetupViewController!
    var appDelegate:AppDelegate!
    
    override func viewWillAppear(_ animated:Bool)
    {
        appDelegate=UIApplication.shared.delegate as! AppDelegate
        
        uploadItems=appDelegate.uploadItems
        
        timer=Timer.scheduledTimer(timeInterval:1, target:self, selector:#selector(timerHandler), userInfo:nil, repeats:true)
        
        addVideoFileToUpload()
    }
    
    override func viewWillDisappear(_ animated:Bool)
    {
        timer.invalidate()
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
            let imagePicker=DWVideoCompressController(quality:.medium, andSourceType:.photoLibrary, andMediaType:.movie)!
            imagePicker.delegate=self
            present(imagePicker, animated:true)
        }
    }
    
    func imagePickerController(_ picker:UIImagePickerController, didFinishPickingMediaWithInfo info:[String:Any])
    {
        videoPath=(info[UIImagePickerControllerMediaURL] as! URL).path
        
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        uploadInfoSetupViewController=storyboard.instantiateViewController(withIdentifier:"UploadInfoSetupViewController") as! UploadInfoSetupViewController
        
        navigationController?.pushViewController(uploadInfoSetupViewController, animated:false)
        
        picker.dismiss(animated:true)
    }
    
    func addVideoFileToUpload()
    {
        if uploadInfoSetupViewController==nil || uploadInfoSetupViewController.isCancel
        {
            uploadInfoSetupViewController=nil
            videoPath=nil
            
            return
        }
        
        let item=DWUploadItem()
        
        item.videoUploadStatus=DWUploadStatusWait
        item.videoPath=videoPath
        item.videoTitle=uploadInfoSetupViewController.videoTitleTxt.text
        item.videoUploadProgress=0
        item.videoUploadedSize=0
        item.videoThumbnailPath="\(SongManager.documentsDir)/\(item.videoTitle!).png"
        
        try? DWTools.saveVideoThumbnail(withVideoPath:videoPath, toFile:item.videoThumbnailPath)
        
        item.videoFileSize=DWTools.getFileSize(withPath:videoPath, error:nil)
        
        uploadItems.items.add(item)
        tableView.reloadData()
        
        uploadInfoSetupViewController=nil
        videoPath=nil
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return uploadItems.items.count
    }
    
    func tableView(_ tableView:UITableView, cellForRowAtIndexPath indexPath:IndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCell(withIdentifier:"UploadingCell") as! UploadCell
        
        let item=uploadItems.items[indexPath.row] as! DWUploadItem
        
        cell.videoTitleLbl.text=item.videoTitle
        cell.videoThumbnailImageView.image=item.getVideoThumbnail()
        
        let uploadedSizeMB=Float(item.videoUploadedSize)/1024.0/1024.0
        let fileSizeMB=Float(item.videoFileSize)/1024.0/1024.0
        
        cell.progressLbl.text=String(format:"%0.1fM/%0.1fM", uploadedSizeMB, fileSizeMB)
        
        cell.statusButton.tag=indexPath.row
        cell.statusButton.addTarget(self, action:#selector(videoUploadStatusButtonAction), for:.touchUpInside)
        
        cell.updateUploadStatus(item)
        
        return cell
    }
    
    func tableView(_ tableView:UITableView, canEditRowAtIndexPath indexPath:IndexPath)->Bool
    {
        return true
    }
    
    func tableView(_ tableView:UITableView, commitEditingStyle editingStyle:UITableViewCellEditingStyle, forRowAtIndexPath indexPath:IndexPath)
    {
        if editingStyle == .delete
        {
            uploadItems.removeObject(at:UInt(indexPath.row))
            
            tableView.reloadData()
        }
    }
    
    func videoUploadStatusButtonAction(button:UIButton)
    {
        let indexPath=IndexPath(row:button.tag, section:0)
        
        let cell=tableView.cellForRow(at:indexPath) as! UploadCell
        
        let item=uploadItems.items[button.tag] as! DWUploadItem
        
        switch item.videoUploadStatus
        {
        case DWUploadStatusWait:
            videoUploadStartWithItem(item, cell)
            break
        case DWUploadStatusStart:
            videoUploadPauseWithItem(item, cell)
            break
        case DWUploadStatusUploading:
            videoUploadPauseWithItem(item, cell)
            break
        case DWUploadStatusPause:
            videoUploadResumeWithItem(item, cell)
            break
        case DWUploadStatusResume:
            videoUploadPauseWithItem(item, cell)
            break
        case DWUploadStatusLoadLocalFileInvalid:
            videoUploadFailedAlert("The local file does not exist, delete the task to re-add the file")
            break
        case DWUploadStatusFail:
            videoUploadResumeWithItem(item, cell)
            break
        default:
            break
        }
    }
    
    func videoUploadFailedAlert(_ info:String)
    {
        let alertController=UIAlertController(title:"Message", message:info, preferredStyle:.alert)
        alertController.addAction(UIAlertAction(title:"OK", style:.cancel, handler:nil))
        present(alertController, animated:true)
    }
    
    func setUploadBlockWithItem(_ item:DWUploadItem, _ cell:UploadCell)
    {
        let uploader=item.uploader!
        
        uploader.progressBlock={(progress:Float, totalBytesWritten:Int, totalBytesExpectedToWrite:Int)->() in
            item.videoUploadProgress=progress
            item.videoUploadedSize=totalBytesWritten
            cell.updateCellProgress(item)
        }
        
        uploader.finishBlock={()->() in
            // FIRST GET STREAM KEY OF UPLOADED VIDEO
            // HIT API TO SAVE THIS VIDEO ON OUR SERVER
            self.appDelegate.uploadItems.items.remove(item)
            DispatchQueue.main.async(execute:{()->() in
                self.tableView.reloadData()
            })
        }
        
        uploader.failBlock={(error:Error?)->() in
            item.uploader=nil
            item.videoUploadStatus=DWUploadStatusFail
            cell.updateUploadStatus(item)
        }
        
        uploader.pausedBlock={(error:Error?)->() in
            item.videoUploadStatus=DWUploadStatusPause
            cell.updateUploadStatus(item)
        }
    }
    
    func videoUploadStartWithItem(_ item:DWUploadItem, _ cell:UploadCell)
    {
        item.uploader=DWUploader(userId:"D43560320694466A", andKey:"WGbPBVI3075vGwA0AIW0SR9pDTsQR229", uploadVideoTitle:item.videoTitle, videoDescription:"", videoTag:"", videoPath:item.videoPath, notifyURL:"")
        
        item.videoUploadStatus=DWUploadStatusUploading
        
        cell.updateUploadStatus(item)
        
        item.uploader.timeoutSeconds=20
        
        setUploadBlockWithItem(item, cell)
        
        item.uploader.start()
    }
    
    func videoUploadResumeWithItem(_ item:DWUploadItem, _ cell:UploadCell)
    {
        if let _=item.uploadContext
        {
            if item.uploader==nil
            {
                item.uploader=DWUploader(videoContext:item.uploadContext)
            }
            
            item.videoUploadStatus=DWUploadStatusUploading
            cell.updateUploadStatus(item)
            item.uploader.timeoutSeconds=20
            setUploadBlockWithItem(item, cell)
            
            item.uploader.resume()
            
            return
        }
        
        item.uploader=nil
        videoUploadStartWithItem(item, cell)
    }
    
    func videoUploadPauseWithItem(_ item:DWUploadItem, _ cell:UploadCell)
    {
        if let _=item.uploader
        {
            item.uploader.pause()
            item.videoUploadStatus=DWUploadStatusPause
            cell.updateUploadStatus(item)
        }
    }
    
    func timerHandler()
    {
        var itemVar:DWUploadItem?
        var index=0
        
        for item in uploadItems.items
        {
            itemVar=item as? DWUploadItem
            
            if itemVar!.videoUploadStatus==DWUploadStatusWait
            {
                break
            }
            index+=1
        }
        
        if let item=itemVar
        {
            let indexPath=IndexPath(row:index, section:0)
            
            let cell=tableView.cellForRow(at:indexPath) as! UploadCell
            
            videoUploadStartWithItem(item, cell)
        }
    }
}
