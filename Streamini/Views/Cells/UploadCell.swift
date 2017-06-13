//
//  UploadCell.swift
//  BEINIT
//
//  Created by Ankit Garg on 6/13/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class UploadCell: UITableViewCell
{
    @IBOutlet var videoTitleLbl:UILabel!
    @IBOutlet var progressLbl:UILabel!
    @IBOutlet var videoThumbnailImageView:UIImageView!
    @IBOutlet var statusButton:UIButton!
    @IBOutlet var progressView:UIProgressView!
    
    func updateUploadStatus(_ item:DWUploadItem)
    {
        if item.videoUploadStatus==DWUploadStatusStart
        {
            statusButton.setBackgroundImage(UIImage(named:"download-status-uploading"), for:.normal)
        }
        else if item.videoUploadStatus==DWUploadStatusFail
        {
            statusButton.setBackgroundImage(UIImage(named:"download-status-fail"), for:.normal)
        }
        else if item.videoUploadStatus==DWUploadStatusWait
        {
            statusButton.setBackgroundImage(UIImage(named:"download-stat-waiting"), for:.normal)
        }
        else if item.videoUploadStatus==DWUploadStatusPause
        {
            statusButton.setBackgroundImage(UIImage(named:"download-status-hold"), for:.normal)
        }
        else if item.videoUploadStatus==DWUploadStatusUploading||item.videoUploadStatus==DWUploadStatusResume
        {
            statusButton.setBackgroundImage(UIImage(named:"download-status-uploading"), for:.normal)
        }
        else if item.videoUploadStatus==DWUploadStatusLoadLocalFileInvalid
        {
            statusButton.setBackgroundImage(UIImage(named:"download-status-hold"), for:.normal)
        }
    }
    
    func updateCellProgress(_ item:DWUploadItem)
    {
        progressView.progress=item.videoUploadProgress
        
        let uploadedSizeMB=item.videoUploadedSize/1024/1024
        let fileSizeMB=item.videoFileSize/1024/1024
        
        progressLbl.text="\(uploadedSizeMB)M/\(fileSizeMB)M"
    }
}
