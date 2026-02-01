//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by bot on 30.12.2025.
//

import Foundation
import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private let imageView = UIImageView()
    private let exitButton = UIButton(type: .system)
    
    private let nameLabel = UILabel()
    private let loginNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let profile = ProfileService.shared.profile {
            updateProfileDetails(profile: profile)
        }
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        
        setupImageView()
        setupExitButton()
        setupLabels()
        setupConstraints()
        updateProfileIfNeeded()
        updateAvatar()
        view.backgroundColor = UIColor(named: "YP Black (iOS)")
    }
    
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let imageUrl = URL(string: profileImageURL)
        else { return }

        print("imageUrl: \(imageUrl)")

        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))

        let processor = RoundCornerImageProcessor(cornerRadius: 35) // Радиус для круга
        KingfisherManager.shared.cache.removeImage(forKey: imageUrl.absoluteString)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: imageUrl,
            placeholder: placeholderImage,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale), 
                .cacheOriginalImage,
                .forceRefresh
            ]) { result in

                switch result {
                case .success(let value):
                    print(value.image)
                    print(value.cacheType)
                    print(value.source)
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           updateProfileIfNeeded()
       }
    
    private func setupImageView() {
        let image = UIImage(named: "Avatar")
        imageView.image = image
        
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
    }
    
    private func setupExitButton() {
        let exitIcon = UIImage(named: "Exit")
        exitButton.setImage(exitIcon, for: .normal)
        exitButton.tintColor = UIColor(named: "YP Red (iOS)")
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        
        exitButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
    }
    
    private func setupLabels() {
        
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        nameLabel.textColor = UIColor(named: "YP White (iOS)")
        nameLabel.text = "Екатерина Новикова"
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        
        loginNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        loginNameLabel.textColor = UIColor(named: "YP Gray (iOS)")
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = UIColor(named: "YP White (iOS)")
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.numberOfLines = 0 
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
        
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            
            
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            exitButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44),
            
            
            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: exitButton.leadingAnchor, constant: -8),
            
            
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
        ])
    }
    
    @objc private func exitButtonTapped() {
        print("Exit button tapped!")
        
    }
    
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name.isEmpty
            ? "Имя не указано"
            : profile.name
        loginNameLabel.text = profile.loginName.isEmpty
            ? "@неизвестный_пользователь"
            : profile.loginName
        descriptionLabel.text = (profile.bio?.isEmpty ?? true)
            ? "Профиль не заполнен"
            : profile.bio
    }
    
    private func updateProfileIfNeeded() {
            if ProfileService.shared.profile == nil {
                loadProfile()
            } else {
                updateProfileDetails(profile: ProfileService.shared.profile!)
                if let username = ProfileService.shared.profile?.username {
                    loadProfileImage(username: username)
                }
            }
        }
        
        private func loadProfile() {
            guard let token = OAuth2TokenStorage.shared.token else {
                return
            }
            
            ProfileService.shared.fetchProfile(token) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let profile):
                        self?.updateProfileDetails(profile: profile)
                        // Загружаем аватарку после получения профиля
                        self?.loadProfileImage(username: profile.username)
                    case .failure(let error):
                        print("Ошибка загрузки профиля: \(error)")
                    }
                }
            }
        }
        
        private func loadProfileImage(username: String) {
            guard let token = OAuth2TokenStorage.shared.token else {
                return
            }
            
            ProfileImageService.shared.fetchProfileImageURL(username: username) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        // Уведомление уже отправлено, и updateAvatar() будет вызван через наблюдатель
                        print("URL аватарки получен")
                    case .failure(let error):
                        print("Ошибка загрузки URL аватарки: \(error)")
                    }
                }
            }
        }
}
