//
//  PickerView.swift
//  Just
//
//  Created by Krzysztof Kapitan on 20.05.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit
import RxSwift

protocol PickerItem {
    var title: String { get }
}

final class PickerView<T: PickerItem>: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    typealias SelectionBlock = (T) -> ()
    
    let selected = PublishSubject<T>()
    
    fileprivate let items: [T]
    
    init(items: [T]) {
        self.items = items
        
        super.init(frame: .zero)
        
        delegate = self
        dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selected.onNext(items[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row].title
    }
}
