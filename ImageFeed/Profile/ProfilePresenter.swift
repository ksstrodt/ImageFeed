//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by bot on 26.03.2026.
//
import Foundation
import Kingfisher

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let logoutService: ProfileLogoutServiceProtocol
    private var profileImageObserver: NSObjectProtocol?
    
    init(
        profileService: ProfileServiceProtocol = ProfileService.shared,
        profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared,
        logoutService: ProfileLogoutServiceProtocol = ProfileLogoutService.shared
    ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.logoutService = logoutService
    }
    
    func viewDidLoad() {
        print("[ProfilePresenter] viewDidLoad called")
        setupObservers()
        loadProfile()
        updateAvatar()
    }
    
    private func setupObservers() {
        profileImageObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                print("[ProfilePresenter] Received avatar change notification")
                if let userInfo = notification.userInfo,
                   let urlString = userInfo["URL"] as? String {
                    print("[ProfilePresenter] New avatar URL: \(urlString)")
                }
                self?.updateAvatar()
            }
    }
    
    func loadProfile() {
        print("[ProfilePresenter] loadProfile called")
        if let profile = profileService.profile {
            print("[ProfilePresenter] Using existing profile: \(profile.username)")
            updateProfileUI(with: profile)
        } else {
            print("[ProfilePresenter] Fetching new profile")
            fetchProfile()
        }
    }
    
    private func fetchProfile() {
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ProfilePresenter] No token available")
            return
        }
        
        print("[ProfilePresenter] Fetching profile with token")
        profileService.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    print("[ProfilePresenter] Successfully fetched profile: \(profile.username)")
                    self?.updateProfileUI(with: profile)
                    self?.fetchProfileImage(username: profile.username)
                case .failure(let error):
                    print("[ProfilePresenter] Error fetching profile: \(error)")
                    self?.view?.showError(error)
                }
            }
        }
    }
    
    private func updateProfileUI(with profile: Profile) {
        let name = profile.name.isEmpty ? "Имя не указано" : profile.name
        let loginName = profile.loginName.isEmpty ? "@неизвестный_пользователь" : profile.loginName
        let bio: String
        if let bioText = profile.bio, !bioText.isEmpty {
            bio = bioText
        } else {
            bio = "Профиль не заполнен"
        }
        
        print("[ProfilePresenter] Updating UI with name: \(name), login: \(loginName)")
        view?.displayProfileDetails(name: name, loginName: loginName, bio: bio)
    }
    
    private func fetchProfileImage(username: String) {
        print("[ProfilePresenter] Fetching profile image for username: \(username)")
        
        profileImageService.fetchProfileImageURL(username: username) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let urlString):
                    print("[ProfilePresenter] Successfully fetched avatar URL: \(urlString)")
                    // Avatar will be updated via notification
                case .failure(let error):
                    print("[ProfilePresenter] Error fetching avatar URL: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateAvatar() {
        print("[ProfilePresenter] updateAvatar called")
        
        guard let avatarURLString = profileImageService.avatarURL else {
            print("[ProfilePresenter] No avatar URL available")
            return
        }
        
        print("[ProfilePresenter] Avatar URL: \(avatarURLString)")
        
        guard let imageUrl = URL(string: avatarURLString) else {
            print("[ProfilePresenter] Invalid URL string: \(avatarURLString)")
            return
        }
        
        view?.displayAvatar(with: imageUrl)
    }
    
    func didTapExitButton() {
        view?.showLogoutConfirmation()
    }
    
    deinit {
        if let observer = profileImageObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
