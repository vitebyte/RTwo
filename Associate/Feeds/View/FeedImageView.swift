//
//  FeedImageView.swift
//  DigitalEcoSystem
//
//  Created by Ravi Ranjan on 25/05/17.
//  Copyright © 2017 Dean and Deluca. All rights reserved.
//

import UIKit

class FeedImageView: UIView {

    //MARK: - Variables
    var feedImageUrl: String?

    //MARK: Outlets
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!

    //MARK: View life cycle methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        showImageView()
    }

    required init?(coder _: NSCoder) {
        
        LogManager.logSevere("FeedImageView init(coder:) has not been implemented")
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: setup view
    func showImageView() {
        let imageUrl: String = Constants.ImageUrl.SmallImage + feedImageUrl!
        feedImageView.sd_setShowActivityIndicatorView(true)
        feedImageView.sd_setIndicatorStyle(.gray)
        feedImageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "placeholder"), options: .retryFailed, completed: { _, _, _, _ in
            self.feedImageView.sd_setShowActivityIndicatorView(false)
        })
    }

    func showAnimate() {
        transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        alpha = 0
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.alpha = 1
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }

    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.alpha = 0.0
        }, completion: { (_ finished: Bool) -> Void in
            if finished {
                self.removeFromSuperview()
            }
        })
    }

    //MARK: Actions
    @IBAction func closeButtonAction(_: Any) {
        removeAnimate()
    }
}
