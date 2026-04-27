//
//  ImagesListPresenterSpy.swift
//  Image FeedTests
//
//  Created by bot on 26.03.2026.
//
@testable import ImageFeed
import Foundation
import UIKit

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    
    weak var view: ImagesListViewControllerProtocol?
    
    // MARK: - Stubbed Properties
    var stubbedPhotosCount: Int = 0
    var stubbedPhotos: [Photo] = []
    
    // MARK: - Call Tracking
    private(set) var viewDidLoadCalled = false
    private(set) var viewDidLoadCallCount = 0
    private(set) var loadNextPageCalled = false
    private(set) var loadNextPageCallCount = 0
    private(set) var didSelectPhotoCalled = false
    private(set) var didSelectPhotoCallCount = 0
    private(set) var didTapLikeCalled = false
    private(set) var didTapLikeCallCount = 0
    private(set) var willDisplayCellCalled = false
    private(set) var willDisplayCellCallCount = 0
    private(set) var configureCellCalled = false
    private(set) var configureCellCallCount = 0
    
    // MARK: - Captured Parameters
    private(set) var capturedDidSelectPhotoIndex: Int?
    private(set) var capturedDidTapLikeIndex: Int?
    private(set) var capturedWillDisplayCellIndex: Int?
    private(set) var capturedConfigureCell: (cell: ImagesListCell, index: Int)?
    
    // MARK: - Protocol Properties
    var photosCount: Int {
        return stubbedPhotosCount
    }
    
    // MARK: - Protocol Methods
    func viewDidLoad() {
        viewDidLoadCalled = true
        viewDidLoadCallCount += 1
    }
    
    func loadNextPage() {
        loadNextPageCalled = true
        loadNextPageCallCount += 1
    }
    
    func photo(at index: Int) -> Photo? {
        guard index < stubbedPhotos.count else { return nil }
        return stubbedPhotos[index]
    }
    
    func didSelectPhoto(at index: Int) {
        didSelectPhotoCalled = true
        didSelectPhotoCallCount += 1
        capturedDidSelectPhotoIndex = index
    }
    
    func didTapLike(at index: Int) {
        didTapLikeCalled = true
        didTapLikeCallCount += 1
        capturedDidTapLikeIndex = index
    }
    
    func willDisplayCell(at index: Int) {
        willDisplayCellCalled = true
        willDisplayCellCallCount += 1
        capturedWillDisplayCellIndex = index
    }
    
    func configureCell(_ cell: ImagesListCell, at index: Int) {
        configureCellCalled = true
        configureCellCallCount += 1
        capturedConfigureCell = (cell, index)
    }
    
    // MARK: - Helper Methods
    func reset() {
        viewDidLoadCalled = false
        viewDidLoadCallCount = 0
        loadNextPageCalled = false
        loadNextPageCallCount = 0
        didSelectPhotoCalled = false
        didSelectPhotoCallCount = 0
        didTapLikeCalled = false
        didTapLikeCallCount = 0
        willDisplayCellCalled = false
        willDisplayCellCallCount = 0
        configureCellCalled = false
        configureCellCallCount = 0
        
        capturedDidSelectPhotoIndex = nil
        capturedDidTapLikeIndex = nil
        capturedWillDisplayCellIndex = nil
        capturedConfigureCell = nil
    }
}
