//
//  SwitchConversationCollectionView.swift
//  Convos
//
//  Created by Rahul Madduluri on 3/10/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

private let conversationReuseIdentifier = "SwitchConversationCollectionCell"

class SwitchConversationCollectionView: UIView, ConversationUIComponent, UICollectionViewDelegate, UICollectionViewDataSource {
    var conversationVC: ConversationComponentDelegate? = nil
    
    var switchCollectionView: UICollectionView?
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if (switchCollectionView == nil) {
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: Constants.cellWidth, height: self.bounds.size.height)
            layout.minimumInteritemSpacing = Constants.betweenCellSpace
            switchCollectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
            configureCollectionView()
            self.addSubview(switchCollectionView!)
        }
        switchCollectionView?.reloadData()
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let convoIndex = indexPath.row
        
        if let cvd = conversationVC?.getConversationViewData()[convoIndex] {
            conversationVC?.switchConvoSelected(uuid: cvd.uuid)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return conversationVC?.getConversationViewData().count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: SwitchConversationCollectionViewCell
        let convoIndex = indexPath.row
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: conversationReuseIdentifier, for: indexPath) as! SwitchConversationCollectionViewCell
        cell.conversationVC = self.conversationVC
        if let cvd = conversationVC?.getConversationViewData() {
            cell.customTextLabel.text = cvd[convoIndex].text
            cell.photoImageView.image = nil
            if let uri = cvd[convoIndex].photoURI {
                cell.photoImageView.af_setImage(withURL: REST.imageURL(imageURI: uri))
            }
        }
        cell.setNeedsLayout()
        return cell
    }
    
    // MARK: Private
    
    private func configureCollectionView() {
        switchCollectionView?.backgroundColor = UIColor.white
        switchCollectionView?.register(SwitchConversationCollectionView.self, forCellWithReuseIdentifier: conversationReuseIdentifier)
        switchCollectionView?.delegate = self
        switchCollectionView?.dataSource = self
    }
    
}

private struct Constants {
    static let cellWidth: CGFloat = 60.0
    static let betweenCellSpace: CGFloat = 2.0
}
