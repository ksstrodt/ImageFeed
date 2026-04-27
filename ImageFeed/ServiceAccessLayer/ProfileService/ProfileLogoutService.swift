//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by bot on 19.02.2026.
//
import Foundation
import WebKit
import Kingfisher
import SwiftKeychainWrapper

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    func logout() {
        cleanCookies()
        cleanTokensAndData()
        navigateToSplashScreen()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func cleanTokensAndData() {
        OAuth2TokenStorage.shared.token = nil
        ProfileService.shared.cleanProfileData()
        ProfileImageService.shared.cleanAvatarData()
        ImagesListService.shared.cleanImagesData()
        cleanKingfisherCache()
    }
    
    private func cleanKingfisherCache() {
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
        cache.cleanExpiredDiskCache()
    }
    
    private func navigateToSplashScreen() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }
}
extension ProfileLogoutService: ProfileLogoutServiceProtocol { }
