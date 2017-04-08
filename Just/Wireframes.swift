//
//  Wireframes.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import Foundation

struct Wireframe {
    
    struct Main: StoryboardWireframe {
        let storyboardName: String = "Main"
        
        func landing() -> LandingViewController {
            return instantiatior.identifiable()
        }
        
        func login() -> LoginViewController {
            return instantiatior.identifiable()
        }
        
        func register() -> RegistrationViewController {
            return instantiatior.identifiable()
        }
        
        func settings() -> SettingsViewController {
            return instantiatior.identifiable()
        }
        
        func taskList() -> TaskListViewController {
            return instantiatior.identifiable()
        }
        
        func taskDetails() -> TaskDetailsViewController {
            return instantiatior.identifiable()
        }
        
        func listPicker() -> ListPickerViewController {
            return instantiatior.identifiable()
        }
        
        func datePicker() -> DatePickerViewController {
            return instantiatior.identifiable()
        }
    }
}
