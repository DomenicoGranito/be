//
//  GradientTableView.swift
//  BEINIT
//
//  Created by Ankit Garg on 4/27/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class GradientTableView: UITableView
{
    var gradientLayer:CAGradientLayer!
    var titleLbl:UILabel!
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        createGradientLayerIfNeeded()
        updateGradientLayer()
    }
    
    func createGradientLayerIfNeeded()
    {
        if gradientLayer != nil
        {
            return
        }
        
        let colorTop=UIColor(red:255/255, green:149/255, blue:0/255, alpha:1).cgColor
        let colorBottom=UIColor(red:255/255, green:94/255, blue:58/255, alpha:1).cgColor
        gradientLayer=CAGradientLayer()
        gradientLayer.colors=[colorTop, colorBottom]
        gradientLayer.locations=[0, 1]
        layer.insertSublayer(gradientLayer, at:0)
        
        titleLbl=UILabel()
        titleLbl.text="Celebrating Asian Pacific Heritage!"
        titleLbl.textColor=UIColor.white
        titleLbl.textAlignment = .center
        gradientLayer.addSublayer(titleLbl.layer)
    }
    
    func updateGradientLayer()
    {
        gradientLayer.frame=rect(forSection: 0)
        titleLbl.frame=CGRect(x:0, y:0, width:gradientLayer.frame.size.width, height:60)
    }
}
