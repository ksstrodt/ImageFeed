//
//  ServiceProtocols.swift
//  ImageFeed
//
//  Created by bot on 26.03.2026.
//
import Foundation

protocol ProfileServiceProtocol {
    var profile: Profile? { get }
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void)
    func cleanProfileData()
}

protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void)
    func cleanAvatarData()
}

protocol ProfileLogoutServiceProtocol {
    func logout()
}

protocol ImagesListServiceProtocol {
    var photos: [Photo] { get }
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
    func cleanImagesData()
}
