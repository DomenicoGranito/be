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
    
    func createGradientLayer(_ image:UIImage)
    {
        let colorTop=image.getPixelColor(CGPoint(x:100, y:100)).cgColor
        let colorBottom=image.getPixelColor(CGPoint(x:200, y:200)).cgColor
        
        gradientLayer=CAGradientLayer()
        gradientLayer.colors=[colorTop, colorBottom]
        gradientLayer.locations=[0, 1]
        gradientLayer.frame=rect(forSection:0)
        layer.insertSublayer(gradientLayer, at:0)
        
        addMessage()
    }
    
    func addMessage()
    {
        titleLbl=UILabel()
        titleLbl.text="Celebrating Asian Pacific Heritage!"
        titleLbl.textColor=UIColor.white
        titleLbl.textAlignment = .center
        titleLbl.frame=CGRect(x:0, y:0, width:self.frame.size.width, height:60)
        layer.addSublayer(titleLbl.layer)
    }
}

extension UIImage
{
    func getPixelColor(_ pos:CGPoint)->UIColor
    {
        let pixelData=self.cgImage!.dataProvider!.data
        
        let data:UnsafePointer<UInt8>=CFDataGetBytePtr(pixelData)
        
        let pixelInfo=((Int(self.size.width)*Int(pos.y))+Int(pos.x))*4
        
        let r=CGFloat(data[pixelInfo])/CGFloat(255)
        let g=CGFloat(data[pixelInfo+1])/CGFloat(255)
        let b=CGFloat(data[pixelInfo+2])/CGFloat(255)
        let a=CGFloat(data[pixelInfo+3])/CGFloat(255)
        
        return UIColor(red:r, green:g, blue:b, alpha:a)
    }
}
