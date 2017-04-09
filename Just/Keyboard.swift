//
//  Keyboard.swift
//  Just
//
//  Created by Krzysztof Kapitan on 09.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

final class Keyboard {
    
    typealias KeyboardAction = (CGRect) -> Void
    
    fileprivate var onShowBlock: KeyboardAction?
    fileprivate var onHideBlock: KeyboardAction?
    
    fileprivate var isKeyboardShown: Bool = false
    
    init() {
        register()
    }
    
    deinit {
        unregister()
    }
    
    @discardableResult
    func onShow(_ onShowBlock: @escaping KeyboardAction) -> Keyboard {
        self.onShowBlock = onShowBlock
        return self
    }
    
    @discardableResult
    func onHide(_ onHideBlock: @escaping KeyboardAction) -> Keyboard {
        self.onHideBlock = onHideBlock
        return self
    }
    
    @discardableResult
    func register() -> Keyboard {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        return self
    }
    
    @discardableResult
    func unregister() -> Keyboard {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        return self
    }
    
    @objc fileprivate func keyboardWillShow(notification: Notification) {
        guard !isKeyboardShown else { return }
        
        guard let keyboardFrameValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardFrame = keyboardFrameValue.cgRectValue
        
        onShowBlock?(keyboardFrame)
        isKeyboardShown = true
    }
    
    @objc fileprivate func keyboardWillHide(notification: Notification) {
        guard isKeyboardShown else { return }
        
        guard let keyboardFrameValue = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return }
        
        let keyboardFrame = keyboardFrameValue.cgRectValue
        
        onHideBlock?(keyboardFrame)
        isKeyboardShown = false
    }
}
