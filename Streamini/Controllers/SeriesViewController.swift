//
//  SeriesViewController.swift
//  BEINIT
//
//  Created by Dominic on 2/15/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class SeriesViewController: BaseViewController
{
    @IBOutlet var tableView:UITableView!
    @IBOutlet var pageControl:UIPageControl!
    @IBOutlet var scrollView:UIScrollView!
    @IBOutlet var searchBar:UISearchBar!
    @IBOutlet var searchView:UIView!
    @IBOutlet var cancelButton:UIButton!
    @IBOutlet var filterButton:UIButton!
    @IBOutlet var topViewTopSpaceConstraint:NSLayoutConstraint!
    @IBOutlet var shuffleButtonTopSpaceConstraint:NSLayoutConstraint!
    
    var blockingView:UIView!
    var navigationBarBackgroundImage:UIImage!
    var shuffleButtonTopSpace:CGFloat!
        
    override func viewDidLoad()
    {
        shuffleButtonTopSpace=shuffleButtonTopSpaceConstraint.constant
        
        scrollView.contentSize=CGSize(width:view.frame.size.width*2, height:276)
        
        let playlistView=PlaylistView.instanceFromNib()
        playlistView.frame=CGRect(x:0, y:0, width:view.frame.size.width, height:276)
        scrollView.addSubview(playlistView)
        
        let playlistDetailView=PlaylistDetailView.instanceFromNib()
        playlistDetailView.frame=CGRect(x:view.frame.size.width, y:0, width:view.frame.size.width, height:276)
        scrollView.addSubview(playlistDetailView)
        
        navigationBarBackgroundImage=navigationController!.navigationBar.backgroundImage(for: .default)
        
        navigationController!.navigationBar.backgroundColor=UIColor.clear
        navigationController!.navigationBar.setBackgroundImage(UIImage(), for:.default)
        
        tableView.contentOffset=CGPoint(x:0, y:64)
        
        blockingView=UIView(frame:CGRect(x:0, y:0, width:view.frame.size.width, height:64))
        blockingView.backgroundColor=UIColor.black
        view.addSubview(blockingView)
    }
    
    override func viewWillDisappear(_ animated:Bool)
    {
        navigationController!.navigationBar.setBackgroundImage(navigationBarBackgroundImage, for:.default)
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return 10
    }
    
    func tableView(_ tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        return UITableViewCell()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView:UIScrollView)
    {
        let pageNumber=self.scrollView.contentOffset.x/scrollView.frame.size.width
        pageControl.currentPage=Int(pageNumber)
    }
    
    func scrollViewDidScroll(_ scrollView:UIScrollView)
    {
        if tableView.contentOffset.y > -20
        {
            if searchView.alpha==1
            {
                UIView.animate(withDuration: 0.3, animations:{()->Void in
                    self.searchView.alpha=0
                    }, completion:{(finished:Bool)->Void in
                        self.blockingView.isHidden=false
                })
            }
            
            topViewTopSpaceConstraint.constant=max(0, tableView.contentOffset.y+20)
        }
        else
        {
            if searchView.alpha==0
            {
                blockingView.isHidden=true
                UIView.animate(withDuration: 0.3, animations:{()->Void in
                    self.searchView.alpha=1
                })
            }
            
            topViewTopSpaceConstraint.constant=0
        }
        
        if tableView.contentOffset.y<=231
        {
            shuffleButtonTopSpaceConstraint.constant=shuffleButtonTopSpace-tableView.contentOffset.y
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar:UISearchBar)
    {
        searchBar.resignFirstResponder()
        filterButton?.isHidden=false
        cancelButton?.isHidden=true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar:UISearchBar)
    {
        filterButton?.isHidden=true
        cancelButton?.isHidden=false
    }
    
    func searchBar(_ searchBar:UISearchBar, textDidChange searchText:String)
    {
        if searchText.characters.count>0
        {
            
        }
    }
    
    @IBAction func cancel()
    {
        searchBar.resignFirstResponder()
        filterButton?.isHidden=false
        cancelButton?.isHidden=true
    }
    
    @IBAction func filter()
    {
        let vc=storyBoard.instantiateViewController(withIdentifier: "FiltersViewController") as! FiltersViewController
        vc.backgroundImage=renderImageFromView()
        present(vc, animated:true, completion:nil)
    }
    
    @IBAction func options()
    {
        let vc=storyBoard.instantiateViewController(withIdentifier: "OptionsViewController") as! OptionsViewController
        vc.backgroundImage=renderImageFromView()
        present(vc, animated:true, completion:nil)
    }
    
    func renderImageFromView()->UIImage?
    {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, true, 0)
        let context=UIGraphicsGetCurrentContext()
        
        view.layer.render(in: context!)
        
        let renderedImage=UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return renderedImage
    }
}
