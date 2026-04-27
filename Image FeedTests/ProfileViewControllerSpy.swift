//
//  ProfileViewControllerSpy.swift
//  Image FeedTests
//
//  Created by bot on 26.03.2026.
//
@testable import ImageFeed
import UIKit

final class ProfileViewControllerSpy: UIViewController, ProfileViewControllerProtocol {
    
    var presenter: ProfilePresenterProtocol?
    
    // MARK: - Call Tracking
    private(set) var displayProfileDetailsCalled = false
    private(set) var displayProfileDetailsCallCount = 0
    private(set) var displayAvatarCalled = false
    private(set) var displayAvatarCallCount = 0
    private(set) var showLogoutConfirmationCalled = false
    private(set) var showLogoutConfirmationCallCount = 0
    private(set) var performLogoutCalled = false
    private(set) var performLogoutCallCount = 0
    private(set) var showErrorCalled = false
    private(set) var showErrorCallCount = 0
    
    // MARK: - Captured Parameters
    private(set) var capturedName: String?
    private(set) var capturedLoginName: String?
    private(set) var capturedBio: String?
    private(set) var capturedAvatarURL: URL?
    private(set) var capturedError: Error?
    
    // MARK: - Protocol Methods
    func displayProfileDetails(name: String, loginName: String, bio: String) {
        displayProfileDetailsCalled = true
        displayProfileDetailsCallCount += 1
        capturedName = name
        capturedLoginName = loginName
        capturedBio = bio
    }
    
    func displayAvatar(with url: URL?) {
        displayAvatarCalled = true
        displayAvatarCallCount += 1
        capturedAvatarURL = url
    }
    
    func showLogoutConfirmation() {
        showLogoutConfirmationCalled = true
        showLogoutConfirmationCallCount += 1
    }
    
    func performLogout() {
        performLogoutCalled = true
        performLogoutCallCount += 1
    }
    
    func showError(_ error: Error) {
        showErrorCalled = true
        showErrorCallCount += 1
        capturedError = error
    }
    
    // MARK: - Helper Methods
    func reset() {
        displayProfileDetailsCalled = false
        displayProfileDetailsCallCount = 0
        displayAvatarCalled = false
        displayAvatarCallCount = 0
        showLogoutConfirmationCalled = false
        showLogoutConfirmationCallCount = 0
        performLogoutCalled = false
        performLogoutCallCount = 0
        showErrorCalled = false
        showErrorCallCount = 0
        
        capturedName = nil
        capturedLoginName = nil
        capturedBio = nil
        capturedAvatarURL = nil
        capturedError = nil
    }
}
