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
    @IBOutlet var subscribeButton:UIButton!
    @IBOutlet var userNameLbl:UILabel!
    @IBOutlet var userImageView:UIImageView!
    
    func update(_ stream:Stream)
    {
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
    }
}
