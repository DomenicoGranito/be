//
//  PlayerView.swift
//  BEINIT
//
//  Created by Dominic Granito on 5/12/2016.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//


import UIKit

protocol PlayerViewDelegate: class {
    func playerViewWillBeShown(_ playerView: PlayerView)
    func playerViewWillBeHidden(_ playerView: PlayerView)
    func reportButtonPressed()
    func shareButtonPressed()
}

class PlayerView: UIView {
    @IBOutlet weak var streamNameLabel: UILabel!
    @IBOutlet weak var streamNameHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    var stream: Stream?
    weak var delegate: PlayerViewDelegate?
    weak var userSelectingDelegate: UserSelecting?
    var userSelectingHandler: UserSelectingHandler?
    
    // MAKR: - View life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = false
        
        shareButton.addTarget(self, action: #selector(PlayerView.shareButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        reportButton.addTarget(self, action: #selector(PlayerView.reportButtonPressed(_:)), for: UIControlEvents.touchUpInside)
    }
    
    // MARK: - Actions
    
    @IBAction func tapGesturePerformed(_ sender: AnyObject) {
        self.hide()
    }
    
    func shareButtonPressed(_ sender: UIButton) {
        if let del = self.delegate {
            del.shareButtonPressed()
        }
    }
    
    func reportButtonPressed(_ sender: UIButton) {
        if let del = self.delegate {
            del.reportButtonPressed()
        }
    }
    
    // MARK: - Show/hide methods
    
    func show(_ isOwner: Bool) {
        shareButton.isHidden  = isOwner
        reportButton.isHidden = isOwner
        self.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.alpha = 1.0
        })
        
        if let del = delegate {
            del.playerViewWillBeShown(self)
        }
    }
    
    func hide() {
        self.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.alpha = 0.0
        })
        
        if let del = delegate {
            del.playerViewWillBeHidden(self)
        }
    }
    
    // MARK: - Update data
    
    func update(_ stream: Stream) {
        func setupButton(_ button: UIButton, image: UIImage, title: String, top: CGFloat) {
            button.setImage(image, for: UIControlState())
            button.titleEdgeInsets = UIEdgeInsetsMake(0, 15.0, 0.0, 0.0)
            button.imageEdgeInsets = UIEdgeInsetsMake(top, 0.0, 0.0, 0.0)
            button.setTitle(title, for: UIControlState())
            button.setImageTintColor(UIColor(white: 1.0, alpha: 1.0), for: UIControlState())
            button.setImageTintColor(UIColor(white: 1.0, alpha: 0.5), for: UIControlState.highlighted)
            button.setTitleColor(UIColor(white: 1.0, alpha: 1.0), for: UIControlState())
            button.setTitleColor(UIColor(white: 1.0, alpha: 0.5), for: UIControlState.highlighted)
        }
        
        self.stream = stream
        
        if let del = userSelectingDelegate {
            self.userSelectingHandler = UserSelectingHandler(imageView: userImageView, delegate: del, user: stream.user)
        }
        
        streamNameLabel.text = stream.title
        let expectedSize = streamNameLabel.sizeThatFits(CGSize(width: streamNameLabel.bounds.size.width, height: 10000))
        streamNameHeightConstraint.constant = expectedSize.height
        
        if !stream.city.isEmpty {
            locationLabel.text = stream.city
            
            let size = locationLabel.sizeThatFits(locationLabel.bounds.size)
            locationWidthConstraint.constant = size.width + 10
            locationLabel.isHidden = false
        }
        
        usernameLabel.text = stream.user.name
        
        userImageView.sd_setImage(with: stream.user.avatarURL() as URL!)
        
        let shareText = NSLocalizedString("stream_info_share_button", comment: "")
        setupButton(shareButton, image: UIImage(named: "share")!, title: shareText, top: -5.0)
        
        let reportText = NSLocalizedString("stream_info_report_button", comment: "")
        setupButton(reportButton, image: UIImage(named: "report")!, title: reportText, top: 0.0)
        
        self.layoutIfNeeded()
    }
}
