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
    
    let menuItemTitlesArray:NSMutableArray=["Share to Friends", "Share to Timeline", "Go to channels", "Report this Video", "Add to favourite", "Block Content from this Channel"]
    let menuItemIconsArray:NSMutableArray=["upload", "upload", "add", "share", "report", "add"]
    
    var stream:Stream?
    let site=Config.shared.site()
    var videoImage:UIImage!
    var appDelegate:AppDelegate!
    var isDownloadInProgress=false
        
    override func viewDidLoad()
    {
        if UserContainer.shared.logged().subscription=="pro"
        {
            menuItemTitlesArray.add("Download this video")
            menuItemIconsArray.add("block")
        }
        
        appDelegate=UIApplication.shared.delegate as! AppDelegate
        
        for item in appDelegate.downloadingItems.items
        {
            if (item as AnyObject).videoId==stream!.videoID
            {
                isDownloadInProgress=true
                break
            }
        }

        if SongManager.isAlreadyFavourited(stream!.id)
        {
            menuItemTitlesArray.replaceObject(at:4, with:"Remove from favourite")
            menuItemIconsArray.replaceObject(at:4, with:"time.png")
        }
        
        backgroundImageView?.sd_setImage(with:URL(string:"\(site)/thumb/\(stream!.id).jpg"))
    }
    
    @IBAction func closeButtonPressed()
    {
        dismiss(animated:true)
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return menuItemTitlesArray.count+1
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
            NotificationCenter.default.post(name: Notification.Name("goToChannels"), object:stream?.user)
        }
        if indexPath.row==4
        {
            StreamConnector().report(stream!.id, reportSuccess, failureWithoutAction)
        }
        if indexPath.row==5
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
        if indexPath.row==6
        {
            dismiss(animated:true)
            SocialConnector().block(stream!.user.id, blockSuccess, failureWithoutAction)
            SongManager.deleteBlockedUserVideos(stream!.user.id)
            NotificationCenter.default.post(name:Notification.Name("blockUser"), object:nil)
            NotificationCenter.default.post(name: Notification.Name("hideMiniPlayer"), object:nil)
            NotificationCenter.default.post(name: Notification.Name("refreshAfterBlock"), object:nil)
        }
        if indexPath.row==7
        {
            if SongManager.isAlreadyDownloaded(stream!.id)
            {
                SCLAlertView().showSuccess("MESSAGE", subTitle:"This video has been downloaded already")
            }
            else if isDownloadInProgress
            {
                SCLAlertView().showSuccess("MESSAGE", subTitle:"Download in progress")
            }
            else
            {
                view.window?.rootViewController?.dismiss(animated:true, completion:nil)
                NotificationCenter.default.post(name: Notification.Name("goToDownloads"), object:stream)
            }
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
