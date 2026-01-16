//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by bot on 08.01.2026.
//
import UIKit

// MARK: - AuthViewControllerDelegate

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}
// MARK: - AuthViewController

final class AuthViewController: UIViewController {
    
    // MARK: - Constants
    
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    // MARK: - Dependencies
    
    private let oauth2Service = OAuth2Service.shared
    
    // MARK: - Properties
    
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - UI Configuration
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black (iOS)")
    }
}

// MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
            fetchOAuthToken(code) { [weak self] result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        vc.dismiss(animated: true) {
                            self.delegate?.didAuthenticate(self)
                        }
                    }
                case .failure(let error):
                    print("[Auth] Ошибка: \(error)")
                }
            }
        }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}

extension AuthViewController {
    private func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        oauth2Service.fetchOAuthToken(code: code) { result in
            completion(result)
        }
    }
}

