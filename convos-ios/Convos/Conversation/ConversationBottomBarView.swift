//
//  ConversationBottomBarView.swift
//  Convos
//
//  Created by Rahul Madduluri on 9/21/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit

class ConversationBottomBarView: UIView {
    var newMessageTextField: UITextField = UITextField()
    
    // MARK: UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        newMessageTextField.placeholder = Constants.placeholderText
        newMessageTextField.backgroundColor = UIColor.white

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Setup Divider
        let divider: UIView = UIView(frame: CGRect(x: self.bounds.minX, y: self.bounds.minY, width: self.bounds.size.width, height: Constants.dividerHeight))
        divider.dotLine()
        self.addSubview(divider)
        
        // Setup New Message text field
        newMessageTextField.frame = CGRect(x: self.bounds.minX + Constants.newMessageTextFieldLeftBuffer, y: self.bounds.minY + Constants.newMessageTextFieldTopBuffer, width: self.bounds.size.width - Constants.newMessageTextFieldLeftBuffer, height: Constants.newMessageTextFieldHeight)
        self.addSubview(newMessageTextField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension UIView {
    func dotLine() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createBezierPath().cgPath
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.lineDashPattern = [10, 7]
        shapeLayer.lineDashPhase = 3.0
        self.layer.addSublayer(shapeLayer)
    }
    
    private func createBezierPath() -> UIBezierPath {
        let path = UIBezierPath()
        let p0 = CGPoint(x: self.bounds.minX, y: self.bounds.minY)
        path.move(to: p0)
        let p1 = CGPoint(x: self.bounds.maxX, y: self.bounds.maxY)
        path.addLine(to: p1)
        path.stroke()
        let  dashes: [ CGFloat ] = [2, 4, 6, 2]
        path.setLineDash(dashes, count: dashes.count, phase: 3)
        return path
    }
}

private struct Constants {
    static let placeholderText = "New Message"
    static let dividerHeight: CGFloat = 1
    static let newMessageTextFieldLeftBuffer: CGFloat = 50
    static let newMessageTextFieldHeight: CGFloat = 40
    static let newMessageTextFieldTopBuffer: CGFloat = 5
}
