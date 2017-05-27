//
//  DatePickerViewController.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

final class DatePickerViewController: UIViewController {
    
    @IBOutlet weak var tickButton: UIButton!
    @IBOutlet weak var crossButton: UIButton!
    
    @IBOutlet weak var picker: UIDatePicker!

    let selected = Variable<Date?>(nil)
    
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        picker.setValue(UIColor.white, forKey: "textColor")
        
        setupBindings()
    }
    
    func setupBindings() {
        
        selected
            .asObservable()
            .filterNil()
            .bindTo(picker.rx.date)
            .addDisposableTo(disposeBag)
        
        picker.rx
            .date
            .asObservable()
            .bindTo(selected)
            .addDisposableTo(disposeBag)
        
        crossButton.rx
            .tap
            .map { nil }
            .bindTo(selected)
            .addDisposableTo(disposeBag)
        
        Observable.of(
            crossButton.rx.tap,
            tickButton.rx.tap
        ).merge()
            .subscribe(onNext: { [unowned self] _ in
                self.dismiss(animated: true)
            })
            .addDisposableTo(disposeBag)
    }
}
