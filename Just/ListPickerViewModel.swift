//
//  ListPickerViewModel.swift
//  Just
//
//  Created by Krzysztof Kapitan on 27.05.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import RxDataSources

final class SelectableTableViewSectionedReloadDataSource<S: SectionModelType>
: TableViewSectionedDataSource<S>, RxTableViewDataSourceType {
    
    func tableView(_ tableView: UITableView, observedEvent: Event<[S]>) {
        UIBindingObserver(UIElement: self) { dataSource, element in
            dataSource.setSections(element)
            tableView.reloadDataPreservingSelection()
            }.on(observedEvent)
    }
}

final class ListPickerViewModel: NSObject, UITableViewDelegate {
    
    typealias Section = SectionModel<String, List>
    
    enum Action {
        case add
        case fetch
    }
    
    enum ActionResult {
        case success(Action)
        case failure(Action, Error?)
    }
    
    fileprivate let service: ListService = {
        return .init()
    }()
    
    fileprivate let storage: ListStorage = {
        return try! .init()
    }()
    
    fileprivate let disposeBag = DisposeBag()
    
    let name = Variable<String?>(nil)
    let selected = Variable<List?>(nil)
    
    let allowAdding = Variable<Bool>(false)
    let selectedIndexPath = Variable<IndexPath?>(nil)
    
    let actionResults = PublishSubject<ActionResult>()
    let dataSource = SelectableTableViewSectionedReloadDataSource<Section>()
    
    init(list: List?, allowAdding: Bool) {
        self.selected.value = list
        self.allowAdding.value = allowAdding
        
        super.init()
        
        fetchLists()
        prepareDataSource()
        prepareSelectedIndexPath()
    }
    
    func lists() -> Observable<[List]> {
        return storage.lists().shareReplay(1)
    }
    
    func sections() -> Observable<[Section]> {
        return lists().map {
            [Section(model: "", items: $0)]
        }
    }
    
    func prepareSelectedIndexPath() {
        
        Observable.combineLatest(
            lists(),
            selected.asObservable().filterNil()
        ) { (lists, selected) -> IndexPath? in
            return lists
                .index(where: { $0.id == selected.id })
                .flatMap { IndexPath(row: $0, section: 0) }
            }
            .bindTo(selectedIndexPath)
            .addDisposableTo(disposeBag)
    }
    
    func prepareDataSource() {
        dataSource.configureCell = { _, tableView, _, item in
            
            let cell: ListEntryCell = tableView.dequeue()
            cell.title = item.name
            
            return cell
        }
    }
    
    func fetchLists() {
        
        service
            .fetchLists()
            .map { [unowned self] result in
                switch result {
                case .failure(let error):
                    return .failure(.fetch, error)
                case .success(let lists):
                    try! self.storage.add(lists, update: true)
                    
                    return .success(.fetch)
                }
            }
            .bindTo(actionResults)
            .addDisposableTo(disposeBag)
    }
    
    func addList() {
        guard let name = name.value, !name.isEmpty else { return }
        
        service.createList(with: ListForm(title: name))
            .map { [unowned self] result in
                switch result {
                case .success(let list):
                    try! self.storage.add(list, update: true)
                    return .success(.add)
                case .failure(let error):
                    return .failure(.add, error)
                }
            }
            .bindTo(actionResults)
            .addDisposableTo(disposeBag)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}
