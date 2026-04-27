//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by bot on 27.12.2025.
//

import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    weak var delegate: ImagesListCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellImage.contentMode = .scaleAspectFill
        cellImage.layer.cornerRadius = 16
        cellImage.layer.masksToBounds = true
        
            likeButton.isHidden = false
            likeButton.isUserInteractionEnabled = true
            likeButton.accessibilityIdentifier = "like button off"
            likeButton.accessibilityLabel = "Like"
           self.accessibilityIdentifier = "imageCell"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
        delegate = nil
    }
    
    
    
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked ? UIImage(resource: .active) : UIImage(resource: .noActive)
        likeButton.setImage(likeImage, for: .normal)
    }
    
    func animateLikeButton() {
        UIView.animate(withDuration: 0.1, animations: {
            self.likeButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.likeButton.transform = .identity
            }
        }
    }
}
