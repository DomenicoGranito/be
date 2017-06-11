//
//  OfflineViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 6/9/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class OfflineViewController: UIViewController
{
    @IBOutlet var downloadFinishTbl:UITableView!
    @IBOutlet var downloadingTbl:UITableView!
    @IBOutlet var segmentedControl:UISegmentedControl!
    
    var timer:Timer!
    var stream:Stream?
    var downloadingItems:DWDownloadItems!
    var downloadFinishItems:[NSManagedObject]!
    let site=Config.shared.site()
    var appDelegate:AppDelegate!
    
    override func viewDidLoad()
    {
        appDelegate=UIApplication.shared.delegate as! AppDelegate
        
        loadTableView()
        
        timer=Timer.scheduledTimer(timeInterval:1, target:self, selector:#selector(timerHandler), userInfo:nil, repeats:true)
        
        addTask()
    }
    
    override func viewWillDisappear(_ animated:Bool)
    {
        timer.invalidate()
    }
    
    func loadTableView()
    {
        downloadingItems=appDelegate.downloadingItems
        downloadFinishItems=SongManager.getDownloads()
        
        downloadingTbl.reloadData()
        downloadFinishTbl.reloadData()
    }
    
    func addTask()
    {
        if let _=stream
        {
            segmentedControl.selectedSegmentIndex=1
            
            downloadFinishTbl.isHidden=true
            downloadingTbl.isHidden=false
            
            let item=DWDownloadItem()
            item.videoDownloadStatus=DWDownloadStatusWait
            item.videoId=stream!.videoID
            item.streamID=Int(stream!.id)
            item.streamUserID=Int(stream!.user.id)
            item.streamTitle=stream!.title
            item.streamHash=stream!.streamHash
            item.streamUserName=stream!.user.name
            
            appDelegate.downloadingItems.items.add(item)
            
            loadTableView()
        }
    }
    
    @IBAction func segmentedControlValueChanged()
    {
        if segmentedControl.selectedSegmentIndex==0
        {
            downloadFinishTbl.isHidden=false
            downloadingTbl.isHidden=true
        }
        else
        {
            downloadFinishTbl.isHidden=true
            downloadingTbl.isHidden=false
        }
    }
    
    func videoDownloadingStatusButtonAction(button:UIButton)
    {
        let indexPath=IndexPath(row:button.tag, section:0)
        
        let cell=downloadingTbl.cellForRow(at:indexPath) as! OfflineCell
        
        let item=downloadingItems.items[button.tag] as! DWDownloadItem
        
        switch(item.videoDownloadStatus)
        {
        case DWDownloadStatusWait:
            videoDownloadStartWithItem(item, cell)
            break
        case DWDownloadStatusStart:
            videoDownloadPauseWithItem(item, cell)
            break
        case DWDownloadStatusDownloading:
            videoDownloadPauseWithItem(item, cell)
            break
        case DWDownloadStatusPause:
            videoDownloadResumeWithItem(item, cell)
            break
        case DWDownloadStatusFail:
            videoDownloadStartWithItem(item, cell)
            break
        default:
            break
        }
    }
    
    func setDownloaderBlocksWithItem(_ item:DWDownloadItem, _ cell:OfflineCell)
    {
        let downloader=item.downloader
        
        downloader?.progressBlock={(_ progress:Float, _ totalBytesWritten:Int, _ totalBytesExpectedToWrite:Int)->Void in
            item.videoDownloadedSize=totalBytesWritten
            item.videoFileSize=totalBytesExpectedToWrite
            item.videoDownloadProgress=Float(item.videoDownloadedSize/item.videoFileSize)
        }
        
        downloader?.failBlock={(_ error:Error?)->Void in
            item.videoDownloadStatus=DWDownloadStatusFail
            cell.updateDownloadStatus(item)
        }
        
        downloader?.finishBlock={()->Void in
            SongManager.addToDownloads(item.streamTitle, item.streamHash, item.streamID, item.streamUserName, item.videoId, item.streamUserID)
            self.appDelegate.downloadingItems.items.remove(item)
            DispatchQueue.main.async(execute:{()->Void in
                self.loadTableView()
            })
        }
    }
    
    func videoDownloadStartWithItem(_ item:DWDownloadItem, _ cell:OfflineCell)
    {
        item.videoDownloadStatus=DWDownloadStatusStart
        cell.updateDownloadStatus(item)
        
        let paths=NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory=paths[0]
        
        item.videoPath="\(documentDirectory)/\(item.videoId!).mp4"
        
        let downloader=DWDownloader(userId:"D43560320694466A", andVideoId:item.videoId, key:"WGbPBVI3075vGwA0AIW0SR9pDTsQR229", destinationPath:item.videoPath)
        
        item.downloader=downloader
        item.videoDownloadStatus=DWDownloadStatusDownloading
        cell.updateDownloadStatus(item)
        downloader?.timeoutSeconds=20
        
        setDownloaderBlocksWithItem(item, cell)
        
        downloader?.start()
    }
    
    func videoDownloadResumeWithItem(_ item:DWDownloadItem, _ cell:OfflineCell)
    {
        if let _=item.downloader
        {
            item.downloader.resume()
            item.videoDownloadStatus=DWDownloadStatusDownloading
            cell.updateDownloadStatus(item)
        }
    }
    
    func videoDownloadPauseWithItem(_ item:DWDownloadItem, _ cell:OfflineCell)
    {
        if let _=item.downloader
        {
            item.downloader.pause()
            item.videoDownloadStatus=DWDownloadStatusPause
            cell.updateDownloadStatus(item)
        }
    }
    
    func timerHandler()
    {
        var itemVar:DWDownloadItem?
        var index=0
        
        for item in downloadingItems.items
        {
            if (item as AnyObject).videoDownloadStatus==DWDownloadStatusWait
            {
                itemVar=item as? DWDownloadItem
                break
            }
            index+=1
        }
        
        if let item=itemVar
        {
            let indexPath=IndexPath(row:index, section:0)
            
            let cell=downloadingTbl.cellForRow(at:indexPath) as! OfflineCell
            
            videoDownloadStartWithItem(item, cell)
        }
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        if tableView==downloadFinishTbl
        {
            return downloadFinishItems.count
        }
        else
        {
            return downloadingItems.items.count
        }
    }
    
    func tableView(_ tableView:UITableView, cellForRowAtIndexPath indexPath:IndexPath)->UITableViewCell
    {
        if tableView==downloadFinishTbl
        {
            let cell=tableView.dequeueReusableCell(withIdentifier:"DownloadFinishCell") as! RecentlyPlayedCell
            
            cell.videoTitleLbl?.text=downloadFinishItems[indexPath.row].value(forKey:"streamTitle") as? String
            cell.artistNameLbl?.text=downloadFinishItems[indexPath.row].value(forKey:"streamUserName") as? String
            cell.videoThumbnailImageView?.sd_setImage(with:URL(string:"\(site)/thumb/\(downloadFinishItems[indexPath.row].value(forKey:"streamID") as! Int).jpg"), placeholderImage:UIImage(named:"stream"))
            
            cell.selectedBackgroundView=SelectedCellView().create()
            
            return cell
        }
        else
        {
            let cell=tableView.dequeueReusableCell(withIdentifier:"DownloadingCell") as! OfflineCell
            
            let item=downloadingItems.items[indexPath.row] as! DWDownloadItem
            
            cell.videoTitleLbl.text=item.streamTitle
            cell.artistNameLbl.text=item.streamUserName
            cell.videoThumbnailImageView.sd_setImage(with:URL(string:"\(site)/thumb/\(item.streamID).jpg"), placeholderImage:UIImage(named:"stream"))
            
            cell.statusButton.tag=indexPath.row
            cell.statusButton.addTarget(self, action:#selector(videoDownloadingStatusButtonAction), for:.touchUpInside)
            
            cell.updateDownloadStatus(item)
            
            return cell
        }
    }
}