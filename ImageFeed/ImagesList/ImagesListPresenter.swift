//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by bot on 26.03.2026.
//
import Foundation
import Kingfisher
import UIKit

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    
    private let imagesListService: ImagesListServiceProtocol
    private var photos: [Photo] = []
    private var imageListServiceObserver: NSObjectProtocol?
    private let dateFormatter = DateFormatter.imageList
    
    var photosCount: Int {
        return photos.count
    }
    
    init(imagesListService: ImagesListServiceProtocol = ImagesListService.shared) {
        self.imagesListService = imagesListService
    }
    
    func viewDidLoad() {
        setupObservers()
        loadNextPage()
    }
    
    private func setupObservers() {
        imageListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updatePhotos()
            }
    }
    
    private func updatePhotos() {
        let newPhotos = imagesListService.photos
        photos = newPhotos
        view?.updateTableViewAnimated()
    }
    
    func loadNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func photo(at index: Int) -> Photo? {
        guard index < photos.count else { return nil }
        return photos[index]
    }
    
    func didSelectPhoto(at index: Int) {
        guard let photo = photo(at: index) else { return }
        view?.navigateToSingleImage(with: photo, previewImage: nil)
    }
    
    func didTapLike(at index: Int) {
        guard let photo = photo(at: index) else { return }
        
        let newLikeState = !photo.isLiked
        
        updatePhotoLikeState(at: index, isLiked: newLikeState)
        
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: newLikeState) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success:
                    break
                case .failure:
                    self?.updatePhotoLikeState(at: index, isLiked: photo.isLiked)
                    self?.view?.showLikeError()
                }
            }
        }
    }
    
    private func updatePhotoLikeState(at index: Int, isLiked: Bool) {
        guard let photo = photo(at: index) else { return }
        
        let updatedPhoto = Photo(
            id: photo.id,
            size: photo.size,
            createdAt: photo.createdAt,
            welcomeDescription: photo.welcomeDescription,
            thumbImageURL: photo.thumbImageURL,
            largeImageURL: photo.largeImageURL,
            isLiked: isLiked
        )
        photos[index] = updatedPhoto
        view?.updateLikeInTableView(photoId: photo.id, isLiked: isLiked)
    }
    
    func willDisplayCell(at index: Int) {
        if index + 1 == photosCount {
            loadNextPage()
        }
    }
    
    func configureCell(_ cell: ImagesListCell, at index: Int) {
        guard let photo = photo(at: index) else { return }
        
        cell.delegate = (view as? ImagesListCellDelegate)
        
        if let url = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.indicatorType = .activity
            cell.cellImage.kf.setImage(
                with: url,
                placeholder: UIImage(named: "placeholder"),
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            )
        }
        
        if let date = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }
        
        cell.setIsLiked(photo.isLiked)
        cell.selectionStyle = .none
    }
    
    deinit {
        if let observer = imageListServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
