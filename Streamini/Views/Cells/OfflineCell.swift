//
//  OfflineCell.swift
//  BEINIT
//
//  Created by Ankit Garg on 6/10/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class OfflineCell: UITableViewCell
{
    @IBOutlet var videoTitleLbl:UILabel!
    @IBOutlet var artistNameLbl:UILabel!
    @IBOutlet var videoThumbnailImageView:UIImageView!
    @IBOutlet var statusButton:UIButton!
    @IBOutlet var progressView:UIProgressView!
    
    func updateDownloadStatus(_ item:DWDownloadItem)
    {
        if item.videoDownloadStatus==DWDownloadStatusStart
        {
            statusButton.setBackgroundImage(UIImage(named:"download-status-down"), for:.normal)
        }
        else if item.videoDownloadStatus==DWDownloadStatusFail
        {
            statusButton.setBackgroundImage(UIImage(named:"download-status-fail"), for:.normal)
        }
        else if item.videoDownloadStatus==DWDownloadStatusWait
        {
            statusButton.setBackgroundImage(UIImage(named:"download-stat-waiting"), for:.normal)
        }
        else if item.videoDownloadStatus==DWDownloadStatusPause
        {
            statusButton.setBackgroundImage(UIImage(named:"download-status-hold"), for:.normal)
        }
        else if item.videoDownloadStatus==DWDownloadStatusDownloading
        {
            statusButton.setBackgroundImage(UIImage(named:"download-status-down"), for:.normal)
        }
    }
    
    func updateCellProgress(_ item:DWDownloadItem)
    {
        progressView.progress=item.videoDownloadProgress
    }
}
