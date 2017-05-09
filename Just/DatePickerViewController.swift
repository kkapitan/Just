//
//  DatePickerViewController.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

final class DatePickerViewController: UIViewController {
    
    @IBOutlet weak var picker: UIDatePicker!
    
    typealias PickAction = (Date) -> ()
    typealias ClearAction = () -> ()
    
    var onPick: PickAction?
    var onClear: ClearAction?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.setValue(UIColor.white, forKey: "textColor")
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }
    
    func dateChanged() {
        onPick?(picker.date)
    }
    
    @IBAction func tickAction(_ sender: UIButton) {
        dismiss(animated: true)
        onPick?(picker.date)
    }
    
    @IBAction func crossAction(_ sender: UIButton) {
        dismiss(animated: true)
        onClear?()
    }
}
