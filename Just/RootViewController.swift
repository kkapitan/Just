//
//  RootViewController.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit
import RxSwift

enum SessionStatus {
    case signedIn
    case notSignedIn
}

final class RootViewController: UIViewController {
    
    fileprivate var isInitialPresentation: Bool = true
    
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let launchScreen = Wireframe.Launch().launchScreen()
        addChildViewController(launchScreen)
        launchScreen.view.frame = view.bounds
        view.addSubview(launchScreen.view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isInitialPresentation {
            subscribeForNotifications()
            
            if let _ = KeychainStorage().getUser() {
                NotificationCenter.default.post(name: NSNotification.Name.SessionStatusChanged, object: SessionStatus.signedIn)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name.SessionStatusChanged, object: SessionStatus.notSignedIn)
            }
            
            isInitialPresentation = false
        }
    }
    
    func sessionChanged(notification: Notification) {
        guard let status = notification.object as? SessionStatus else { return }
        
        dismiss(animated: true)
        present(context: status)
    }
    
    func subscribeForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(sessionChanged), name: NSNotification.Name.SessionStatusChanged, object: nil)
    }
    
    func unsubscribeFromNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(sessionChanged), name: NSNotification.Name.SessionStatusChanged, object: nil)
    }
    
    func present(context: SessionStatus) {
        switch context {
        case .signedIn:
            presentTaskList()
            break
        case .notSignedIn:
            presentLanding()
            break
        }
    }
    
    func presentLanding() {
        let landing = Wireframe.Main().landing()
        let navigationController = TransparentNavigationController(rootViewController: landing)
        
        self.present(navigationController, animated: true)
    }
    
    func presentTaskList() {
        let storage = try! ListStorage()
        let service = ListService()
        
        service
            .fetchLists()
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success(let lists):
                    try! storage.add(lists, update: true)
                    
                    let taskList = Wireframe.Main().taskList()
                    let navigationController = MainNavigationController(rootViewController: taskList)
                    
                    taskList.list = lists.first
                    
                    self?.present(navigationController, animated: true)
                case .failure(let error):
                    self?.showError(error)
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    deinit {
        unsubscribeFromNotifications()
    }
}
