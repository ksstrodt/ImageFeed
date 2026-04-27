//
//  ImagesListViewControllerSpy.swift
//  Image FeedTests
//
//  Created by bot on 26.03.2026.
//
@testable import ImageFeed
import UIKit

final class ImagesListViewControllerSpy: UIViewController, ImagesListViewControllerProtocol {
    
    var presenter: ImagesListPresenterProtocol?
    
    // MARK: - Call Tracking
    private(set) var updateTableViewAnimatedCalled = false
    private(set) var updateTableViewAnimatedCallCount = 0
    private(set) var updateLikeInTableViewCalled = false
    private(set) var updateLikeInTableViewCallCount = 0
    private(set) var showLikeErrorCalled = false
    private(set) var showLikeErrorCallCount = 0
    private(set) var showLoadingErrorCalled = false
    private(set) var showLoadingErrorCallCount = 0
    private(set) var navigateToSingleImageCalled = false
    private(set) var navigateToSingleImageCallCount = 0
    
    // MARK: - Captured Parameters
    private(set) var capturedPhotoId: String?
    private(set) var capturedIsLiked: Bool?
    private(set) var capturedError: Error?
    private(set) var capturedPhoto: Photo?
    private(set) var capturedPreviewImage: UIImage?
    
    // MARK: - Protocol Methods
    func updateTableViewAnimated() {
        updateTableViewAnimatedCalled = true
        updateTableViewAnimatedCallCount += 1
    }
    
    func updateLikeInTableView(photoId: String, isLiked: Bool) {
        updateLikeInTableViewCalled = true
        updateLikeInTableViewCallCount += 1
        capturedPhotoId = photoId
        capturedIsLiked = isLiked
    }
    
    func showLikeError() {
        showLikeErrorCalled = true
        showLikeErrorCallCount += 1
    }
    
    func showLoadingError(_ error: Error) {
        showLoadingErrorCalled = true
        showLoadingErrorCallCount += 1
        capturedError = error
    }
    
    func navigateToSingleImage(with photo: Photo, previewImage: UIImage?) {
        navigateToSingleImageCalled = true
        navigateToSingleImageCallCount += 1
        capturedPhoto = photo
        capturedPreviewImage = previewImage
    }
    
    func simulateLikeTap(at index: Int) {
        presenter?.didTapLike(at: index)
    }
    
    // MARK: - Helper Methods
    func reset() {
        updateTableViewAnimatedCalled = false
        updateTableViewAnimatedCallCount = 0
        updateLikeInTableViewCalled = false
        updateLikeInTableViewCallCount = 0
        showLikeErrorCalled = false
        showLikeErrorCallCount = 0
        showLoadingErrorCalled = false
        showLoadingErrorCallCount = 0
        navigateToSingleImageCalled = false
        navigateToSingleImageCallCount = 0
        
        capturedPhotoId = nil
        capturedIsLiked = nil
        capturedError = nil
        capturedPhoto = nil
        capturedPreviewImage = nil
    }
}
