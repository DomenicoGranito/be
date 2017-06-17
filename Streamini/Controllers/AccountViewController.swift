//
//  AccountViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 6/17/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class AccountViewController: UITableViewController
{
    @IBOutlet var accountValueLbl:UILabel!
    
    override func viewDidLoad()
    {
        if UserContainer.shared.logged().subscription=="pro"
        {
            accountValueLbl.text="PRO"
        }
    }
}
