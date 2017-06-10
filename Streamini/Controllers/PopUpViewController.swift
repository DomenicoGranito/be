//
//  PopUpViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 3/2/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class PopUpViewController: BaseViewController
{
    @IBOutlet var backgroundImageView:UIImageView?
    
    let menuItemTitlesArray:NSMutableArray=["Share to friends", "Share on timeline", "Go to channels", "Download this video", "Report this video", "Add to favourite", "Block content from this channel"]
    let menuItemIconsArray:NSMutableArray=["upload", "upload", "add", "share", "report", "add", "block"]
    
    var stream:Stream?
    let site=Config.shared.site()
    var videoImage:UIImage!
    
    // MARK: - Orientation Handling.
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad()
    {
        if SongManager.isAlreadyFavourited(stream!.id)
        {
            menuItemTitlesArray.replaceObject(at:5, with:"Remove from favourite")
            menuItemIconsArray.replaceObject(at:5, with:"time.png")
        }
        
        backgroundImageView?.sd_setImage(with:URL(string:"\(site)/thumb/\(stream!.id).jpg"))
    }
    
    @IBAction func closeButtonPressed()
    {
        dismiss(animated:true)
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return 8
    }
    
    func tableView(_ tableView:UITableView, heightForRowAtIndexPath indexPath:IndexPath)->CGFloat
    {
        if indexPath.row==0
        {
            return 80
        }
        else
        {
            return 44
        }
    }
    
    func tableView(_ tableView:UITableView, cellForRowAtIndexPath indexPath:IndexPath)->UITableViewCell
    {
        if indexPath.row==0
        {
            let cell=tableView.dequeueReusableCell(withIdentifier:"RecentlyPlayedCell") as! RecentlyPlayedCell
            
            cell.videoTitleLbl?.text=stream?.title
            cell.artistNameLbl?.text=stream?.user.name
            cell.videoThumbnailImageView?.sd_setImage(with:URL(string:"\(site)/thumb/\(stream!.id).jpg"))
            
            videoImage=cell.videoThumbnailImageView?.image
            
            return cell
        }
        else
        {
            let cell=tableView.dequeueReusableCell(withIdentifier:"MenuCell") as! MenuCell
            
            cell.menuItemTitleLbl?.text=menuItemTitlesArray[indexPath.row-1] as? String
            cell.menuItemIconImageView?.image=UIImage(named:menuItemIconsArray[indexPath.row-1] as! String)
            
            return cell
        }
    }
    
    func tableView(_ tableView:UITableView, didSelectRowAtIndexPath indexPath:IndexPath)
    {
        if indexPath.row==1
        {
            shareOnWeChat(0)
        }
        if indexPath.row==2
        {
            shareOnWeChat(1)
        }
        if indexPath.row==3
        {
            view.window?.rootViewController?.dismiss(animated:true, completion:nil)
            NotificationCenter.default.post(name:Notification.Name("goToChannels"), object:stream?.user)
        }
        if indexPath.row==4
        {
            // GO TO VIDEO DOWNLOAD VIEW
        }
        if indexPath.row==5
        {
            StreamConnector().report(stream!.id, reportSuccess, failureWithoutAction)
        }
        if indexPath.row==6
        {
            dismiss(animated:true, completion:nil)
            
            if SongManager.isAlreadyFavourited(stream!.id)
            {
                SongManager.removeFromFavourite(stream!.id)
            }
            else
            {
                SongManager.addToFavourite(stream!.title, stream!.streamHash, stream!.id, stream!.user.name, stream!.vType, stream!.videoID, stream!.user.id)
            }
        }
        if indexPath.row==7
        {
            dismiss(animated:true)
            SocialConnector().block(stream!.user.id, blockSuccess, failureWithoutAction)
            SongManager.deleteBlockedUserVideos(stream!.user.id)
            NotificationCenter.default.post(name:Notification.Name("blockUser"), object:nil)
            NotificationCenter.default.post(name:Notification.Name("hideMiniPlayer"), object:nil)
            NotificationCenter.default.post(name:Notification.Name("refreshAfterBlock"), object:nil)
        }
    }
    
    func reportSuccess()
    {
        SCLAlertView().showSuccess("MESSAGE", subTitle:"Video has been reported")
    }
    
    func blockSuccess()
    {
        
    }
    
    func failureWithoutAction(error:NSError)
    {
        handleError(error)
    }
    
    func shareOnWeChat(_ sceneID:Int32)
    {
        if WXApi.isWXAppInstalled()
        {
            let videoObject=WXVideoObject()
            videoObject.videoUrl="http://beinit.cn/\(stream!.streamHash)/\(stream!.id)"
            
            let message=WXMediaMessage()
            message.title=stream?.title
            message.description=stream?.user.name
            message.mediaObject=videoObject
            message.setThumbImage(videoImage)
            
            let req=SendMessageToWXReq()
            req.message=message
            req.scene=sceneID
            
            WXApi.send(req)
        }
        else
        {
            SCLAlertView().showSuccess("MESSAGE", subTitle:"Please install WeChat application")
        }
    }
}
