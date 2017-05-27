//
//  DashboardInputView.swift
//  Just
//
//  Created by Krzysztof Kapitan on 09.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

import RxSwift

final class DashboardInputViewModel {
    let list = Variable<List?>(nil)
    let text = Variable<String?>(nil)
    let date = Variable<Date?>(nil)
}

final class DashboardInputView: UIView, Reusable, NibLoadable {
   
    @IBOutlet weak var clockButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    
    @IBOutlet weak var inputTextField: UITextField!
    
    @IBOutlet weak var listLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    fileprivate let disposeBag = DisposeBag()
    
    let viewModel = DashboardInputViewModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyState(.inactive, animated: false)
        
        // Set padding for text field
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: inputTextField.frame.height))
        
        inputTextField.leftView = paddingView
        inputTextField.leftViewMode = .always
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 1.0
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        
        setupBindings()
    }
    
    func setupBindings() {
        let formatter: DateFormatter = .short
        
        inputTextField.rx
            .text
            .asObservable()
            .bindTo(viewModel.text)
            .addDisposableTo(disposeBag)
        
        viewModel.text
            .asObservable()
            .bindTo(inputTextField.rx.text)
            .addDisposableTo(disposeBag)
        
        viewModel
            .date
            .asObservable()
            .map {
                $0.flatMap(formatter.string(from:)) ?? ""
            }
            .bindTo(dateLabel.rx.text)
            .addDisposableTo(disposeBag)
        
        viewModel
            .list
            .asObservable()
            .map { $0?.name ?? "" }
            .bindTo(listLabel.rx.text)
            .addDisposableTo(disposeBag)
    }
    
    func activate() {
        applyState(.active, animated: true)
    }
    
    func deactivate() {
        applyState(.inactive, animated: true)
    }
}

extension DashboardInputView {
    struct State {
        let text: String
        let offset: CGFloat
        let clearsInput: Bool
    }
    
    func applyState(_ state: State, animated: Bool) {
        leadingConstraint.constant = state.offset
        viewModel.text.value = state.text
        
        if state.clearsInput {
            viewModel.date.value = nil
            viewModel.list.value = nil
        }
        
        guard animated else { return }
        
        UIView.animate(withDuration: 0.5) {
            self.layoutIfNeeded()
        }
    }
}

extension DashboardInputView.State {
    static let active: DashboardInputView.State = {
        return .init(text: "", offset: 10, clearsInput: false)
    }()
    
    static let inactive: DashboardInputView.State = {
        return .init(text: "Type things to be done...", offset: -100, clearsInput: true)
    }()
}
