//
//  RecentStreamCell.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/07/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

class RecentStreamCell: StreamCell
{
    @IBOutlet var streamNameLabel:UILabel!
    @IBOutlet var userLabel:UILabel!
    @IBOutlet var playImageView:UIImageView!
    @IBOutlet var dotsButton:UIButton!
    
    override func update(_ stream:Stream)
    {
        let site=Config.shared.site()
        
        super.update(stream)
        playImageView.sd_setImage(with:URL(string:"\(site)/thumb/\(stream.id).jpg"), placeholderImage:UIImage(named:"stream"))
        userLabel.text=stream.user.name
        streamNameLabel.text=stream.title
    }
    
    func updateMyStream(_ stream:Stream)
    {
        super.update(stream)
        
        userLabel.text=UserContainer.shared.logged().name
        streamNameLabel.text=stream.title
    }
    
    func calculateHeight()->CGFloat
    {
        streamNameLabel.sizeToFit()
        return streamNameLabel.frame.size.height
    }
}
