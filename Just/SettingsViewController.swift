//
//  SettingsViewController.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

final class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let settings: [[Setting]] = {
        return [
            [.link(.aboutUs), .link(.support), .link(.terms)],
            //[.switch(.storeInCloud), .switch(.notificationsOn)]
        ]
    }()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(for: SettingsSwitchCell.self)
        tableView.registerNib(for: SettingsNavigationCell.self)
        
        tableView.estimatedRowHeight = 53.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let setting = settings[indexPath.section][indexPath.row]
        
        switch setting {
        case .link(let linkSetting):
            let cell: SettingsNavigationCell = tableView.dequeue()
            cell.title = linkSetting.title
            
            return cell
        case .switch(let switchSetting):
            let cell: SettingsSwitchCell = tableView.dequeue()
            cell.setting = switchSetting.current
            cell.title = switchSetting.title
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let setting = settings[indexPath.section][indexPath.row]
        
        switch setting {
        case .link(let linkSetting):
            UIApplication.shared.openURL(linkSetting.url)
            break
        case .switch:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let titleView = SectionTitleView.view
        titleView.title = title(forSection: section)
        
        return titleView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
    }
    
    func title(forSection section: Int) -> String {
        switch section {
        case 0:
            return "INFO"
        case 1:
            return "SETUP"
        default:
            fatalError("Wrong section id")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    @IBAction func signOutAction() {
        let service = UserService()
        service.logout(completion: { _ in })
        
        KeychainStorage().deleteUser()
        NotificationCenter.default.post(name: NSNotification.Name.SessionStatusChanged, object: SessionStatus.notSignedIn)
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
}
