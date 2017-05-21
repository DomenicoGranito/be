//
//  StreamCellTableViewCell.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/06/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

class SearchStreamCell: StreamCell
{
    @IBOutlet var streamImageView:UIImageView!
    @IBOutlet var userLabel:UILabel!
    @IBOutlet var streamNameLabel:UILabel!
    @IBOutlet var dotsButton:UIButton?
    
    var userSelectingHandler:UserSelectingHandler?
    let (host, _, _, _, _)=Config.shared.wowza()
    
    override func update(_ stream:Stream)
    {
        userLabel.text=stream.user.name
        streamNameLabel.text=stream.title
        streamImageView.sd_setImage(with:URL(string:"http://\(host)/thumb/\(stream.id).jpg"), placeholderImage:UIImage(named:"stream"))
    }
}
