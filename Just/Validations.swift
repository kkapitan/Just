//
//  Validations.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import Foundation

struct Validations {
    
    static func isValid(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with: email)
    }
    
    static func isValid(username: String) -> Bool {
        return !username.isEmpty && username.characters.count < 15
    }
    
    static func isValid(confirmation: String, of password: String) -> Bool {
        return password == confirmation
    }
    
    static func isValid(password: String) -> Bool {
        return password.characters.count > 6
    }

}
