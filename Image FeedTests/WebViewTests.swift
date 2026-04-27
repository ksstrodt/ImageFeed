//
//  Image_FeedTests.swift
//  Image FeedTests
//
//  Created by bot on 17.03.2026.
//
@testable import ImageFeed
import XCTest

@MainActor
final class WebViewTests: XCTestCase {
    
    // Тестовая конфигурация для изоляции тестов
    private let testConfiguration = AuthConfiguration(
        accessKey: "test_access_key",
        secretKey: "test_secret_key",
        redirectURI: "test_redirect_uri",
        accessScope: "test_scope",
        authURLString: "https://test.com/oauth/authorize",
        defaultBaseURLString: "https://test.com/api"
    )
    
    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest() async {
        // given
        let viewController = WebViewViewControllerSpy()
        let authHelper = await MainActor.run { AuthHelper(configuration: testConfiguration) }
        let presenter = await MainActor.run { WebViewPresenter(authHelper: authHelper) }
        
        await MainActor.run {
            viewController.presenter = presenter
            presenter.view = viewController
        }
        
        // when
        await MainActor.run {
            presenter.viewDidLoad()
        }
        
        // then
        XCTAssertTrue(viewController.loadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() async {
        // given
        let authHelper = await MainActor.run { AuthHelper(configuration: testConfiguration) }
        let presenter = await MainActor.run { WebViewPresenter(authHelper: authHelper) }
        let progress: Float = 0.6
        
        // when
        let shouldHideProgress = await MainActor.run {
            presenter.shouldHideProgress(for: progress)
        }
        
        // then
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() async {
        // given
        let authHelper = await MainActor.run { AuthHelper(configuration: testConfiguration) }
        let presenter = await MainActor.run { WebViewPresenter(authHelper: authHelper) }
        let progress: Float = 1.0
        
        // when
        let shouldHideProgress = await MainActor.run {
            presenter.shouldHideProgress(for: progress)
        }
        
        // then
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() async {
        // given
        let authHelper = await MainActor.run { AuthHelper(configuration: testConfiguration) }
        
        // when
        let url = await MainActor.run { authHelper.authURL() }
        
        // then
        XCTAssertNotNil(url, "Auth URL should not be nil")
        
        guard let urlString = url?.absoluteString else {
            XCTFail("Авторизационная ссылка собрана неверно")
            return
        }
        
        XCTAssertTrue(urlString.contains(testConfiguration.authURLString))
        XCTAssertTrue(urlString.contains(testConfiguration.accessKey))
        XCTAssertTrue(urlString.contains(testConfiguration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(testConfiguration.accessScope))
    }
    
    func testCodeFromURL() async {
        // given
        let authHelper = await MainActor.run { AuthHelper(configuration: testConfiguration) }
        let urlString = "https://unsplash.com/oauth/authorize/native?code=test_code"
        guard let url = URL(string: urlString) else {
            XCTFail("Invalid URL")
            return
        }
        
        // when
        let code = await MainActor.run { authHelper.code(from: url) }
        
        // then
        XCTAssertEqual(code, "test_code")
    }
}
