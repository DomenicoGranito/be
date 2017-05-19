//
//  JoinStreamViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 14/07/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

class JoinStreamViewController: BaseViewController, UITextFieldDelegate, UITableViewDelegate, UIAlertViewDelegate,
UIActionSheetDelegate, SelectFollowersDelegate, ReplayViewDelegate, UserSelecting, CollectionViewPullDelegate {
    @IBOutlet weak var infoView: InfoView!
    
    @IBOutlet weak var playerView: PlayerView!
    
    @IBOutlet weak var replayView: ReplayView!
    
    @IBOutlet weak var closeButton: SensibleButton!
    @IBOutlet weak var infoButton: SensibleButton!
    @IBOutlet weak var eyeButton: SensibleButton!
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var likeView: UIView!
    
    @IBOutlet weak var viewersLabel: UILabel!
    @IBOutlet weak var viewersLabelBottomConstraint: NSLayoutConstraint!    // 8 by default
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageTextViewRightConstraint: NSLayoutConstraint! // 43 by default
    @IBOutlet weak var messageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageViewBottomConstraint: NSLayoutConstraint!     // 8 by default
    
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var commentsTableViewHeight: NSLayoutConstraint!     // 360 by default
    @IBOutlet weak var viewersCollectionViewHeight: NSLayoutConstraint! // 58 by default
    @IBOutlet weak var viewersCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var likesViewBottom: NSLayoutConstraint! // 16
    @IBOutlet weak var viewersBottom: NSLayoutConstraint! // 16
    @IBOutlet weak var replaysBottom: NSLayoutConstraint! // 16
    
    var commentsDataSource  = CommentsDataSource()
    var viewersDataSource   = ViewersDataSource()
    var viewersDelegate     = ViewersDelegate()
    let animator            = HeartBounceAnimator()
    var likes: UInt         = 0
    var isRecent            = true
    var messenger:Messenger?
    var keyboardHandler: JoinStreamKeyboardHandler?
    var infoViewDelegate: JoinInfoViewDelegate?
    var streamPlayer: StreamPlayer?
    var stream: Stream?
    var textViewHandler: GrowingTextViewHandler?
    
    var page: UInt = 0
    
    // MARK: - Actions
    
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        closeButton.isEnabled = false
                
        if streamPlayer != nil {
            StreamConnector().leave(stream!.id, likes, leaveSuccess, leaveFailure)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func closeStream() {
        if streamPlayer != nil {
            StreamConnector().leave(stream!.id, likes, leaveWithAlertSuccess, leaveFailure)
        } else {
            UIAlertView.streamClosedAlert(nil).show()
        }
    }
    
    @IBAction func infoButtonPressed(_ sender: AnyObject) {
        infoView.show(false)
    }
    
    @IBAction func viewersButtonPressed(_ sender: AnyObject) {
        if self.viewersCollectionViewHeight.constant == 58.0 {
            self.viewersDataSource.viewers = []
            self.viewersCollectionView.reloadData()
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.viewersCollectionViewHeight.constant = 0.0
                self.likesViewBottom.constant   = 16.0
                self.viewersBottom.constant     = 16.0
                self.replaysBottom.constant     = 16.0
                
                self.view.layoutIfNeeded()
            }, completion: { (finished) -> Void in
                
            })
            
        } else {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.viewersCollectionViewHeight.constant = 58.0
                self.likesViewBottom.constant   = 58.0 + 16.0
                self.viewersBottom.constant     = 58.0 + 16.0
                self.replaysBottom.constant     = 58.0 + 16.0
                
                self.view.layoutIfNeeded()
            })
            StreamConnector().viewers(NSDictionary(object: stream!.id, forKey: "streamId" as NSCopying), viewersSuccess, failureWithoutAction)
        }
    }
    
    @IBAction func authorImageViewPressed(_ sender: AnyObject) {
        //self.showUserInfo(stream!.user, userStatusDelegate: nil)
    }
    
    @IBAction func tapGesturePerformed(_ sender: AnyObject) {
        if messageTextView.isFirstResponder {
            messageTextView.resignFirstResponder()
        } else {
            likes += 1
            messenger!.send(Message.like(), streamId: stream!.id)
        }
    }
    
    @IBAction func closeKeyboardButtonPerformed(_ sender: AnyObject) {
        messageTextView.resignFirstResponder()
    }
    
    // MARK: - ReplayViewDelegate
    
    func replayViewWillBeShown(_ replayView: ReplayView) {
        replayView.update(stream!)
        closeButton.isHidden      = true
        infoButton.isHidden       = true
        messageTextView.isHidden  = true
        messageTextView.resignFirstResponder()
    }
    
    func replayViewStreamDidEnd(_ replayView: ReplayView) {
        StreamConnector().leave(stream!.id, 0, leaveAnother, leaveFailure)
    }
    
    func replayViewWillBeHidden(_ replayView: ReplayView) {
        closeButton.isHidden      = false
        infoButton.isHidden       = false
        messageTextView.isHidden  = false
    }
    
    func replayViewPlayButtonPressed(_ replayView: ReplayView) {
        if self.viewersCollectionViewHeight.constant == 58.0 {
            viewersButtonPressed(eyeButton)
        }
        
        StreamConnector().join(stream!.id, joinSuccess, joinFailure)
    }
    
    func replayViewCloseButtonPressed(_ replayView: ReplayView) {
        if let player = streamPlayer {
            player.reset()
        }
        self.dismiss(animated: true, completion: nil)
    }
        
    func replayViewViewersButtonPressed(_ replayView: ReplayView) {
        
        if self.viewersCollectionViewHeight.constant == 58.0 && replayView.viewersIsShown {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.viewersCollectionViewHeight.constant = 0.0
                self.likesViewBottom.constant   = 16.0
                self.viewersBottom.constant     = 16.0
                self.replaysBottom.constant     = 16.0
                
                self.view.layoutIfNeeded()
                }) { (completed) -> Void in
            }
        } else {
            page = 0
            StreamConnector().viewers(NSDictionary(object: stream!.id, forKey: "streamId" as NSCopying), viewersSuccess, failureWithoutAction)
        }
    }
    
    func replayViewReplaysButtonPressed(_ replayView: ReplayView) {
        if self.viewersCollectionViewHeight.constant == 58.0 && replayView.replaysIsShown {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.viewersCollectionViewHeight.constant = 0.0
                self.likesViewBottom.constant   = 16.0
                self.viewersBottom.constant     = 16.0
                self.replaysBottom.constant     = 16.0
                
                self.view.layoutIfNeeded()
                }) { (completed) -> Void in
            }
        } else {
            page = 0
            StreamConnector().replayViewers(NSDictionary(object: stream!.id, forKey: "streamId" as NSCopying), viewersSuccess, failureWithoutAction)
        }
    }
    
    // MARK: - SelectFollowersDelegate
    
    func followersDidSelected(_ users: [User]) {
        let usersId = users.map({ $0.id })
        StreamConnector().share(stream!.id, usersId, successWithoutAction, failureWithoutAction)
    }
    
    // MARK: - UIActionSheetDelegate
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1 {
            StreamConnector().share(stream!.id, nil, successWithoutAction, failureWithoutAction)
        }
        if buttonIndex == 2 {
            self.performSegue(withIdentifier: "JoinToFollowers", sender: self)
        }
    }
    
    // MARK: - UIAlertViewDelegate
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != alertView.cancelButtonIndex {
            StreamConnector().report(stream!.id, successWithoutAction, failureWithoutAction)
        }
    }
    
    // MARK: - Update counter
    
    func updateCounter() {
        StreamConnector().get(stream!.id, getStreamSuccess, failureWithoutAction)
    }
    
    // MARK: - Block Stream
    
    func blockStream(_ userId: UInt) {
        if userId == UserContainer.shared.logged().id {
            UIAlertView.userBlockedAlert().show()
            if streamPlayer != nil {
                StreamConnector().leave(stream!.id, likes, leaveSuccess, leaveFailure)
            }
        }
    }
    
    // MARK: - Network Responses
    
    func successWithoutAction() {
    }
    
    func failureWithoutAction(_ error: NSError) {
        handleError(error)
    }
    
    func viewersSuccess(_ likes: UInt, viewers: UInt, users: [User]) {
        viewersDataSource.viewers = users
        
        self.viewersCollectionView.reloadData()
        
        
    }
    
    func moreViewersSuccess(_ likes: UInt, viewers: UInt, users: [User]) {
        viewersDataSource.viewers = viewersDataSource.viewers + users
        self.viewersCollectionView.reloadData()
    }
    
    func chatMessageReceived(_ message: Message) {
        if let messageController = MessageController.getMessageControllerForJoin(message.type, viewController: self) {
            messageController.handle(message)
        }
    }
    
    func joinSuccess() {
        // Play stream
        if !isRecent {
            streamPlayer = StreamPlayer(stream: stream!, isRecent: isRecent, view: previewView, indicator: activityIndicator)
            self.streamPlayer!.delegate = DefaultStreamPlayerDelegate(isRecent: isRecent, replayView: replayView)
            
            //messenger = MessengerFactory.getMessenger("pubnub")!
            //messenger!.connect(stream!.id)
            //messenger!.receive(chatMessageReceived)
            //messenger!.send(Message.connected(), streamId: stream!.id)
        } else {
            streamPlayer!.play()
            replayView.hide(true)
            
            infoButton.isHidden       = false
            messageTextView.isHidden  = true
        }
        
      //  messenger = MessengerFactory.getMessenger("pubnub")!
      //  messenger!.connect(stream!.id)
      //  messenger!.receive(chatMessageReceived)
      //  messenger!.send(Message.connected(), streamId: stream!.id)
    }
    
    func joinFailure(_ error: NSError) {
        self.activityIndicator.stopAnimating()
        handleError(error)
        
        if let userInfo = error.userInfo as? [String:NSObject]
        {
            let code=userInfo["code"] as! UInt
            
            if code==Error.kUserBlocked
            {
                UIAlertView.userBlockedAlert().show()
                self.dismiss(animated: true, completion: nil)
            }
        }
        else
        {
            UIAlertView.failedJoinStreamAlert().show()
        }
    }
    
    func leaveSuccess() {
        leaveSilentSuccess()
        self.dismiss(animated: true, completion: nil)
    }
    
    func leaveWithAlertSuccess() {
        leaveSilentSuccess()
        UIAlertView.streamClosedAlert(nil).show()
    }
    
    func leaveSilentSuccess() {
        if let mes = messenger {
            mes.send(Message.disconnected(), streamId: stream!.id)
            mes.disconnect(stream!.id)
        }
        likes = 0
        streamPlayer!.stop()
        streamPlayer = nil
    }
    
    func leaveAnother() {
        replayView.update(stream!)
        closeButton.isHidden      = true
        infoButton.isHidden       = true
        messageTextView.isHidden  = true
        messageTextView.resignFirstResponder()

        if let mes = messenger {
            mes.send(Message.disconnected(), streamId: stream!.id)
            mes.disconnect(stream!.id)
        }
        
        likes = 0
        streamPlayer!.stop()
    }
    
    func leaveFailure(_ error: NSError) {
        handleError(error)
        closeButton.isEnabled = true
    }
    
    func getStreamSuccess(_ stream: Stream) {
        self.stream = stream
        infoViewDelegate!.stream = stream
        viewersLabel.text = "\(stream.tviewers)"
    }
    
    // MARK: - Handle notifications
    
    func forceLeave(_ notification: NSNotification) {
        if streamPlayer != nil {
            StreamConnector().leave(stream!.id, likes, leaveSilentSuccess, leaveFailure)
            if let mes = messenger {
                mes.send(Message.disconnected(), streamId: stream!.id)
                mes.disconnect(stream!.id)
            }            
        }
    }
    
    // MARK: - UserSelecting protocol
    
    func userDidSelected(_ user: User) {
        //self.showUserInfo(user, userStatusDelegate: nil)
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()

        NotificationCenter.default.addObserver(self, selector: #selector(JoinStreamViewController.forceLeave(_:)), name: NSNotification.Name(rawValue: "Close/Leave"), object: nil)
        if !isRecent {
            StreamConnector().join(stream!.id, joinSuccess, joinFailure)
        } else {
            streamPlayer = StreamPlayer(stream: stream!, isRecent: isRecent, view: previewView, indicator: activityIndicator)
            self.streamPlayer!.delegate = DefaultStreamPlayerDelegate(isRecent: isRecent, replayView: replayView)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.setNavigationBarHidden(true, animated: true)
        keyboardHandler!.register()
        UIApplication.shared.setStatusBarHidden(true, with: .fade)
        
        let app = UIApplication.shared.delegate as! AppDelegate
        app.closeStream = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isRecent {
            messageTextViewRightConstraint.constant = 8.0
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let navController = navigationController {
            navController.setNavigationBarHidden(false, animated: true)
        }
        keyboardHandler!.unregister()
        
        let app = UIApplication.shared.delegate as! AppDelegate
        app.closeStream = false
    }
    
    func configureView() {        
        closeButton.setImageTintColor(UIColor(white: 1.0, alpha: 1.0), for: UIControlState.normal)
        closeButton.setImageTintColor(UIColor(white: 1.0, alpha: 0.5), for: UIControlState.highlighted)
        infoButton.setImageTintColor(UIColor(white: 1.0, alpha: 0.7), for: UIControlState.normal)
        infoButton.setImageTintColor(UIColor(white: 1.0, alpha: 1.0), for: UIControlState.highlighted)
        eyeButton.setImageTintColor(UIColor(white: 1.0, alpha: 0.7), for: UIControlState.normal)
        eyeButton.setImageTintColor(UIColor(white: 1.0, alpha: 1.0), for: UIControlState.highlighted)
        
        commentsDataSource.userSelectedDelegate = self
        commentsTableView.delegate = commentsDataSource
        commentsTableView.dataSource = commentsDataSource
        commentsTableView.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI))

        messageTextView.tintColor = UIColor(white: 1.0, alpha: 1.0)
        var messageTextViewFrame = messageTextView.frame
        messageTextViewFrame.size.height = 39.0
        messageTextView.frame = messageTextViewFrame
        
        self.textViewHandler = GrowingTextViewHandler(textView: messageTextView, withHeightConstraint: messageViewHeightConstraint)
        textViewHandler!.updateMinimumNumber(ofLines: 1, andMaximumNumberOfLine: 3)
        textViewHandler!.setText("", withAnimation: false)
        
        viewersDataSource.userSelectedDelegate = self
        viewersDelegate.pullDelegate     = self
        viewersCollectionView.dataSource = viewersDataSource
        viewersCollectionView.delegate   = viewersDelegate
        
        self.replayView.delegate    = self
        self.replayView.hide(false)
        
        infoViewDelegate = JoinInfoViewDelegate(close: closeButton, info: infoButton, alertViewDelegate: self, actionSheetDelegate: self, actionSheetView: self.view)
        infoViewDelegate!.stream = stream
        self.infoView.delegate = infoViewDelegate!
        self.infoView.userSelectingDelegate = self
        
        keyboardHandler = JoinStreamKeyboardHandler(
            view: view,
            messageTextView: messageTextView,
            commentsTableView: commentsTableView,
            commentsTableViewHeight: commentsTableViewHeight,
            viewersCollectionViewHeight: viewersCollectionViewHeight,
            messageViewBottomConstraint: messageViewBottomConstraint,
            messageTextViewRightConstraint: messageTextViewRightConstraint,
            viewersLabelBottomConstraint: viewersLabelBottomConstraint,
            viewersLabel: viewersLabel,
            eyeButton: eyeButton,
            isRecent: isRecent
        )
        
        if isRecent {
            infoButton.isHidden                       = true
            messageTextView.isHidden                  = true
            viewersLabel.isHidden                     = true
            viewersLabel.backgroundColor            = UIColor.red
            eyeButton.isHidden                        = true
            self.view.layoutIfNeeded()
        }
        
    }
    
    override func prepare(for segue:UIStoryboardSegue, sender:Any?)
    {
        if let sid = segue.identifier
        {
            if sid == "JoinToFollowers"
            {
                let controller = segue.destination as! FollowersViewController
                controller.delegate = self
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    {
        if text == "\n"
        {
            if textView.text.trimmingCharacters(in:NSCharacterSet.whitespacesAndNewlines).isEmpty
            {
                return false
            }
            messenger!.send(Message.create(textView.text), streamId: stream!.id)
            textViewHandler!.setText("", withAnimation: false)
            return false
        }
        
        let term = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return term.characters.count <= 140
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        messenger!.send(Message.create(textField.text!), streamId: stream!.id)
        textField.text = ""
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
//        textView.text = textView.text.handleEmoji()
        self.textViewHandler!.resizeTextView(withAnimation: true)
    }
    
    func collectionViewDidBeginPullingLeft(_ collectionView: UIScrollView, offset: CGFloat) {
        let data = NSDictionary(objects: [stream!.id, page+=1], forKeys: ["streamId" as NSCopying, "p" as NSCopying])
        if replayView.viewersIsShown {
            StreamConnector().viewers(data, moreViewersSuccess, failureWithoutAction)
        }
        if replayView.replaysIsShown {
            StreamConnector().replayViewers(data, moreViewersSuccess, failureWithoutAction)
        }
    }
}
