//
//  RootViewController.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

enum EntranceContext {
    case signedIn, notSignedIn
}

final class RootViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        present(context: .notSignedIn)
    }
    
    func present(context: EntranceContext) {
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
        
        self.present(navigationController, animated: false)
    }
    
    func presentTaskList() {
        let taskList = Wireframe.Main().taskList()
        let navigationController = MainNavigationController(rootViewController: taskList)
        
        present(navigationController, animated: false)
    }
}
