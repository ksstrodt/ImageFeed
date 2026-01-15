//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by bot on 11.01.2026.
//
import Foundation

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    private let tokenKey = "bearerToken"
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue, forKey: tokenKey)
                print("[TokenStorage] Токен сохранен: \(newValue.prefix(10))...")
            } else {
                UserDefaults.standard.removeObject(forKey: tokenKey)
                print("[TokenStorage] Токен удален")
            }
        }
    }
}
