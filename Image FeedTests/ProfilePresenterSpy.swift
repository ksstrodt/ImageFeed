//
//  ProfilePresenterSpy.swift
//  Image FeedTests
//
//  Created by bot on 26.03.2026.
//
@testable import ImageFeed
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    
    weak var view: ProfileViewControllerProtocol?
    
    // MARK: - Call Tracking
    private(set) var viewDidLoadCalled = false
    private(set) var viewDidLoadCallCount = 0
    private(set) var didTapExitButtonCalled = false
    private(set) var didTapExitButtonCallCount = 0
    private(set) var updateAvatarCalled = false
    private(set) var updateAvatarCallCount = 0
    private(set) var loadProfileCalled = false
    private(set) var loadProfileCallCount = 0
    
    // MARK: - Captured Parameters
    private(set) var capturedUsername: String?
    
    // MARK: - Protocol Methods
    func viewDidLoad() {
        viewDidLoadCalled = true
        viewDidLoadCallCount += 1
    }
    
    func didTapExitButton() {
        didTapExitButtonCalled = true
        didTapExitButtonCallCount += 1
    }
    
    func updateAvatar() {
        updateAvatarCalled = true
        updateAvatarCallCount += 1
    }
    
    func loadProfile() {
        loadProfileCalled = true
        loadProfileCallCount += 1
    }
    
    // MARK: - Helper Methods
    func reset() {
        viewDidLoadCalled = false
        viewDidLoadCallCount = 0
        didTapExitButtonCalled = false
        didTapExitButtonCallCount = 0
        updateAvatarCalled = false
        updateAvatarCallCount = 0
        loadProfileCalled = false
        loadProfileCallCount = 0
        
        capturedUsername = nil
    }
}
