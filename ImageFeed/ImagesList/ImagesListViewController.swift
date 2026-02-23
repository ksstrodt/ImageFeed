//
//  ViewController.swift
//  ImageFeed
//
//  Created by bot on 20.12.2025.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    private var imageListServiceObserver: NSObjectProtocol?
    private var imageListLikeObserver: NSObjectProtocol?
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let dateFormatter = DateFormatter.imageList
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupObservers()
        loadNextPage()
    }
    
    private func setupTableView() {
        //tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(
            top: 12,
            left: 0,
            bottom: 12,
            right: 0
        )
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupObservers() {
        imageListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateTableViewAnimated()
            }
        
        imageListLikeObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeLikeNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                guard let self = self,
                      let photoId = notification.userInfo?["photoId"] as? String,
                      let isLiked = notification.userInfo?["isLiked"] as? Bool else { return }
                
                self.updateLikeInTableView(photoId: photoId, isLiked: isLiked)
            }
    }
    
    private func updateLikeInTableView(photoId: String, isLiked: Bool) {
        guard let index = photos.firstIndex(where: { $0.id == photoId }) else { return }
        
        let photo = photos[index]
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
        
        
        if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ImagesListCell {
            cell.setIsLiked(isLiked)
        }
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        
        photos = imagesListService.photos
        
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    private func loadNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath,
                indexPath.row < photos.count
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let photo = photos[indexPath.row]
            
            
            viewController.photoURL = photo.largeImageURL
            
            
            if let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell,
               let previewImage = cell.cellImage.image {
                viewController.image = previewImage
            }
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    deinit {
        if let observer = imageListServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = imageListLikeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < photos.count else { return 0 }
        
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            loadNextPage()
        }
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
}

// MARK: - Config Cell
extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard indexPath.row < photos.count else { return }
        
        let photo = photos[indexPath.row]
        
        
        cell.delegate = self
        
        
        if let url = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.indicatorType = .activity
            cell.cellImage.kf.setImage(
                with: url,
                placeholder: UIImage(named: "placeholder"),
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            ) { [weak self] result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        self?.tableView.beginUpdates()
                        self?.tableView.endUpdates()
                    }
                case .failure(let error):
                    print("Ошибка загрузки: \(error)")
                }
            }
        }
        
        
        if let date = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }
        
        
        cell.setIsLiked(photo.isLiked)
        cell.selectionStyle = .none
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        guard indexPath.row < photos.count else { return }
        
        let photo = photos[indexPath.row]
        let newLikeState = !photo.isLiked
        
        cell.animateLikeButton()
        
        cell.setIsLiked(newLikeState)
        
        
        let updatedPhoto = Photo(
            id: photo.id,
            size: photo.size,
            createdAt: photo.createdAt,
            welcomeDescription: photo.welcomeDescription,
            thumbImageURL: photo.thumbImageURL,
            largeImageURL: photo.largeImageURL,
            isLiked: newLikeState
        )
        photos[indexPath.row] = updatedPhoto
        
        UIBlockingProgressHUD.show()
        
        
        imagesListService.changeLike(photoId: photo.id, isLike: newLikeState) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success:
                    break
                    
                case .failure(let error):
                    
                    print("Ошибка при изменении лайка: \(error)")
                    
                    
                    let revertedPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: photo.isLiked
                    )
                    self?.photos[indexPath.row] = revertedPhoto
                    cell.setIsLiked(photo.isLiked)
                    
                    self?.showLikeErrorAlert()
                }
            }
        }
    }
    
    private func showLikeErrorAlert() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Не удалось обновить лайк. Попробуйте еще раз",
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
}
