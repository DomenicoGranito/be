//
//  PlaylistViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 4/15/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class PlaylistViewController: ARNModalImageTransitionViewController, ARNImageTransitionZoomable
{
    @IBOutlet var backgroundImageView:UIImageView!
    @IBOutlet var headerTitleLbl:UILabel!
    @IBOutlet var bottomView:UIView!
    @IBOutlet var itemsTbl:UITableView!
    
    var sectionTitlesArray=NSMutableArray(array:["NOW PLAYING", "UP NEXT ON SHUFFLE"])
    let site=Config.shared.site()
    var selectedStreamsArray=NSMutableArray()
    var upNextStreamsArray=NSMutableArray()
    var streamsArray=NSMutableArray()
    var nowPlayingStream:Stream!
    var nowPlayingStreamIndex:Int!
        
    override func viewDidLoad()
    {
        nowPlayingStream=streamsArray.object(at:nowPlayingStreamIndex) as! Stream
        
        streamsArray.removeObject(at:nowPlayingStreamIndex)
        
        backgroundImageView.sd_setImage(with:URL(string:"\(site)/thumb/\(nowPlayingStream.id).jpg"))
        
        headerTitleLbl.text=nowPlayingStream.title
        
        itemsTbl.isEditing=true
    }
    
    func numberOfSectionsInTableView(_ tableView:UITableView)->Int
    {
        return sectionTitlesArray.count
    }
    
    func tableView(_ tableView:UITableView, heightForHeaderInSection section:Int)->CGFloat
    {
        return 30
    }
    
    func tableView(_ tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        let headerView=UIView(frame:CGRect(x:0, y:0, width:tableView.frame.size.width, height:30))
        
        let titleLbl=UILabel(frame:CGRect(x:10, y:0, width:300, height:20))
        titleLbl.text=sectionTitlesArray[section] as? String
        titleLbl.font=UIFont.systemFont(ofSize: 10)
        titleLbl.textColor=UIColor.white
        
        let lineView=UIView(frame:CGRect(x:10, y:29.5, width:tableView.frame.size.width-20, height:0.5))
        lineView.backgroundColor=UIColor(red:37/255, green:36/255, blue:41/255, alpha:1)
        
        headerView.addSubview(titleLbl)
        headerView.addSubview(lineView)
        
        return headerView
    }
    
    func tableView(_ tableView:UITableView, heightForRowAtIndexPath indexPath:IndexPath)->CGFloat
    {
        return indexPath.section==0 ? 80 : 50
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        if section==0
        {
            return 1
        }
        else if sectionTitlesArray.count==2&&section==1
        {
            return streamsArray.count
        }
        else if section==1
        {
            return upNextStreamsArray.count
        }
        else
        {
            return streamsArray.count
        }
    }
    
    func tableView(_ tableView:UITableView, cellForRowAtIndexPath indexPath:IndexPath)->UITableViewCell
    {
        if indexPath.section==0
        {
            let cell=tableView.dequeueReusableCell(withIdentifier:"NowPlayingCell") as! RecentStreamCell
            
            cell.streamNameLabel.text=nowPlayingStream.title
            cell.userLabel.text=nowPlayingStream.user.name
            cell.playImageView.sd_setImage(with:URL(string:"\(site)/thumb/\(nowPlayingStream.id).jpg"), placeholderImage:UIImage(named:"stream"))
            cell.dotsButton?.addTarget(self, action:#selector(dotsButtonTapped), for:.touchUpInside)
            
            return cell
        }
        else
        {
            let cell=tableView.dequeueReusableCell(withIdentifier:"UpNextCell") as! RecentStreamCell
            cell.playImageView.image=selectedStreamsArray.contains(indexPath.row) ? UIImage(named:"checkmark") : UIImage(named:"checkmarkblank")
            
            var stream:Stream!
            
            if sectionTitlesArray.count==2&&indexPath.section==1
            {
                stream=streamsArray[indexPath.row] as! Stream
            }
            else if indexPath.section==1
            {
                stream=upNextStreamsArray[indexPath.row] as! Stream
            }
            else
            {
                stream=streamsArray[indexPath.row] as! Stream
            }
            
            cell.streamNameLabel.text=stream.title
            cell.userLabel.text=stream.user.name
            
            return cell
        }
    }
    
    func tableView(_ tableView:UITableView, didSelectRowAtIndexPath indexPath:IndexPath)
    {
        if indexPath.section>0
        {
            let cell=tableView.cellForRow(at:indexPath) as! RecentStreamCell
            
            if selectedStreamsArray.contains(indexPath.row)
            {
                selectedStreamsArray.remove(indexPath.row)
                cell.playImageView.image=UIImage(named:"checkmarkblank")
            }
            else
            {
                selectedStreamsArray.add(indexPath.row)
                cell.playImageView.image=UIImage(named:"checkmark")
            }
            
            var offset:CGFloat=0
            
            if selectedStreamsArray.count>0
            {
                offset=50
            }
            
            performAnimation(offset)
        }
    }
    
    func tableView(_ tableView:UITableView, editingStyleForRowAtIndexPath indexPath:IndexPath)->UITableViewCellEditingStyle
    {
        return .none
    }
    
    func tableView(_ tableView:UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath:IndexPath)->Bool
    {
        return false
    }
    
    func tableView(_ tableView:UITableView, canMoveRowAtIndexPath indexPath:IndexPath)->Bool
    {
        return indexPath.section==0 ? false : true
    }
    
    func tableView(_ tableView:UITableView, moveRowAtIndexPath sourceIndexPath:IndexPath, toIndexPath destinationIndexPath:IndexPath)
    {
        streamsArray.exchangeObject(at:sourceIndexPath.row, withObjectAt:destinationIndexPath.row)
        itemsTbl.reloadData()
    }
    
    @IBAction func addToUpNext()
    {
        if sectionTitlesArray.count==2
        {
            sectionTitlesArray.insert("UP NEXT", at:1)
        }
        
        for i in 0 ..< selectedStreamsArray.count
        {
            let sourceIndex=selectedStreamsArray[i] as! Int
            let destinationIndex=nowPlayingStreamIndex+i
            
            streamsArray.exchangeObject(at:sourceIndex, withObjectAt:destinationIndex)
            upNextStreamsArray.add(streamsArray.object(at:sourceIndex))
        }
        
        selectedStreamsArray.removeAllObjects()
        itemsTbl.reloadData()
        performAnimation(0)
    }
    
    func dotsButtonTapped()
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewController(withIdentifier: "PopUpViewController") as! PopUpViewController
        vc.stream=nowPlayingStream
        present(vc, animated:true)
    }
    
    @IBAction func removeSelectedStreams()
    {
        let indexSet=NSMutableIndexSet()
        
        let selectedStreamIndex=nowPlayingStreamIndex
        
        for i in 0 ..< selectedStreamsArray.count
        {
            let index=selectedStreamsArray[i] as! Int
            
            if (index<selectedStreamIndex!)
            {
                nowPlayingStreamIndex=nowPlayingStreamIndex-1
            }
            
            indexSet.add(index)
        }
        
        streamsArray.removeObjects(at:indexSet as IndexSet)
        selectedStreamsArray.removeAllObjects()
        itemsTbl.reloadData()
        performAnimation(0)
    }
    
    func performAnimation(_ offset:CGFloat)
    {
        UIView.animate(withDuration: 0.5, animations:{
            self.itemsTbl.frame=CGRect(x:0, y:48, width:self.view.frame.size.width, height:self.view.frame.size.height-48-offset)
            self.bottomView.frame=CGRect(x:0, y:self.view.frame.size.height-offset, width:self.view.frame.size.width, height:50)
        })
    }
    
    @IBAction func closePlaylist()
    {
        streamsArray.insert(nowPlayingStream, at:nowPlayingStreamIndex)
        
        NotificationCenter.default.post(name:Notification.Name("closePlaylist"), object:nowPlayingStreamIndex)
        
        dismiss(animated:true)
    }
    
    @IBAction func closePlayer()
    {
        view.window?.rootViewController?.dismiss(animated:true)
        
        streamsArray.insert(nowPlayingStream, at:nowPlayingStreamIndex)
        
        NotificationCenter.default.post(name:Notification.Name("closePlayer"), object:nowPlayingStreamIndex)
    }
    
    func createTransitionImageView()->UIImageView
    {
        return UIImageView()
    }
}
