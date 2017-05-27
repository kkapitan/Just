//
//  SettingsViewModel.swift
//  Just
//
//  Created by Krzysztof Kapitan on 27.05.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import RxDataSources

final class SettingsViewModel: NSObject, UITableViewDelegate {
    
    enum LogoutResult {
        case success
        case failure(Error?)
    }
    
    typealias Section = SectionModel<String, Setting>
    
    let settings: [[Setting]] = {
        return [
            [.link(.aboutUs), .link(.support), .link(.terms)],
            [.switch(.storeInCloud), .switch(.notificationsOn)]
        ]
    }()
    
    let dataSource = RxTableViewSectionedReloadDataSource<Section>()
    
    override init() {
        super.init()
        
        dataSource.configureCell = { _, tableView, _, item in
            switch item {
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
    }
    
    func sections() -> Observable<[Section]> {
        return Observable.from(settings.map { Section(model: "", items: $0) })
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleView = SectionTitleView.view
        titleView.title = title(forSection: section)
        
        return titleView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    func logout() -> Observable<LogoutResult> {
        let service = UserService()
        
        return service.logout().flatMap { response -> Observable<LogoutResult> in
            switch response {
            case .failure(let error):
                return Observable.just(.failure(error))
            case .success:
                
                try? ListStorage().removeAll()
                try? TasksStorage().removeAll()
                
                KeychainStorage().deleteUser()
                NotificationCenter.default.post(name: NSNotification.Name.SessionStatusChanged, object: SessionStatus.notSignedIn)
                
                return Observable.just(.success)
            }
        }
    }
}
