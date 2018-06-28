//
//  FeedImageCell.swift
//  DigitalEcoSystem
//
//  Created by Ravi Ranjan on 25/05/17.
//  Copyright © 2017 Dean and Deluca. All rights reserved.
//

import UIKit

class FeedImageCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var feedImageView: UIImageView!
    
    // MARK: - View life cycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
         feedImageView.contentMode = .scaleAspectFill
    }
    
    // MARK: - setup data
    func setDataOnFeedCollectionCell(feed: Feed, indexpath: IndexPath) {
        
        switch indexpath.row {
        case 0:
            let imagUrl: String = Constants.ImageUrl.LargeImage + feed.feedsImage!
            feedImageView.sd_setShowActivityIndicatorView(true)
            feedImageView.sd_setIndicatorStyle(.gray)
            feedImageView.sd_setImage(with: URL(string: imagUrl), placeholderImage: UIImage(named: "feedPlaceholder"), options: .retryFailed, completed: { _, _, _, _ in
                self.feedImageView.sd_setShowActivityIndicatorView(false)
            })
        case 1:
            self.feedImageView.image = UIImage.init(named: "feedPlaceholder")
            DispatchQueue.global(qos: .userInitiated).async {
                let overlayImage = self.createThumbnailOfVideoFromFileURL(videoURL: Constants.ImageUrl.Video + feed.feedsVideo!)
                DispatchQueue.main.async {
                    self.feedImageView.image = overlayImage
                }
            }
        default:
            print("Default")
        }
    }
    
    func createThumbnailOfVideoFromFileURL(videoURL: String) -> UIImage? {
        let asset = AVAsset(url: URL(string: videoURL)!)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(Float64(1), 100)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            // Set a default image if Image is not acquired
            return UIImage(named: "feedPlaceholder")
        }
    }
    
}
