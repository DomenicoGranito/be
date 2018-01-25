//
//  AboutVideoCell.swift
//  Streamini
//
//  Created by Ankit Garg on 1/4/18.
//  Copyright © 2018 Cedricm Video. All rights reserved.
//

class AboutVideoCell: UITableViewCell
{
    @IBOutlet var videoTitleLbl:UILabel!
    @IBOutlet var categoryLbl:UILabel!
    @IBOutlet var viewersCountAndUploadedAgoLbl:UILabel!
    @IBOutlet var uploadedDateLbl:UILabel!
    @IBOutlet var videoDescriptionTextView:UITextView!
    @IBOutlet var cityLbl:UILabel!
    @IBOutlet var yearLbl:UILabel!
    @IBOutlet var brandLbl:UILabel!
    @IBOutlet var venueLbl:UILabel!
    @IBOutlet var PRAgencyLbl:UILabel!
    @IBOutlet var musicAgencyLbl:UILabel!
    @IBOutlet var adAgencyLbl:UILabel!
    @IBOutlet var eventAgencyLbl:UILabel!
    @IBOutlet var videoAgencyLbl:UILabel!
    @IBOutlet var talentAgencyLbl:UILabel!
    @IBOutlet var likeCountLbl:UILabel!
    @IBOutlet var shareCountLbl:UILabel!
    @IBOutlet var commentCountLbl:UILabel!
    @IBOutlet var likeButton:UIButton!
    @IBOutlet var shareButton:UIButton!
    @IBOutlet var playlistButton:UIButton!
    @IBOutlet var subscribeButton:UIButton!
    @IBOutlet var userNameLbl:UILabel!
    @IBOutlet var userImageView:UIImageView!
    
    var stream:Stream!
    let storyboard=UIStoryboard(name:"Main", bundle:nil)
    
    func update(_ stream:Stream)
    {
        self.stream=stream
        
        subscribeButton.layer.borderColor=UIColor(red:190/255, green:142/255, blue:64/255, alpha:1).cgColor
        
        videoTitleLbl.text=stream.title
        categoryLbl.text=stream.category
        viewersCountAndUploadedAgoLbl.text="\(stream.viewers) Views | Uploaded 1 month ago"
        uploadedDateLbl.text="Jul 21, 2017"
        videoDescriptionTextView.text=stream.videoDescription
        cityLbl.text=stream.city
        yearLbl.text=stream.year
        brandLbl.text=stream.brand
        venueLbl.text=stream.venue
        PRAgencyLbl.text=stream.PRAgency
        musicAgencyLbl.text=stream.musicAgency
        adAgencyLbl.text=stream.adAgency
        eventAgencyLbl.text=stream.eventAgency
        videoAgencyLbl.text=stream.videoAgency
        talentAgencyLbl.text=stream.talentAgency
        likeCountLbl.text="\(stream.likes)"
        shareCountLbl.text="\(stream.shares)"
        commentCountLbl.text="\(stream.comments)"
        userNameLbl.text=stream.user.name
        userImageView.sd_setImage(with:stream.user.avatarURL(), placeholderImage:UIImage(named:"profile"))
        
        SongManager.addToRecentlyPlayed(stream.title, stream.streamHash, stream.id, stream.user.name, stream.videoID, stream.user.id)
        
        songLikeStatus()
        subscribeStatus()
    }
    
    @IBAction func subscribe()
    {
        if stream.user.isFollowed
        {
            SocialConnector().unfollow(stream.user.id, unfollowSuccess, unfollowFailure)
        }
        else
        {
            SocialConnector().follow(stream.user.id, followSuccess, followFailure)
        }
    }
    
    func followSuccess()
    {
        subscribeButton.setTitle("Subscribed", for:.normal)
        subscribeButton.setTitleColor(UIColor.white, for:.normal)
        subscribeButton.backgroundColor=UIColor(red:190/255, green:142/255, blue:64/255, alpha:1)
    }
    
    func followFailure(_ error:NSError)
    {
        
    }
    
    func unfollowSuccess()
    {
        subscribeButton.setTitle("+ Subscribe", for:.normal)
        subscribeButton.setTitleColor(UIColor(red:190/255, green:142/255, blue:64/255, alpha:1), for:.normal)
        subscribeButton.backgroundColor=UIColor.clear
    }
    
    func unfollowFailure(_ error:NSError)
    {
        
    }
    
    @IBAction func like()
    {
        if SongManager.isAlreadyFavourited(stream.id)
        {
            likeCountLbl.text="\(Int(likeCountLbl.text!)!-1)"
            likeButton.setImage(UIImage(named:"empty_heart"), for:.normal)
            SongManager.removeFromFavourite(stream.id)
        }
        else
        {
            likeCountLbl.text="\(Int(likeCountLbl.text!)!+1)"
            likeButton.setImage(UIImage(named:"red_heart"), for:.normal)
            SongManager.addToFavourite(stream.title, stream.streamHash, stream.id, stream.user.name, stream.vType, stream.videoID, stream.user.id)
        }
    }
    
    func songLikeStatus()
    {
        if SongManager.isAlreadyFavourited(stream.id)
        {
            likeButton.setImage(UIImage(named:"red_heart"), for:.normal)
        }
        else
        {
            likeButton.setImage(UIImage(named:"empty_heart"), for:.normal)
        }
    }
    
    func subscribeStatus()
    {
        if stream.user.isFollowed
        {
            subscribeButton.setTitle("Subscribed", for:.normal)
        }
        else
        {
            subscribeButton.setTitle("+ Subscribe", for:.normal)
        }
    }
}
