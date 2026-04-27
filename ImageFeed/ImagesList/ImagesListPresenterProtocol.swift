//
//  ImagesListPresenterProtocol.swift
//  ImageFeed
//
//  Created by bot on 26.03.2026.
//
import UIKit
import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photosCount: Int { get }
    
    func viewDidLoad()
    func loadNextPage()
    func photo(at index: Int) -> Photo?
    func didSelectPhoto(at index: Int)
    func didTapLike(at index: Int)
    func willDisplayCell(at index: Int)
    func configureCell(_ cell: ImagesListCell, at index: Int)
}

protocol ImagesListViewControllerProtocol: AnyObject {
    func updateTableViewAnimated()
    func updateLikeInTableView(photoId: String, isLiked: Bool)
    func showLikeError()
    func showLoadingError(_ error: Error)
    func navigateToSingleImage(with photo: Photo, previewImage: UIImage?)
}
