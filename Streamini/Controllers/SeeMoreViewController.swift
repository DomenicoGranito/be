//
//  SeeMoreViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 5/9/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class SeeMoreViewController: UIViewController
{
    @IBOutlet var tableView:UITableView!
    
    let storyBoard=UIStoryboard(name:"Main", bundle:nil)
    var TBVC:TabBarViewController!
    var t:String!
    var q:String!
    var users:[User]=[]
    var streams:[Stream]=[]
    
    override func viewWillAppear(_ animated:Bool)
    {
        self.title=t.capitalized
        navigationController?.isNavigationBarHidden=false
        
        if t=="streams"
        {
            StreamConnector().searchMoreStreams(q, searchMoreStreamsSuccess, searchFailure)
        }
        else
        {
            StreamConnector().searchMoreOthers(q, t, searchMoreOthersSuccess, searchFailure)
        }
    }
    
    func tableView(_ tableView:UITableView, heightForRowAtIndexPath indexPath:IndexPath)->CGFloat
    {
        if t=="streams"
        {
            return 80
        }
        else
        {
            return 70
        }
    }

    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        if t=="streams"
        {
            return streams.count
        }
        else
        {
            return users.count
        }
    }

    func tableView(_ tableView:UITableView, cellForRowAtIndexPath indexPath:IndexPath)->UITableViewCell
    {
        if t=="streams"
        {
            let cell=tableView.dequeueReusableCell(withIdentifier:"StreamCell", for:indexPath) as! SearchStreamCell
            let stream=streams[indexPath.row]
            cell.update(stream)
            
            cell.dotsButton?.tag=indexPath.row
            cell.dotsButton?.addTarget(self, action:#selector(dotsButtonTapped), for:.touchUpInside)
            
            return cell
        }
        else
        {
            let cell=tableView.dequeueReusableCell(withIdentifier:"PeopleCell", for:indexPath) as! PeopleCell
            
            let user=users[indexPath.row]
            
            cell.userImageView.sd_setImage(with:user.avatarURL() as! URL)
            cell.usernameLabel.text=user.name
            cell.likesLabel.text="\(user.likes)"
            
            return cell
        }
    }

    func tableView(_ tableView:UITableView, didSelectRowAtIndexPath indexPath:IndexPath)
    {
        if t=="streams"
        {
            let modalVC=storyBoard.instantiateViewController(withIdentifier:"ModalViewController") as! ModalViewController
            
            let streamsArray=NSMutableArray()
            streamsArray.add(streams[indexPath.row])
            
            modalVC.streamsArray=streamsArray
            modalVC.TBVC=TBVC
            
            TBVC.modalVC=modalVC
            TBVC.configure(streams[indexPath.row])
        }
        else
        {
            let vc=storyBoard.instantiateViewController(withIdentifier:"UserViewControllerId") as! UserViewController
            vc.user=users[indexPath.row]
            navigationController?.pushViewController(vc, animated:true)
        }
    }

    func searchMoreStreamsSuccess(streams:[Stream])
    {
        self.streams=streams
        
        tableView.reloadData()
    }
    
    func searchMoreOthersSuccess(users:[User])
    {
        self.users=users
        
        tableView.reloadData()
    }
    
    func searchFailure(error:NSError)
    {
        
    }
    
    func dotsButtonTapped(sender:UIButton)
    {
        let vc=storyBoard.instantiateViewController(withIdentifier:"PopUpViewController") as! PopUpViewController
        vc.stream=streams[sender.tag]
        present(vc, animated:true)
    }
}
