//
//  Setting.swift
//  Just
//
//  Created by Krzysztof Kapitan on 09.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import Foundation

enum Setting {
    case link(LinkSetting)
    case `switch`(SwitchSetting)
}

struct LinkSetting {
    let url: URL
    let title: String
}

struct SwitchSetting {
    
    let title: String
    let defaultValue: Bool
    
    func `switch`() {
        let value = !current
        defaults.set(value, forKey: key)
    }
    
    var current: Bool {
        let value = defaults.object(forKey: key) as? Bool
        return value ?? defaultValue
    }
    
    private var key: String {
        return "Defaults.Setting.Key.\(title)"
    }
    
    private var defaults: UserDefaults {
        return .standard
    }
}

extension LinkSetting {
    static let aboutUs: LinkSetting = {
        let url = URL(string: "http://www.google.com")!
        return .init(url: url, title: "About us")
    }()
    
    static let support: LinkSetting = {
        let url = URL(string: "http://www.google.com")!
        return .init(url: url, title: "Support")
    }()
    
    static let terms: LinkSetting = {
        let url = URL(string: "http://www.google.com")!
        return .init(url: url, title: "Terms and conditions")
    }()
}

extension SwitchSetting {
    static let storeInCloud: SwitchSetting = {
        return .init(title: "Store data in cloud", defaultValue: false)
    }()
    
    static let notificationsOn: SwitchSetting = {
        return .init(title: "Deadline notifications", defaultValue: true)
    }()
}
