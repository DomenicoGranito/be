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
    @IBOutlet var subscribeButton:UIButton!
    @IBOutlet var channelButton:UIButton!
    @IBOutlet var userNameLbl:UILabel!
    @IBOutlet var userImageView:UIImageView!
    
    var delegate:PlayerViewControllerDelegate!
    var stream:Stream!
    let storyboard=UIStoryboard(name:"Main", bundle:nil)
    
    func update(_ stream:Stream)
    {
        self.stream=stream
        
        subscribeButton.layer.borderColor=UIColor(red:231/255, green:206/255, blue:151/255, alpha:1).cgColor
        
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
        userNameLbl.text=stream.user.name
        userImageView.sd_setImage(with:stream.user.avatarURL(), placeholderImage:UIImage(named:"profile"))
        
        SongManager.addToRecentlyPlayed(stream.title, stream.streamHash, stream.id, stream.user.name, stream.videoID, stream.user.id)
        
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
        subscribeButton.setTitleColor(.white, for:.normal)
        subscribeButton.backgroundColor=UIColor(red:231/255, green:206/255, blue:151/255, alpha:1)
        delegate.updateSubscribeStatus(stream, true)
    }
    
    func followFailure(_ error:NSError)
    {
        
    }
    
    func unfollowSuccess()
    {
        subscribeButton.setTitle("+ Subscribe", for:.normal)
        subscribeButton.setTitleColor(UIColor(red:231/255, green:206/255, blue:151/255, alpha:1), for:.normal)
        subscribeButton.backgroundColor = .clear
        delegate.updateSubscribeStatus(stream, false)
    }
    
    func unfollowFailure(_ error:NSError)
    {
        
    }
    
    func subscribeStatus()
    {
        if stream.user.isFollowed
        {
            subscribeButton.setTitle("Subscribed", for:.normal)
            subscribeButton.setTitleColor(.white, for:.normal)
            subscribeButton.backgroundColor=UIColor(red:231/255, green:206/255, blue:151/255, alpha:1)
        }
        else
        {
            subscribeButton.setTitle("+ Subscribe", for:.normal)
        }
    }
}
