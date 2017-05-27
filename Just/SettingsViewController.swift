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
