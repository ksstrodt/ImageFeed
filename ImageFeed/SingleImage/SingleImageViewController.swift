//
//  File.swift
//  ImageFeed
//
//  Created by bot on 01.01.2026.
//
import Foundation
import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            imageView.image = image
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    var photoURL: String?
    
    
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
        
        if let photoURL = photoURL {
            loadFullImage(url: photoURL)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let image = image {
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    // MARK: - Загрузка полномасштабного изображения
    private func loadFullImage(url: String) {
        guard let imageURL = URL(string: url) else {
            showError()
            return
        }
        
        
        UIBlockingProgressHUD.show()
        print("Начинаем загрузку полноразмерного изображения: \(url)")
        
        
        ImageCache.default.removeImage(forKey: imageURL.cacheKey)
        
        let options: KingfisherOptionsInfo = [
            .transition(.fade(0.2)),
            .cacheOriginalImage,
            .forceRefresh,
            .downloadPriority(URLSessionTask.highPriority)
        ]
        
        imageView.kf.setImage(
            with: imageURL,
            placeholder: image ?? UIImage(named: "placeholder"),
            options: options,
            progressBlock: { receivedSize, totalSize in
                print("Загружено: \(receivedSize)/\(totalSize)")
            }
        ) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
            }
            
            switch result {
            case .success(let imageResult):
                print("Полноразмерное изображение успешно загружено")
                DispatchQueue.main.async {
                    self?.image = imageResult.image
                    self?.rescaleAndCenterImageInScrollView(image: imageResult.image)
                }
                
            case .failure(let error):
                print("Ошибка загрузки полномасштабного изображения: \(error.localizedDescription)")
                
                if error.isTaskCancelled {
                    print("Загрузка была отменена")
                    return
                }
                
                DispatchQueue.main.async {
                    self?.showError()
                }
            }
        }
    }
    
    // MARK: - Показ ошибки с возможностью повторить
    private func showError() {
        guard view.window != nil else { return }
        
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Не надо", style: .cancel) { [weak self] _ in
        }
        
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            guard let self = self, let photoURL = self.photoURL else { return }
            self.loadFullImage(url: photoURL)
        }
        
        if let blueColor = UIColor(named: "YP Blue (iOS)") {
            retryAction.setValue(blueColor, forKey: "titleTextColor")
            cancelAction.setValue(blueColor, forKey: "titleTextColor")
        }
        
        alert.addAction(cancelAction)
        alert.addAction(retryAction)
        
        present(alert, animated: true)
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
        imageView.kf.cancelDownloadTask()
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

extension Error {
    var isTaskCancelled: Bool {
        let nsError = self as NSError
        return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled
    }
}
