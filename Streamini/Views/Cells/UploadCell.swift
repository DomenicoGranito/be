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
        if item.videoUploadStatus==DWUploadStatusFail
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
        else if item.videoUploadStatus==DWUploadStatusUploading||item.videoUploadStatus==DWUploadStatusResume||item.videoUploadStatus==DWUploadStatusStart
        {
            statusButton.setBackgroundImage(UIImage(named:"upload-status-uploading"), for:.normal)
        }
        else if item.videoUploadStatus==DWUploadStatusLoadLocalFileInvalid
        {
            statusButton.setBackgroundImage(UIImage(named:"download-status-hold"), for:.normal)
        }
    }
    
    func updateCellProgress(_ item:DWUploadItem)
    {
        progressView.progress=item.videoUploadProgress
        
        let uploadedSizeMB=Float(item.videoUploadedSize)/1024.0/1024.0
        let fileSizeMB=Float(item.videoFileSize)/1024.0/1024.0
        
        progressLbl.text=String(format:"%0.1fM/%0.1fM", uploadedSizeMB, fileSizeMB)
    }
}
