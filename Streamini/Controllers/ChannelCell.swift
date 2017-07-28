//
//  ChannelCell.swift
//  BEINIT
//
//  Created by Ankit Garg on 7/28/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class ChannelCell: UITableViewCell
{
    @IBOutlet var userImageView:UIImageView!
    @IBOutlet var userNameLbl:UILabel!
    @IBOutlet var subscribeButton:UIButton!
    @IBOutlet var collectionView:UICollectionView!
    
    var TBVC:TabBarViewController!
    var channelVideosArray:NSArray!
    let site=Config.shared.site()
    let storyboard=UIStoryboard(name:"Main", bundle:nil)
    
    func update(_ user:User)
    {
        userNameLbl.text=user.name
        userImageView.sd_setImage(with:user.avatarURL(), placeholderImage:UIImage(named:"profile"))
    }
    
    func reloadCollectionView()
    {
        collectionView!.reloadData()
    }

    func collectionView(_ collectionView:UICollectionView, numberOfItemsInSection section:Int)->Int
    {
        return channelVideosArray.count
    }
    
    func collectionView(_ collectionView:UICollectionView, cellForItemAtIndexPath indexPath:IndexPath)->UICollectionViewCell
    {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier:"videoCell", for:indexPath) as! VideoCell
        
        let video=channelVideosArray[indexPath.row] as! Stream
        
        cell.videoTitleLbl?.text=video.title
        cell.followersCountLbl?.text=video.user.name
        cell.videoThumbnailImageView?.sd_setImage(with:URL(string:"\(site)/thumb/\(video.id).jpg"), placeholderImage:UIImage(named:"videostream"))
        
        let cellRecognizer=UITapGestureRecognizer(target:self, action:#selector(cellTapped))
        cell.tag=indexPath.row
        cell.addGestureRecognizer(cellRecognizer)
        
        return cell
    }
    
    func cellTapped(gestureRecognizer:UITapGestureRecognizer)
    {
        let modalVC=storyboard.instantiateViewController(withIdentifier:"ModalViewController") as! ModalViewController
        
        let stream=channelVideosArray[gestureRecognizer.view!.tag] as! Stream
        
        let streamsArray=NSMutableArray()
        streamsArray.add(stream)
        
        modalVC.streamsArray=streamsArray
        modalVC.TBVC=TBVC
        
        TBVC.modalVC=modalVC
        TBVC.configure(stream)
    }
}
