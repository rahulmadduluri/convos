//
//  SmartTextField.swift
//  SmartTextField
//
//  Created by Alejandro Pasccon on 4/20/16.
//  Copyright © 2016 Alejandro Pasccon. All rights reserved.
//
//  Modified by Rahul Madduluri on 7/20/17.


import UIKit

protocol SmartTextFieldDelegate {
    func smartTextUpdated(smartText: String)
}

class SmartTextField: UITextField {
    
    var smartTextFieldDelegate: SmartTextFieldDelegate?
    
    // public vars
    var maxNumberOfResults = 0
    var maxResultsListHeight = 0
    var hasInteracted = false
    
    /// Closure to handle when the user stops typing
    var userStoppedTypingHandler: ((Void) -> Void)?
    
    /// Start showing the default loading indicator, useful for searches that take some time.
    func showLoadingIndicator() {
        self.rightViewMode = .always
        indicator.startAnimating()
    }
    
    /// Force the results list to adapt to RTL languages
    var forceRightToLeft = false
    
    /// Hide the default loading indicator
    func stopLoadingIndicator() {
        self.rightViewMode = .never
        indicator.stopAnimating()
    }
    
    var defaultPlaceholderText: String = ""
        
    // private vars
    fileprivate var timer: Timer? = nil
    fileprivate let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        self.addTarget(self, action: #selector(SmartTextField.textFieldDidChange), for: .editingChanged)
        self.addTarget(self, action: #selector(SmartTextField.textFieldDidBeginEditing), for: .editingDidBegin)
        self.addTarget(self, action: #selector(SmartTextField.textFieldDidEndEditing), for: .editingDidEnd)
        self.addTarget(self, action: #selector(SmartTextField.textFieldDidEndEditingOnExit), for: .editingDidEndOnExit)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        placeholder = defaultPlaceholderText
        
        // Create the loading indicator
        indicator.hidesWhenStopped = true
        self.rightView = indicator
    }
    
    func typingDidStop() {
        if userStoppedTypingHandler != nil {
            self.userStoppedTypingHandler!()
        }
    }
    
    // Handle text field changes
    func textFieldDidChange() {
        hasInteracted = true
        
        // Detect pauses while typing
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(SmartTextField.typingDidStop), userInfo: self, repeats: false)
        
        if text!.isEmpty {
            placeholder = defaultPlaceholderText
        }
        
        let updatedText = text ?? ""
        smartTextFieldDelegate?.smartTextUpdated(smartText: updatedText)
    }
    
    func textFieldDidBeginEditing() {
        if let currentText = text {
            smartTextFieldDelegate?.smartTextUpdated(smartText: currentText)
        }
    }
    
    func textFieldDidEndEditing() {
    }
    
    func textFieldDidEndEditingOnExit() {
    }
    
}
