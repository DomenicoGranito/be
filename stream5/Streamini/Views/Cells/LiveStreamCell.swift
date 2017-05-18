//
//  StreamCellTableViewCell.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/06/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import UIKit

class StreamCell: UITableViewCell {
    var stream: Stream?
    weak var userSelectedDelegate: UserSelecting?    
    
    func update(_ stream: Stream) {
        self.stream = stream
    }
}

class LiveStreamCell: StreamCell {
    @IBOutlet weak var streamImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var streamNameLabel: UILabel!
    @IBOutlet weak var streamLiveView: StreamLiveView!
    @IBOutlet weak var streamNameLabelHeight: NSLayoutConstraint!
    
    var userSelectingHandler: UserSelectingHandler?
    
    override func update(_ stream: Stream) {
        super.update(stream)
        
        self.backgroundColor = UIColor.black
        userLabel.text = stream.user.name        
        streamNameLabel.text = stream.title
        
        let expectedSize = streamNameLabel.sizeThatFits(CGSize(width: streamNameLabel.bounds.size.width, height: 10000))
        streamNameLabelHeight.constant = expectedSize.height > 75.0 ? 75.0 : expectedSize.height
        
        self.streamLiveView.setCount(stream.viewers)
        
        userImageView.sd_setImage(with: stream.user.avatarURL() as URL!)        
        streamImageView.sd_setImage(with: stream.urlToStreamImage() as URL!)

        if let delegate = userSelectedDelegate {
            self.userSelectingHandler = UserSelectingHandler(imageView: userImageView, delegate: delegate, user: stream.user)
        }
    }
}
