//
//  ErrorView.swift
//  BEINIT
//
//  Created by Ankit Garg on 3/13/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class ErrorView:UIView
{
    @IBOutlet var errorImageView:UIImageView!
    @IBOutlet var errorLbl:UILabel!
    
    func update(_ error:String, icon:String)
    {
        errorImageView.image=UIImage(named:icon)
        errorLbl.text=error
        
        self.isHidden=false
    }
}
