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
    @IBOutlet var followersCountLbl:UILabel!
    @IBOutlet var subscribeButton:UIButton!
    @IBOutlet var collectionView:UICollectionView!
    
    var user:User!
    var TBVC:TabBarViewController!
    var channelClassReference:ChannelsViewController!
    var userVideosArray:NSArray!
    let storyboard=UIStoryboard(name:"Main", bundle:nil)
    
    func update(_ user:User)
    {
        self.user=user
        
        subscribeButton.layer.borderColor=UIColor.white.cgColor
        
        userNameLbl.text=user.name
        followersCountLbl.text="\(user.followers) FOLLOWERS | \(user.streams) VIDEOS"
        userImageView.sd_setImage(with:user.avatarURL(), placeholderImage:UIImage(named:"profile"))
        
        subscribeStatus()
    }
    
    func subscribeStatus()
    {
        if user.isFollowed
        {
            subscribeButton.setTitle("Unfollow", for:.normal)
        }
        else
        {
            subscribeButton.setTitle("+ Follow", for:.normal)
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
        subscribeButton.setTitle("Unfollow", for:.normal)
        user.isFollowed=true
        let words=followersCountLbl.text!.components(separatedBy:" ")
        followersCountLbl.text="\(Int(words[0])!+1) FOLLOWERS | \(user.streams) VIDEOS"
    }
    
    func followFailure(_ error:NSError)
    {
        
    }
    
    func unfollowSuccess()
    {
        subscribeButton.setTitle("+ Follow", for:.normal)
        user.isFollowed=false
        let words=followersCountLbl.text!.components(separatedBy:" ")
        followersCountLbl.text="\(Int(words[0])!-1) FOLLOWERS | \(user.streams) VIDEOS"
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
        
        cell.categoryNameLbl.text=video.category.uppercased()
        cell.videoYearLbl.text="\(video.year) | \(video.city)".uppercased()
        cell.videoTitleLbl.text=video.title.uppercased()
        cell.followersCountLbl.text=video.user.name.uppercased()
        cell.videoThumbnailImageView.sd_setImage(with:URL(string:"\(video.imgUrl)"), placeholderImage:UIImage(named:"videostream"))
        
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
        playerVC.channelClassReference=channelClassReference
        
        TBVC.playerVC=playerVC
        TBVC.configure(stream)
    }
}
