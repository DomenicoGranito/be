//
//  LineView.swift
//  MusicPlayerTransition
//
//  Created by xxxAIRINxxx on 2015/08/31.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit

class LineView: UIView
{
    override func draw(_ rect:CGRect)
    {
        let topLine=UIBezierPath(rect:CGRect(x:0, y:0, width:frame.size.width, height:0.5))
        UIColor.gray.setStroke()
        topLine.lineWidth=0.2
        topLine.stroke()
        
        let bottomLine=UIBezierPath(rect:CGRect(x:0, y:frame.size.height-0.5, width:frame.size.width, height:0.5))
        UIColor.lightGray.setStroke()
        bottomLine.lineWidth=0.2
        bottomLine.stroke()
    }
}
