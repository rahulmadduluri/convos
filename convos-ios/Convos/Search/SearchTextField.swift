//
//  SearchTextField.swift
//  SearchTextField
//
//  Created by Alejandro Pasccon on 4/20/16.
//  Copyright © 2016 Alejandro Pasccon. All rights reserved.
//
//  Modified by Rahul Madduluri on 7/20/17.


import UIKit

class SearchTextField: UITextField {
    
    var searchTextFieldDelegate: SearchTextFieldDelegate?
    
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
        
    // private vars
    fileprivate var timer: Timer? = nil
    fileprivate var placeholderLabel: UILabel?
    fileprivate let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        self.addTarget(self, action: #selector(SearchTextField.textFieldDidChange), for: .editingChanged)
        self.addTarget(self, action: #selector(SearchTextField.textFieldDidBeginEditing), for: .editingDidBegin)
        self.addTarget(self, action: #selector(SearchTextField.textFieldDidEndEditing), for: .editingDidEnd)
        self.addTarget(self, action: #selector(SearchTextField.textFieldDidEndEditingOnExit), for: .editingDidEndOnExit)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        buildPlaceholderLabel()
        
        // Create the loading indicator
        indicator.hidesWhenStopped = true
        self.rightView = indicator
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rightFrame = super.rightViewRect(forBounds: bounds)
        rightFrame.origin.x -= 5
        return rightFrame
    }
    
    fileprivate func buildPlaceholderLabel() {
        var newRect = self.placeholderRect(forBounds: self.bounds)
        var caretRect = self.caretRect(for: self.beginningOfDocument)
        let textRect = self.textRect(forBounds: self.bounds)
        
        if let range = textRange(from: beginningOfDocument, to: endOfDocument) {
            caretRect = self.firstRect(for: range)
        }
        
        newRect.origin.x = caretRect.origin.x + caretRect.size.width + textRect.origin.x
        newRect.size.width = newRect.size.width - newRect.origin.x
        
        if let placeholderLabel = placeholderLabel {
            placeholderLabel.font = self.font
            placeholderLabel.frame = newRect
        } else {
            placeholderLabel = UILabel(frame: newRect)
            placeholderLabel?.text = "Enter the Convos"
            placeholderLabel?.font = self.font
            placeholderLabel?.backgroundColor = UIColor.clear
            placeholderLabel?.lineBreakMode = .byClipping
            
            if let placeholderColor = self.attributedPlaceholder?.attribute(NSForegroundColorAttributeName, at: 0, effectiveRange: nil) as? UIColor {
                placeholderLabel?.textColor = placeholderColor
            } else {
                placeholderLabel?.textColor = UIColor ( red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0 )
            }
            
            self.addSubview(placeholderLabel!)
        }
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
        timer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(SearchTextField.typingDidStop), userInfo: self, repeats: false)
        
        if text!.isEmpty {
            placeholderLabel?.text = "Enter the Convos"
        } else {
            placeholderLabel?.text = ""
        }
        
        let updatedText = text ?? ""
        searchTextFieldDelegate?.searchTextUpdated(searchText: updatedText)
    }
    
    func textFieldDidBeginEditing() {
        if let currentText = text {
            searchTextFieldDelegate?.searchTextUpdated(searchText: currentText)
        }
        placeholderLabel?.text = nil
        placeholderLabel?.attributedText = nil
    }
    
    func textFieldDidEndEditing() {
        if let currentText = text {
            searchTextFieldDelegate?.searchTextUpdated(searchText: currentText)
        }
        placeholderLabel?.attributedText = nil
        placeholderLabel?.attributedText = nil
    }
    
    func textFieldDidEndEditingOnExit() {
        self.placeholderLabel?.text = nil

        if let svd = searchTextFieldDelegate?.getSearchViewData() {
            self.text = svd.keys[0].text
        }
    }
    
}
