//
//  SettingsViewController.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

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

final class SettingsViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let viewModel = SettingsViewModel()
    
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(for: SettingsSwitchCell.self)
        tableView.registerNib(for: SettingsNavigationCell.self)
        
        tableView.estimatedRowHeight = 53.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = viewModel
        
        setupBindings()
    }
    
    func setupBindings() {
        
        viewModel
            .sections()
            .bindTo(tableView.rx.items(dataSource: viewModel.dataSource))
            .addDisposableTo(disposeBag)
        
        tableView.rx
            .modelSelected(Setting.self)
            .asObservable()
            .subscribe(onNext: { setting in
                switch setting {
                case .link(let linkSetting):
                    UIApplication.shared.openURL(linkSetting.url)
                    break
                case .switch:
                    break
                }
            }).addDisposableTo(disposeBag)
        
        signOutButton.rx
            .tap
            .asObservable()
            .flatMap { [unowned self] (Void) -> Observable<SettingsViewModel.LogoutResult> in
                self.showProgress("Signing out...")
                
                return self.viewModel.logout()
            }.subscribe(onNext: { [unowned self] result in
                self.hideHud()
                
                if case .failure(let error) = result {
                    self.showError(error)
                }
            }).addDisposableTo(disposeBag)
        
        cancelButton.rx
            .tap
            .asObservable()
            .subscribe(onNext: { [unowned self] _ in
                self.dismiss(animated: true)
            }).addDisposableTo(disposeBag)
    }
}
