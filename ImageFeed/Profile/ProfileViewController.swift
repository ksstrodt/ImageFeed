//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by bot on 30.12.2025.
//
import UIKit
import Kingfisher

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    // MARK: - UI Elements
    private let imageView = UIImageView()
    private let exitButton = UIButton(type: .system)
    private let nameLabel = UILabel()
    private let loginNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    // MARK: - Dependencies
    private var presenter: ProfilePresenterProtocol!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        configurePresenter()
        presenter.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP Black (iOS)")
    }
    
    // MARK: - Configuration
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    private func configurePresenter() {
        if presenter == nil {
            presenter = ProfilePresenter()
            presenter.view = self
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        setupImageView()
        setupExitButton()
        setupLabels()
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35 // Добавляем скругление углов
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        imageView.image = placeholderImage
    }
    
    private func setupExitButton() {
        let exitIcon = UIImage(named: "Exit")
        exitButton.setImage(exitIcon, for: .normal)
        exitButton.tintColor = UIColor(named: "YP Red (iOS)")
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.accessibilityIdentifier = "logout button"
        exitButton.accessibilityLabel = "Exit"
        view.addSubview(exitButton)
        exitButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
    }
    
    private func setupLabels() {
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        nameLabel.textColor = UIColor(named: "YP White (iOS)")
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        loginNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        loginNameLabel.textColor = UIColor(named: "YP Gray (iOS)")
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = UIColor(named: "YP White (iOS)")
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
    
    // MARK: - Actions
    @objc func exitButtonTapped() {
        presenter.didTapExitButton()
    }
    
    // MARK: - ProfileViewControllerProtocol
    func displayProfileDetails(name: String, loginName: String, bio: String) {
        print("[ProfileViewController] Displaying profile details - Name: \(name), Login: \(loginName), Bio: \(bio)")
        nameLabel.text = name
        loginNameLabel.text = loginName
        descriptionLabel.text = bio
    }
    
    func displayAvatar(with url: URL?) {
        guard let url = url else {
            print("[ProfileViewController] No URL for avatar")
            return
        }
        
        print("[ProfileViewController] Loading avatar from URL: \(url.absoluteString)")
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: url,
            placeholder: imageView.image,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .forceRefresh
            ]
        ) { result in
            switch result {
            case .success(let value):
                print("[ProfileViewController] Successfully loaded avatar: \(value.source.url?.absoluteString ?? "unknown")")
            case .failure(let error):
                print("[ProfileViewController] Error loading avatar: \(error.localizedDescription)")
            }
        }
    }
    
    func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        let logoutAction = UIAlertAction(title: "Да", style: .destructive) { [weak self] _ in
            self?.performLogout()
        }
        
        let cancelAction = UIAlertAction(title: "Нет", style: .default)
        
        alert.addAction(logoutAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func performLogout() {
        UIBlockingProgressHUD.show()
        
        ProfileLogoutService.shared.logout()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIBlockingProgressHUD.dismiss()
        }
    }
    
    func showError(_ error: Error) {
        print("[ProfileViewController] Error: \(error.localizedDescription)")
        let alert = UIAlertController(
            title: "Ошибка",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
