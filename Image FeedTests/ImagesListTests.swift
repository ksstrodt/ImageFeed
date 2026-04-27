//
//  ImagesListTests.swift
//  Image FeedTests
//
//  Created by bot on 26.03.2026.
//
@testable import ImageFeed
import XCTest
import UIKit

@MainActor
final class ImagesListTests: XCTestCase {
    
    // MARK: - ImagesListViewController Tests
    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsUpdateTableView() {
        // given
        let viewController = ImagesListViewControllerSpy()
        let imagesListService = MockImagesListService()
        let presenter = ImagesListPresenter(imagesListService: imagesListService)
        viewController.presenter = presenter
        presenter.view = viewController
        
        let mockPhotos = createMockPhotos(count: 5)
        
        let expectation = XCTestExpectation(description: "Update table view called")
        
        let observer = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: imagesListService,
            queue: .main
        ) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                // then
                XCTAssertTrue(viewController.updateTableViewAnimatedCalled)
                XCTAssertEqual(presenter.photosCount, 5)
                expectation.fulfill()
            }
        }
        
        // when
        presenter.viewDidLoad()
        
        imagesListService.photos = mockPhotos
        
        wait(for: [expectation], timeout: 1.0)
        
        NotificationCenter.default.removeObserver(observer)
    }
    
    func testDidSelectRowCallsPresenterDidSelectPhoto() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        presenter.stubbedPhotosCount = 10
        viewController.configure(presenter)
        _ = viewController.view
        
        // when
        let tableView = viewController.tableView!
        let indexPath = IndexPath(row: 2, section: 0)
        viewController.tableView(tableView, didSelectRowAt: indexPath)
        
        // then
        XCTAssertTrue(presenter.didSelectPhotoCalled)
        XCTAssertEqual(presenter.capturedDidSelectPhotoIndex, 2)
    }
    
    func testWillDisplayLastRowCallsPresenterWillDisplayCell() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        presenter.stubbedPhotosCount = 10
        viewController.configure(presenter)
        _ = viewController.view
        
        // when
        let tableView = viewController.tableView!
        let indexPath = IndexPath(row: 9, section: 0)
        viewController.tableView(tableView, willDisplay: UITableViewCell(), forRowAt: indexPath)
        
        // then
        XCTAssertTrue(presenter.willDisplayCellCalled)
        XCTAssertEqual(presenter.capturedWillDisplayCellIndex, 9)
    }
    
    func testCellForRowCallsPresenterConfigureCell() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        presenter.stubbedPhotosCount = 3
        presenter.stubbedPhotos = createMockPhotos(count: 3)
        viewController.configure(presenter)
        _ = viewController.view
        
        // when
        let tableView = viewController.tableView!
        let indexPath = IndexPath(row: 0, section: 0)
        _ = viewController.tableView(tableView, cellForRowAt: indexPath)
        
        // then
        XCTAssertTrue(presenter.configureCellCalled)
        XCTAssertEqual(presenter.capturedConfigureCell?.index, 0)
    }
    
    func testDidTapLikeCallsPresenterDidTapLike() {
        // given
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        
        // when
        viewController.simulateLikeTap(at: 2)
        
        // then
        XCTAssertTrue(presenter.didTapLikeCalled)
        XCTAssertEqual(presenter.capturedDidTapLikeIndex, 2)
    }
    
    func testUpdateLikeInTableView() {
        // given
        let viewController = ImagesListViewControllerSpy()
        
        // when
        viewController.updateLikeInTableView(photoId: "test_photo", isLiked: true)
        
        // then
        XCTAssertTrue(viewController.updateLikeInTableViewCalled)
        XCTAssertEqual(viewController.capturedPhotoId, "test_photo")
        XCTAssertEqual(viewController.capturedIsLiked, true)
    }
    
    func testShowLikeError() {
        // given
        let viewController = ImagesListViewControllerSpy()
        
        // when
        viewController.showLikeError()
        
        // then
        XCTAssertTrue(viewController.showLikeErrorCalled)
    }
    
    func testNavigateToSingleImage() {
        // given
        let viewController = ImagesListViewControllerSpy()
        let mockPhoto = createMockPhoto(id: "test_photo")
        
        // when
        viewController.navigateToSingleImage(with: mockPhoto, previewImage: nil)
        
        // then
        XCTAssertTrue(viewController.navigateToSingleImageCalled)
        XCTAssertEqual(viewController.capturedPhoto?.id, "test_photo")
    }
    
    func testLoadNextPage() {
        // given
        let imagesListService = MockImagesListService()
        let presenter = ImagesListPresenter(imagesListService: imagesListService)
        
        // when
        presenter.loadNextPage()
        
        // then
        XCTAssertTrue(imagesListService.fetchPhotosNextPageCalled)
    }
    
    func testPhotoAtIndex() {
        // given
        let imagesListService = MockImagesListService()
        let presenter = ImagesListPresenter(imagesListService: imagesListService)
        let mockPhotos = createMockPhotos(count: 3)
        
        let expectation = XCTestExpectation(description: "Photos updated")
        
        let observer = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: imagesListService,
            queue: .main
        ) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                // when
                let photo = presenter.photo(at: 1)
                
                // then
                XCTAssertNotNil(photo)
                XCTAssertEqual(photo?.id, "photo_1")
                expectation.fulfill()
            }
        }
        
        // when
        presenter.viewDidLoad()
        
        imagesListService.photos = mockPhotos
        
        wait(for: [expectation], timeout: 1.0)
        NotificationCenter.default.removeObserver(observer)
    }
    
    func testPhotoAtIndexOutOfRange() {
        // given
        let imagesListService = MockImagesListService()
        let presenter = ImagesListPresenter(imagesListService: imagesListService)
        let mockPhotos = createMockPhotos(count: 3)
        imagesListService.photos = mockPhotos
        presenter.viewDidLoad()
        
        // when
        let photo = presenter.photo(at: 5)
        
        // then
        XCTAssertNil(photo)
    }
    
    // MARK: - Helper Methods
    private func createMockPhoto(id: String = "photo_0", isLiked: Bool = false) -> Photo {
        return Photo(
            id: id,
            size: CGSize(width: 100, height: 100),
            createdAt: Date(),
            welcomeDescription: "Test description",
            thumbImageURL: "https://example.com/thumb.jpg",
            largeImageURL: "https://example.com/large.jpg",
            isLiked: isLiked
        )
    }
    
    private func createMockPhotos(count: Int, isLiked: Bool = false) -> [Photo] {
        var photos: [Photo] = []
        for i in 0..<count {
            photos.append(createMockPhoto(id: "photo_\(i)", isLiked: isLiked))
        }
        return photos
    }
}

// MARK: - Mock Objects
final class MockImagesListService: ImagesListServiceProtocol {
    var photos: [Photo] = [] {
        didSet {
            // Отправляем уведомление при изменении photos
            NotificationCenter.default.post(
                name: ImagesListService.didChangeNotification,
                object: self
            )
        }
    }
    var fetchPhotosNextPageCalled = false
    var fetchPhotosNextPageCallCount = 0
    var changeLikeCalled = false
    var changeLikeResult: Result<Void, Error>?
    var cleanImagesDataCalled = false
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
        fetchPhotosNextPageCallCount += 1
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
        if let result = changeLikeResult {
            completion(result)
        }
    }
    
    func cleanImagesData() {
        cleanImagesDataCalled = true
    }
}
