//
//  DevicesViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 5/26/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class DevicesViewController: UIViewController
{
    override var supportedInterfaceOrientations:UIInterfaceOrientationMask
    {
        return .portrait
    }
    
    override var shouldAutorotate:Bool
    {
        return false
    }
    
    override func viewDidLoad()
    {
        let volumeView=MPVolumeView(frame:CGRect(x:20, y:view.frame.size.height-30, width:view.frame.size.width-40, height:view.frame.size.height))
        volumeView.showsVolumeSlider=true
        volumeView.showsRouteButton=false
        view.addSubview(volumeView)
    }
    
    @IBAction func close()
    {
        dismiss(animated:true)
    }
}
