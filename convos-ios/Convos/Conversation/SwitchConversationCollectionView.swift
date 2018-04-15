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
    
    fileprivate var switchCollectionView: UICollectionView?
    
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
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: Constants.cellWidth, height: self.bounds.size.height)
        layout.minimumInteritemSpacing = Constants.betweenCellSpace
        switchCollectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        configureCollectionView()
        self.addSubview(switchCollectionView!)
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
                var urlRequest = URLRequest(url: REST.imageURL(imageURI: uri))
                urlRequest.setValue(APIHeaders.authorizationValue(), forHTTPHeaderField: "Authorization")
                cell.photoImageView.af_setImage(withURLRequest: urlRequest)
            }
        }
        cell.setNeedsLayout()
        return cell
    }
    
    // MARK: Public
    
    func resetCollection() {
        switchCollectionView?.reloadData()
    }
    
    func respondToPanGesture(gesture: UIGestureRecognizer) {
        if let panGesture = gesture as? UIPanGestureRecognizer {
            let translation = panGesture.translation(in: self)
            if (translation.y < -25) {
                conversationVC?.hideSwitcher()
            }
        }
    }
    
    // MARK: Private
    
    private func configureCollectionView() {
        switchCollectionView?.backgroundColor = UIColor.white
        switchCollectionView?.register(SwitchConversationCollectionViewCell.self, forCellWithReuseIdentifier: conversationReuseIdentifier)
        switchCollectionView?.delegate = self
        switchCollectionView?.dataSource = self
        let pgr = UIPanGestureRecognizer()
        pgr.addTarget(self, action: #selector(self.respondToPanGesture(gesture:)))
        self.addGestureRecognizer(pgr)
    }
    
}

private struct Constants {
    static let cellWidth: CGFloat = 60.0
    static let betweenCellSpace: CGFloat = 2.0
}
