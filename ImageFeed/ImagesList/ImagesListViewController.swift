//
//  ViewController.swift
//  ImageFeed
//
//  Created by bot on 20.12.2025.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    @IBOutlet weak var tableView: UITableView!
    
    var presenter: ImagesListPresenterProtocol!
      
      override func viewDidLoad() {
          super.viewDidLoad()
          setupTableView()
          configurePresenter()
          presenter.viewDidLoad()
      }
      
      func configure(_ presenter: ImagesListPresenterProtocol) {
          self.presenter = presenter
          presenter.view = self
      }
      
      private func configurePresenter() {
          if presenter == nil {
              presenter = ImagesListPresenter()
              presenter.view = self
          }
      }
      
      private func setupTableView() {
          tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
          tableView.dataSource = self
          tableView.delegate = self
      }
      
      // MARK: - ImagesListViewControllerProtocol
      func updateTableViewAnimated() {
          tableView.reloadData()
      }
      
      func updateLikeInTableView(photoId: String, isLiked: Bool) {
          guard let index = (0..<presenter.photosCount).first(where: { presenter.photo(at: $0)?.id == photoId }) else { return }
          
          if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ImagesListCell {
              cell.setIsLiked(isLiked)
          }
      }
      
      func showLikeError() {
          let alert = UIAlertController(
              title: "Ошибка",
              message: "Не удалось обновить лайк. Попробуйте еще раз",
              preferredStyle: .alert
          )
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          present(alert, animated: true)
      }
      
      func showLoadingError(_ error: Error) {
          let alert = UIAlertController(
              title: "Ошибка загрузки",
              message: error.localizedDescription,
              preferredStyle: .alert
          )
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          present(alert, animated: true)
      }
      
      func navigateToSingleImage(with photo: Photo, previewImage: UIImage?) {
          performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: (photo, previewImage))
      }
      
      override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          if segue.identifier == showSingleImageSegueIdentifier {
              guard let viewController = segue.destination as? SingleImageViewController,
                    let (photo, _) = sender as? (Photo, UIImage?) else {
                  return
              }
              
              viewController.photoURL = photo.largeImageURL
          }
      }
  }

  // MARK: - UITableViewDataSource
  extension ImagesListViewController: UITableViewDataSource {
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return presenter.photosCount
      }
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
          
          guard let imageListCell = cell as? ImagesListCell else {
              return UITableViewCell()
          }
          
          presenter.configureCell(imageListCell, at: indexPath.row)
          
          return imageListCell
      }
  }

  // MARK: - UITableViewDelegate
  extension ImagesListViewController: UITableViewDelegate {
      func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          presenter.didSelectPhoto(at: indexPath.row)
      }
      
      func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
          guard let photo = presenter.photo(at: indexPath.row) else { return 0 }
          
          let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
          let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
          let imageWidth = photo.size.width
          let scale = imageViewWidth / imageWidth
          let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
          return cellHeight
      }
      
      func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
          presenter.willDisplayCell(at: indexPath.row)
      }
  }

  // MARK: - ImagesListCellDelegate
  extension ImagesListViewController: ImagesListCellDelegate {
      func imageListCellDidTapLike(_ cell: ImagesListCell) {
          guard let indexPath = tableView.indexPath(for: cell) else { return }
          cell.animateLikeButton()
          presenter.didTapLike(at: indexPath.row)
      }
  }
