//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by bot on 15.01.2026.
//
import UIKit

final class SplashViewController: UIViewController {
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private let storage = OAuth2TokenStorage.shared
    
    private var imageView: UIImageView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupImageView()
        
        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            presentAuthViewController()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func setupImageView() {
        let imageSplashScreenLogo = UIImage(named: "splashScreenLogo")
        
        imageView = UIImageView(image: imageSplashScreenLogo)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func presentAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            assertionFailure("Не удалось найти AuthViewController по идентификатору")
            return
        }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarController")
        window.rootViewController = tabBarController
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                print("[SplashViewController] Profile fetched: \(profile.username)")
                // Загружаем аватар после получения профиля
                self.fetchProfileImage(username: profile.username)
                self.switchToTabBarController()
                UIBlockingProgressHUD.dismiss()
                
            case .failure(let error):
                print("[SplashViewController] Error fetching profile: \(error)")
                UIBlockingProgressHUD.dismiss()
                self.showAlertAndRetry()
            }
        }
    }
    
    private func fetchProfileImage(username: String) {
        print("[SplashViewController] Fetching profile image for username: \(username)")
        
        profileImageService.fetchProfileImageURL(username: username) { result in
            switch result {
            case .success(let urlString):
                print("[SplashViewController] Avatar URL fetched successfully: \(urlString)")
            case .failure(let error):
                print("[SplashViewController] Error fetching avatar URL: \(error.localizedDescription)")
            }
        }
    }
    
    private func showAlertAndRetry() {
        let alert = UIAlertController(
            title: "Ошибка загрузки профиля",
            message: "Не удалось загрузить данные пользователя. Попробуйте еще раз.",
            preferredStyle: .alert
        )
        
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            guard let token = self?.storage.token else {
                self?.presentAuthViewController()
                return
            }
            self?.fetchProfile(token: token)
        }
        
        let cancelAction = UIAlertAction(title: "Выйти", style: .destructive) { [weak self] _ in
            self?.storage.token = nil
            self?.presentAuthViewController()
        }
        
        alert.addAction(retryAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        guard let token = OAuth2TokenStorage.shared.token else {
            return
        }
        fetchProfile(token: token)
    }
}
