//
//  RelatedVideoCell.swift
//  Streamini
//
//  Created by Ankit Garg on 8/3/18.
//  Copyright © 2018 Cedricm Video. All rights reserved.
//

class RelatedVideoCell: UITableViewCell
{
    @IBOutlet var collectionView:UICollectionView!
    
    var delegate:RelatedVideoSelecting!
    var relatedVideosArray:NSArray!
    let site=Config.shared.site()
    var page=0
    var categoryID:Int!
    var isMoreData=true
    
    func reloadCollectionView()
    {
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView:UICollectionView, numberOfItemsInSection section:Int)->Int
    {
        return relatedVideosArray.count
    }
    
    func collectionView(_ collectionView:UICollectionView, cellForItemAtIndexPath indexPath:IndexPath)->UICollectionViewCell
    {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier:"videoCell", for:indexPath) as! VideoCell
        
        let video=relatedVideosArray[indexPath.row] as! Stream
        
        cell.durationLbl.layer.borderColor=UIColor.white.cgColor
        cell.durationLbl.text=video.duration
        cell.categoryNameLbl.text=video.category.uppercased()
        cell.videoYearLbl.text="\(video.year) | \(video.city)".uppercased()
        cell.videoTitleLbl.text=video.title.uppercased()
        cell.followersCountLbl.text=video.user.name.uppercased()
        cell.videoThumbnailImageView.sd_setImage(with:URL(string:"\(site)/thumb/\(video.id).jpg"), placeholderImage:UIImage(named:"videostream"))
        
        let cellRecognizer=UITapGestureRecognizer(target:self, action:#selector(cellTapped))
        cell.tag=indexPath.row
        cell.addGestureRecognizer(cellRecognizer)
        
        return cell
    }
    
    func cellTapped(gestureRecognizer:UITapGestureRecognizer)
    {
        delegate.relatedVideoDidSelected(gestureRecognizer.view!.tag)
    }
    
    func collectionView(_ collectionView:UICollectionView, willDisplayCell cell:UICollectionViewCell, forItemAtIndexPath indexPath:IndexPath)
    {
        if indexPath.row==relatedVideosArray.count-1&&isMoreData
        {
            fetchMore()
        }
    }
    
    func fetchMore()
    {
        page+=1
        StreamConnector().categoryStreams(false, true, categoryID, page, fetchMoreSuccess, failureStream)
    }
    
    func fetchMoreSuccess(data:NSDictionary)
    {
        if getData(data).count==0
        {
            isMoreData=false
            return
        }
        
        let temp=relatedVideosArray.mutableCopy() as! NSMutableArray
        temp.addObjects(from:getData(data) as [AnyObject])
        relatedVideosArray=temp
        collectionView.reloadData()
        delegate.updateRelatedVideosArray(temp)
    }
    
    func getData(_ data:NSDictionary)->NSMutableArray
    {
        let videos=data["data"] as! NSArray
        
        let moreRelatedVideosArray=NSMutableArray()
        
        for i in 0 ..< videos.count
        {
            let video=videos[i] as! NSDictionary
            
            let user=video["user"] as! NSDictionary
            
            let oneUser=User()
            oneUser.id=user["id"] as! Int
            oneUser.name=user["name"] as! String
            oneUser.avatar=user["avatar"] as? String
            
            let oneVideo=Stream()
            oneVideo.id=video["id"] as! Int
            oneVideo.vType=video["vtype"] as! Int
            oneVideo.videoID=video["streamkey"] as! String
            oneVideo.title=video["title"] as! String
            oneVideo.streamHash=video["hash"] as! String
            oneVideo.lon=video["lon"] as! Double
            oneVideo.lat=video["lat"] as! Double
            oneVideo.city=video["city"] as! String
            oneVideo.brand=video["brand"] as! String
            oneVideo.venue=video["venue"] as! String
            oneVideo.duration=video["duration"] as! String
            oneVideo.cid=video["cid"] as! Int
            oneVideo.category=video["category"] as! String
            oneVideo.PRAgency=video["pr_agency"] as! String
            oneVideo.musicAgency=video["music_agency"] as! String
            oneVideo.adAgency=video["ad_agency"] as! String
            oneVideo.talentAgency=video["talent_agency"] as! String
            oneVideo.eventAgency=video["event_agency"] as! String
            oneVideo.videoAgency=video["video_agency"] as! String
            oneVideo.year=video["year"] as! String
            oneVideo.videoDescription=video["description"] as! String
            
            if let e=video["ended"] as? String
            {
                oneVideo.ended=NSDate(timeIntervalSince1970:Double(e)!)
            }
            
            oneVideo.viewers=video["viewers"] as! Int
            oneVideo.tviewers=video["tviewers"] as! Int
            oneVideo.rviewers=video["rviewers"] as! Int
            oneVideo.likes=video["likes"] as! Int
            oneVideo.shares=video["sharecount"] as! Int
            oneVideo.comments=video["commentcount"] as! Int
            oneVideo.rlikes=video["rlikes"] as! Int
            oneVideo.user=oneUser
            
            moreRelatedVideosArray.add(oneVideo)
        }
        
        return moreRelatedVideosArray
    }
    
    func failureStream(error:NSError)
    {
        
    }
}
