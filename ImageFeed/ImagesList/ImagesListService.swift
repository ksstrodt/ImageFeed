//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by bot on 08.02.2026.
//
import Foundation
import Kingfisher
internal import CoreGraphics

final class ImagesListService {
    static let shared = ImagesListService()
        static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
        static let didChangeLikeNotification = Notification.Name(rawValue: "ImagesListServiceDidChangeLike")
        
        private(set) var photos: [Photo] = []
        private var lastLoadedPage: Int?
        private var task: URLSessionTask?
        private var likeTasks: [String: URLSessionTask] = [:]
        private let perPage = 10
        
        private init() {}

    
    func fetchPhotosNextPage() {
        guard task == nil else {
            print("[ImagesListService.fetchPhotosNextPage] Запрос отменён: предыдущая загрузка ещё выполняется")
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ImagesListService.fetchPhotosNextPage] Ошибка: отсутствует токен авторизации")
            return
        }
        
        guard var urlComponents = URLComponents(string: "https://api.unsplash.com/photos") else {
            print("[ImagesListService.fetchPhotosNextPage] Ошибка: не удалось создать URLComponents")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        
        guard let url = urlComponents.url else {
            print("[ImagesListService.fetchPhotosNextPage] Ошибка: не удалось создать URL из компонентов")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("[ImagesListService.fetchPhotosNextPage] Загрузка страницы \(nextPage) с параметрами: per_page=\(perPage)")
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let photoResults):
                print("[ImagesListService.fetchPhotosNextPage] Успешно загружено \(photoResults.count) фотографий для страницы \(nextPage)")
                
                let newPhotos = photoResults.map { photoResult in
                    return self.convertToPhoto(from: photoResult)
                }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
                
            case .failure(let error):
                // Улучшенное логирование ошибки
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .httpStatusCode(let statusCode):
                        print("[ImagesListService.fetchPhotosNextPage] HTTP ошибка при загрузке страницы \(nextPage): статус код \(statusCode)")
                    case .decodingError(let decodingError):
                        print("[ImagesListService.fetchPhotosNextPage] Ошибка декодирования для страницы \(nextPage): \(decodingError.localizedDescription)")
                    default:
                        print("[ImagesListService.fetchPhotosNextPage] Сетевая ошибка при загрузке страницы \(nextPage): \(networkError.localizedDescription)")
                    }
                } else {
                    print("[ImagesListService.fetchPhotosNextPage] Неизвестная ошибка при загрузке страницы \(nextPage): \(error.localizedDescription)")
                }
            }
            
            self.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
          
           likeTasks[photoId]?.cancel()
           
           let httpMethod = isLike ? "POST" : "DELETE"
           
           guard let token = OAuth2TokenStorage.shared.token,
                 let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
               completion(.failure(NetworkError.invalidRequest))
               return
           }
           
           var request = URLRequest(url: url)
           request.httpMethod = httpMethod
           request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
           
           let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<LikePhotoResult, Error>) in
               guard let self = self else { return }
               
               defer {
                   self.likeTasks[photoId] = nil
               }
               
               switch result {
               case .success(let likeResult):
                   DispatchQueue.main.async {
                      
                       if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                           let photo = self.photos[index]
                           let updatedPhoto = Photo(
                               id: photo.id,
                               size: photo.size,
                               createdAt: photo.createdAt,
                               welcomeDescription: photo.welcomeDescription,
                               thumbImageURL: photo.thumbImageURL,
                               largeImageURL: photo.largeImageURL,
                               isLiked: likeResult.photo.likedByUser
                           )
                           self.photos[index] = updatedPhoto
                           
                          
                           NotificationCenter.default.post(
                               name: ImagesListService.didChangeLikeNotification,
                               object: self,
                               userInfo: [
                                   "photoId": photoId,
                                   "isLiked": updatedPhoto.isLiked,
                                   "index": index
                               ]
                           )
                       }
                       completion(.success(()))
                   }
                   
               case .failure(let error):
                   DispatchQueue.main.async {
                       print("[ImagesListService] Ошибка при \(isLike ? "лайке" : "дизлайке"): \(error.localizedDescription)")
                       completion(.failure(error))
                   }
               }
           }
           
           likeTasks[photoId] = task
           task.resume()
       }
    
    func clearPhotos() {
            photos = []
            lastLoadedPage = nil
           
            likeTasks.values.forEach { $0.cancel() }
            likeTasks.removeAll()
        }
    
    private func convertToPhoto(from photoResult: PhotoResult) -> Photo {
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: photoResult.createdAt ?? "")
        
        return Photo(
            id: photoResult.id,
            size: CGSize(width: photoResult.width, height: photoResult.height),
            createdAt: date,
            welcomeDescription: photoResult.description,
            thumbImageURL: photoResult.urls.thumb,
            largeImageURL: photoResult.urls.full,
            isLiked: photoResult.likedByUser
        )
    }
    
   
    struct LikePhotoResult: Decodable {
        let photo: PhotoResult
    }
    
    func cleanImagesData() {
        photos = []
        lastLoadedPage = nil
        task?.cancel()
        task = nil
        
        
        likeTasks.values.forEach { $0.cancel() }
        likeTasks.removeAll()
        
        
        cleanImagesCache()
    }

    private func cleanImagesCache() {
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
    }
}
