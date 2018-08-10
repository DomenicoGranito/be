//
//  AboutVideoCell.swift
//  Streamini
//
//  Created by Ankit Garg on 1/4/18.
//  Copyright © 2018 Cedricm Video. All rights reserved.
//

protocol PlayerViewControllerDelegate
{
    func updateSubscribeStatus(_ stream:Stream, _ isFollowed:Bool)
}

class AboutVideoCell: UITableViewCell
{
    @IBOutlet var videoTitleLbl:UILabel!
    @IBOutlet var categoryLbl:UILabel!
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
    @IBOutlet var subscribeButton:UIButton!
    @IBOutlet var channelButton:UIButton!
    @IBOutlet var userNameLbl:UILabel!
    @IBOutlet var followersCountLbl:UILabel!
    @IBOutlet var userImageView:UIImageView!
    @IBOutlet var likeButton:UIButton!
    @IBOutlet var shareButton:UIButton!
    @IBOutlet var expandButton:UIButton!
    @IBOutlet var infoView:UIView!
    
    var delegate:PlayerViewControllerDelegate!
    var stream:Stream!
    let storyboard=UIStoryboard(name:"Main", bundle:nil)
    
    func update(_ stream:Stream)
    {
        self.stream=stream
        
        subscribeButton.layer.borderColor=UIColor.white.cgColor
        
        videoTitleLbl.text=stream.title.uppercased()
        videoTitleLbl.addCharacterSpacing()
        categoryLbl.text=stream.category.uppercased()
        categoryLbl.addCharacterSpacing()
        cityLbl.text=stream.city=="" ? "NA" : stream.city
        yearLbl.text=stream.year=="" ? "NA" : stream.year
        brandLbl.text=stream.brand=="" ? "NA" : stream.brand
        venueLbl.text=stream.venue=="" ? "NA" : stream.venue
        PRAgencyLbl.text=stream.PRAgency=="" ? "NA" : stream.PRAgency
        musicAgencyLbl.text=stream.musicAgency=="" ? "NA" : stream.musicAgency
        adAgencyLbl.text=stream.adAgency=="" ? "NA" : stream.adAgency
        eventAgencyLbl.text=stream.eventAgency=="" ? "NA" : stream.eventAgency
        videoAgencyLbl.text=stream.videoAgency=="" ? "NA" : stream.videoAgency
        talentAgencyLbl.text=stream.talentAgency=="" ? "NA" : stream.talentAgency
        userNameLbl.text=stream.user.name.uppercased()
        followersCountLbl.text="FOLLOWERS \(stream.user.followers)"
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
        subscribeButton.setTitle("Unfollow", for:.normal)
        delegate.updateSubscribeStatus(stream, true)
    }
    
    func followFailure(_ error:NSError)
    {
        
    }
    
    func unfollowSuccess()
    {
        subscribeButton.setTitle("+ Follow", for:.normal)
        delegate.updateSubscribeStatus(stream, false)
    }
    
    func unfollowFailure(_ error:NSError)
    {
        
    }
    
    @IBAction func like()
    {
        if SongManager.isAlreadyFavourited(stream.id)
        {
            likeButton.setImage(UIImage(named:"empty_heart"), for:.normal)
            SongManager.removeFromFavourite(stream.id)
        }
        else
        {
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
            subscribeButton.setTitle("Unfollow", for:.normal)
        }
        else
        {
            subscribeButton.setTitle("+ Follow", for:.normal)
        }
    }
}
