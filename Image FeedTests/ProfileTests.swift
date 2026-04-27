//
//  ProfileTests.swift
//  Image FeedTests
//
//  Created by bot on 26.03.2026.
//
@testable import ImageFeed
import XCTest

@MainActor
final class ProfileTests: XCTestCase {
    
    // MARK: - ProfileViewController Tests
    func testViewControllerCallsViewDidLoad() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsDisplayProfileDetails() {
        // given
        let viewController = ProfileViewControllerSpy()
        let profileService = MockProfileService()
        let profileImageService = MockProfileImageService()
        let logoutService = MockProfileLogoutService()
        let presenter = ProfilePresenter(
            profileService: profileService,
            profileImageService: profileImageService,
            logoutService: logoutService
        )
        viewController.presenter = presenter
        presenter.view = viewController
        
        let mockProfile = Profile(
            username: "testuser",
            name: "Test User",
            loginName: "@testuser",
            bio: "Test bio"
        )
        profileService.profile = mockProfile
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(viewController.displayProfileDetailsCalled)
        XCTAssertEqual(viewController.capturedName, "Test User")
        XCTAssertEqual(viewController.capturedLoginName, "@testuser")
        XCTAssertEqual(viewController.capturedBio, "Test bio")
    }
    
    func testExitButtonTappedCallsPresenterDidTapExitButton() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)
        _ = viewController.view
        
        // when
        viewController.exitButtonTapped()
        
        // then
        XCTAssertTrue(presenter.didTapExitButtonCalled)
    }
    
    func testDisplayAvatarWithValidURL() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        let testURL = URL(string: "https://example.com/avatar.jpg")!
        
        // when
        viewController.displayAvatar(with: testURL)
        
        // then
        XCTAssertTrue(viewController.displayAvatarCalled)
        XCTAssertEqual(viewController.capturedAvatarURL, testURL)
    }
    
    func testShowLogoutConfirmation() {
        // given
        let viewController = ProfileViewControllerSpy()
        
        // when
        viewController.showLogoutConfirmation()
        
        // then
        XCTAssertTrue(viewController.showLogoutConfirmationCalled)
    }
    
    func testShowError() {
        // given
        let viewController = ProfileViewControllerSpy()
        let testError = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        
        // when
        viewController.showError(testError)
        
        // then
        XCTAssertTrue(viewController.showErrorCalled)
        XCTAssertNotNil(viewController.capturedError)
    }
}

// MARK: - Mock Services
class MockProfileService: ProfileServiceProtocol {
    var profile: Profile?
    var fetchProfileResult: Result<Profile, Error>?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        if let result = fetchProfileResult {
            completion(result)
        }
    }
    
    func cleanProfileData() {
        profile = nil
    }
}

class MockProfileImageService: ProfileImageServiceProtocol {
    var avatarURL: String?
    var fetchProfileImageResult: Result<String, Error>?
    
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        if let result = fetchProfileImageResult {
            completion(result)
        }
    }
    
    func cleanAvatarData() {
        avatarURL = nil
    }
}

class MockProfileLogoutService: ProfileLogoutServiceProtocol {
    var logoutCalled = false
    
    func logout() {
        logoutCalled = true
    }
}
