//
//  Image_FeedUITests.swift
//  Image FeedUITests
//
//  Created by bot on 31.03.2026.
//

import XCTest

class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
        sleep(3)
    }
    
    private func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 10) -> Bool {
        let exists = element.waitForExistence(timeout: timeout)
        if !exists {
            print("Element not found: \(element)")
            print("Available elements: \(app.buttons.allElementsBoundByIndex.map { "id: '\($0.identifier)', label: '\($0.label)'" })")
        }
        return exists
    }
    
    private var isLoggedIn: Bool {
        return app.tables.cells.firstMatch.exists
    }
    
    private func logout() {
        guard isLoggedIn else { return }
        
        let tabBar = app.tabBars.firstMatch
        if tabBar.waitForExistence(timeout: 5) {
            tabBar.buttons.element(boundBy: 1).tap()
            sleep(1)
        }
        
        let logoutButton = app.buttons["Exit"]
        if logoutButton.waitForExistence(timeout: 3) {
            logoutButton.tap()
            
            let alert = app.alerts.firstMatch
            if alert.waitForExistence(timeout: 3) {
                alert.buttons["Yes"].tap()
                sleep(2)
            }
        }
    }
    
    func testAuth() throws {

        if isLoggedIn {
            logout()
            sleep(2)
        }
        
        let authenticateButton = app.buttons["Authenticate"]
        
        if !authenticateButton.exists {
            let authButton = app.buttons.element(matching: NSPredicate(format: "label CONTAINS[c] %@", "authenticate"))
            XCTAssertTrue(waitForElement(authButton, timeout: 10), "Кнопка Authenticate не найдена")
            authButton.tap()
        } else {
            authenticateButton.tap()
        }
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(waitForElement(webView, timeout: 10), "WebView не загрузилась")
        
        let loginTextField = webView.textFields.firstMatch
        XCTAssertTrue(waitForElement(loginTextField, timeout: 10), "Поле ввода логина не найдено")
        loginTextField.tap()
        loginTextField.typeText("<Ваш e-mail>")
        webView.tap()
        sleep(1)
        
        let passwordTextField = webView.secureTextFields.firstMatch
        XCTAssertTrue(waitForElement(passwordTextField, timeout: 10), "Поле ввода пароля не найдено")
        passwordTextField.tap()
        passwordTextField.typeText("<Ваш пароль>")
        webView.tap()
        sleep(1)
        
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(waitForElement(loginButton, timeout: 10), "Кнопка Login не найдена")
        loginButton.tap()
        
        let cell = app.tables.cells.firstMatch
        XCTAssertTrue(waitForElement(cell, timeout: 15), "Лента не загрузилась")
    }
    
    func testFeed() throws {
        
        let table = app.tables.firstMatch
        XCTAssertTrue(table.waitForExistence(timeout: 15), "Таблица не загрузилась")
        
        sleep(3)
        
        table.swipeUp()
        sleep(2)
        
        let screenWidth = app.frame.width
        let screenHeight = app.frame.height
        
        let likeX = screenWidth - 50
        let likeY = screenHeight * 0.35
        let likeCoordinate = app.coordinate(withNormalizedOffset: CGVector(dx: likeX / screenWidth, dy: likeY / screenHeight))
        
        likeCoordinate.tap()
        sleep(1)
        
        likeCoordinate.tap()
        sleep(1)
        
        let cellX = screenWidth / 2
        let cellY = screenHeight * 0.35
        let cellCoordinate = app.coordinate(withNormalizedOffset: CGVector(dx: cellX / screenWidth, dy: cellY / screenHeight))
        
        cellCoordinate.tap()
        sleep(3)
        
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 15), "Полноэкранный режим не открылся")
        
        let image = scrollView.images.firstMatch
        XCTAssertTrue(image.waitForExistence(timeout: 10), "Изображение не загрузилось")
        
        sleep(2)
        
        image.pinch(withScale: 3, velocity: 1)
        sleep(1)
        
        image.pinch(withScale: 0.5, velocity: -1)
        sleep(1)
        
        let backButton = app.buttons["Backward"]
        if backButton.exists {
            backButton.tap()
        } else {
            let backCoordinate = app.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1))
            backCoordinate.tap()
        }
        
        sleep(2)
        XCTAssertTrue(table.waitForExistence(timeout: 10), "Не удалось вернуться к ленте")
    }
    
    func testProfile() throws {
        sleep(3)
        
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(waitForElement(tabBar, timeout: 10), "TabBar не найден")
        
        let profileTab = tabBar.buttons.element(boundBy: 1)
        XCTAssertTrue(waitForElement(profileTab, timeout: 5), "Вкладка профиля не найдена")
        profileTab.tap()
        
        sleep(3)
        
        let nameLabel = app.staticTexts.element(matching: NSPredicate(format: "label CONTAINS[c] %@", "kirill"))
        let usernameLabel = app.staticTexts.element(matching: NSPredicate(format: "label CONTAINS[c] %@", "ksstrodt"))
        
        let hasName = nameLabel.exists || usernameLabel.exists
        print("Name label exists: \(nameLabel.exists), Username label exists: \(usernameLabel.exists)")
        
        let logoutButton = app.buttons["Exit"]
        XCTAssertTrue(waitForElement(logoutButton, timeout: 5), "Кнопка выхода не найдена")
        logoutButton.tap()
        
        let alert = app.alerts.firstMatch
        if alert.waitForExistence(timeout: 5) {
            let yesButton = alert.buttons["Yes"]
            if yesButton.exists {
                yesButton.tap()
            } else {
                alert.buttons.firstMatch.tap()
            }
        }
        
        sleep(2)
        let authButton = app.buttons["Authenticate"]
        let isOnAuthScreen = authButton.waitForExistence(timeout: 5)
        
        XCTAssertTrue(isOnAuthScreen, "Не вернулись на экран авторизации. Найденные кнопки: \(app.buttons.allElementsBoundByIndex.map { $0.label })")
    }
}
