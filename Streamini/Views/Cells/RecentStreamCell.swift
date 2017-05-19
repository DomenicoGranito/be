//
//  RecentStreamCell.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/07/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

class RecentStreamCell: StreamCell
{
    @IBOutlet var streamNameLabel: UILabel!
    @IBOutlet var userLabel: UILabel!
    //@IBOutlet var streamEndedLabel: UILabel!
    @IBOutlet var playImageView: UIImageView!
    //@IBOutlet var playWidthConstraint: NSLayoutConstraint!
    @IBOutlet var dotsButton:UIButton?
    
    override func update(_ stream:Stream)
    {
        let (host, _, _, _, _)=Config.shared.wowza()
        
        super.update(stream)
        playImageView.sd_setImage(with: NSURL(string:"http://\(host)/thumb/\(stream.id).jpg") as URL!)
        userLabel.text = stream.user.name
        streamNameLabel.text  = stream.title
        //streamEndedLabel.text = stream.ended!.timeAgoSimple
    }
    
    func updateMyStream(_ stream:Stream)
    {
        super.update(stream)
        
        userLabel.text = UserContainer.shared.logged().name
        
        //var isLessThan24Hours = false
        //if let date = stream.ended {
        //    isLessThan24Hours = NSDate().lessThan24Hours(date)
        //}
        
        //playImageView.hidden  = !isLessThan24Hours
        //self.userInteractionEnabled = isLessThan24Hours
        streamNameLabel.text  = stream.title
        
//        if let time = stream.ended {
//            streamEndedLabel.text = time.timeAgoSimple
//        } else {
//            streamEndedLabel.text = ""
//        }

        //playWidthConstraint.constant = (isLessThan24Hours) ? 24.0 : 0.0
        //self.layoutIfNeeded()
    }
    
    func calculateHeight() -> CGFloat
    {
        streamNameLabel.sizeToFit()
        return streamNameLabel.frame.size.height
    }
}
