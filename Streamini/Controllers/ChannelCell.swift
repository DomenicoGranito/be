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
    
    var user:User!
    var TBVC:TabBarViewController!
    var userVideosArray:NSArray!
    let site=Config.shared.site()
    let storyboard=UIStoryboard(name:"Main", bundle:nil)
    
    func update(_ user:User)
    {
        self.user=user
        
        subscribeButton.layer.borderColor=UIColor(red:231/255, green:206/255, blue:151/255, alpha:1).cgColor
        
        userNameLbl.text=user.name
        userImageView.sd_setImage(with:user.avatarURL(), placeholderImage:UIImage(named:"profile"))
        
        subscribeStatus()
    }
    
    func subscribeStatus()
    {
        if user.isFollowed
        {
            subscribeButton.setTitle("Subscribed", for:.normal)
            subscribeButton.setTitleColor(UIColor.white, for:.normal)
            subscribeButton.backgroundColor=UIColor(red:231/255, green:206/255, blue:151/255, alpha:1)
        }
        else
        {
            subscribeButton.setTitle("+ Subscribe", for:.normal)
            subscribeButton.setTitleColor(UIColor(red:231/255, green:206/255, blue:151/255, alpha:1), for:.normal)
            subscribeButton.backgroundColor=UIColor.clear
        }
    }
    
    @IBAction func subscribe()
    {
        if user.isFollowed
        {
            SocialConnector().unfollow(user.id, unfollowSuccess, unfollowFailure)
        }
        else
        {
            SocialConnector().follow(user.id, followSuccess, followFailure)
        }
    }
    
    func followSuccess()
    {
        subscribeButton.setTitle("Subscribed", for:.normal)
        subscribeButton.setTitleColor(UIColor.white, for:.normal)
        subscribeButton.backgroundColor=UIColor(red:231/255, green:206/255, blue:151/255, alpha:1)
    }
    
    func followFailure(_ error:NSError)
    {
        
    }
    
    func unfollowSuccess()
    {
        subscribeButton.setTitle("+ Subscribe", for:.normal)
        subscribeButton.setTitleColor(UIColor(red:231/255, green:206/255, blue:151/255, alpha:1), for:.normal)
        subscribeButton.backgroundColor=UIColor.clear
    }
    
    func unfollowFailure(_ error:NSError)
    {
        
    }
    
    func reloadCollectionView()
    {
        collectionView!.reloadData()
    }

    func collectionView(_ collectionView:UICollectionView, numberOfItemsInSection section:Int)->Int
    {
        return userVideosArray.count
    }
    
    func collectionView(_ collectionView:UICollectionView, cellForItemAtIndexPath indexPath:IndexPath)->UICollectionViewCell
    {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier:"videoCell", for:indexPath) as! VideoCell
        
        let video=userVideosArray[indexPath.row] as! Stream
        
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
        let playerVC=storyboard.instantiateViewController(withIdentifier:"PlayerViewController") as! PlayerViewController
        
        let stream=userVideosArray[gestureRecognizer.view!.tag] as! Stream
        
        playerVC.stream=stream
        playerVC.TBVC=TBVC
        
        TBVC.playerVC=playerVC
        TBVC.configure(stream)
    }
}
