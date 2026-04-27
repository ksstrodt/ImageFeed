//
//  ProfilePresenterProtocol.swift
//  ImageFeed
//
//  Created by bot on 26.03.2026.
//

import Foundation

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapExitButton()
    func updateAvatar()
    func loadProfile()
}

protocol ProfileViewControllerProtocol: AnyObject {
    func displayProfileDetails(name: String, loginName: String, bio: String)
    func displayAvatar(with url: URL?)
    func showLogoutConfirmation()
    func performLogout()
    func showError(_ error: Error)
}
