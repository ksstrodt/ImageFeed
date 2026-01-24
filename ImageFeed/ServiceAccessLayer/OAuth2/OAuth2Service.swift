//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by bot on 11.01.2026.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    // MARK: - Создание URLRequest
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
       
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            print("[OAuth2Service] Некорректный URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
       
        let parameters: [String: String] = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        
        let bodyString = parameters
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
        
        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded",
                        forHTTPHeaderField: "Content-Type")
        
       
        print("[OAuth2Service] Создан запрос для кода: \(code)")
        print("[OAuth2Service] Body: \(bodyString)")
        print("[OAuth2Service] Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        return request
    }
    
    // MARK: - Основная функция для получения токена
    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        
        guard self.lastCode != code else {
                print("[OAuth2Service] Запрос с этим кодом уже выполняется: \(code.prefix(10))...")
                completion(.failure(NetworkError.urlSessionError)) 
                return
            }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            let error = NetworkError.invalidRequest
            print("[OAuth2Service] Не удалось создать запрос для кода: \(code)")
            completion(.failure(error))
            lastCode = nil
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let responseBody):
                    OAuth2TokenStorage.shared.token = responseBody.accessToken
                    print("[OAuth2Service] Токен успешно получен: \(responseBody.accessToken.prefix(10))...")
                    print("[OAuth2Service] Token type: \(responseBody.tokenType)")
                    print("[OAuth2Service] Scope: \(responseBody.scope)")
                    completion(.success(responseBody.accessToken))
                case .failure(let error):
                    completion(.failure(error))
                }
                self?.lastCode = nil
                self?.task = nil
            }
        }
        
        self.task = task
        print("[OAuth2Service] Запускаем запрос токена для кода: \(code.prefix(10))...")
        task.resume()
    }
    
    // MARK: - Обработка ошибок
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .httpStatusCode(let statusCode):
                print("[OAuth2Service] HTTP ошибка от сервера Unsplash: статус код \(statusCode)")
            case .urlRequestError(let error):
                print("[OAuth2Service] Сетевая ошибка: \(error.localizedDescription)")
            case .urlSessionError:
                print("[OAuth2Service] Неизвестная ошибка URL сессии")
            case .invalidRequest:
                print("[OAuth2Service] Некорректный запрос к Unsplash API")
            case .decodingError(let error):
                print("[OAuth2Service] Ошибка декодирования ответа от Unsplash: \(error.localizedDescription)")
            }
        } else {
            print("[OAuth2Service] Неизвестная ошибка: \(error.localizedDescription)")
        }
    }
}
