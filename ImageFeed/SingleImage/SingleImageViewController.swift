//
//  File.swift
//  ImageFeed
//
//  Created by bot on 01.01.2026.
//

import Foundation
import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            imageView.image = image
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    override func viewDidLoad() {
           super.viewDidLoad()
           
           
           scrollView.delegate = self
           
           
           scrollView.minimumZoomScale = 0.1
           scrollView.maximumZoomScale = 3.0
           
           if let image = image {
               imageView.image = image
               rescaleAndCenterImageInScrollView(image: image)
           }
       }
       
       override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
           
           
           if let image = image {
               rescaleAndCenterImageInScrollView(image: image)
           }
       }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
   

       private func rescaleAndCenterImageInScrollView(image: UIImage) {
      
           scrollView.zoomScale = 1.0
           
       
           let screenSize = scrollView.bounds.size
           let imageSize = image.size
           
           
           let widthRatio = screenSize.width / imageSize.width
           let heightRatio = screenSize.height / imageSize.height
           let scaleToFill = max(widthRatio, heightRatio)
           
       
           let newSize = CGSize(
               width: imageSize.width * scaleToFill,
               height: imageSize.height * scaleToFill
           )
           
           
           imageView.frame = CGRect(
               x: 0,
               y: 0,
               width: newSize.width,
               height: newSize.height
           )
           
           
           scrollView.contentSize = newSize
           
           
           scrollView.minimumZoomScale = min(widthRatio, heightRatio)
           scrollView.maximumZoomScale = max(scaleToFill * 3, 1.25)
           
           
           scrollView.zoomScale = scaleToFill
           
           
           centerImage()
           
           
           if newSize.width > screenSize.width || newSize.height > screenSize.height {
               let offsetX = max((newSize.width - screenSize.width) / 2, 0)
               let offsetY = max((newSize.height - screenSize.height) / 2, 0)
               scrollView.contentOffset = CGPoint(x: offsetX, y: offsetY)
           }
       }
       
       private func centerImage() {
           let scrollViewSize = scrollView.bounds.size
           let imageViewSize = imageView.frame.size
           
           
           let horizontalInset = max((scrollViewSize.width - imageViewSize.width) / 2, 0)
           let verticalInset = max((scrollViewSize.height - imageViewSize.height) / 2, 0)
           
           
           scrollView.contentInset = UIEdgeInsets(
               top: verticalInset,
               left: horizontalInset,
               bottom: verticalInset,
               right: horizontalInset
           )
       }
   }

   extension SingleImageViewController: UIScrollViewDelegate {
       func viewForZooming(in scrollView: UIScrollView) -> UIView? {
           return imageView
       }
       
       func scrollViewDidZoom(_ scrollView: UIScrollView) {
           centerImage()
       }
   }
