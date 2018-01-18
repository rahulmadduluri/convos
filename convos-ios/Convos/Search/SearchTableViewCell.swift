//
//  SearchTableViewCell.swift
//  Convos
//
//  Created by Rahul Madduluri on 1/10/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

private let conversationReuseIdentifier = "SearchConversationCell"

class SearchTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, SearchUIComponent {
    
    var section = 0
    var row = 0
    var uuid: String?
    var delegate: SearchTableComponentDelegate?
    
    // MARK: Initalizers
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor.blue
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: Constants.cellWidth, height: contentView.bounds.size.height)
        layout.minimumInteritemSpacing = Constants.betweenCellSpace
        let collectionView = UICollectionView(frame: contentView.bounds, collectionViewLayout: layout)
        configureCollectionView(collectionView: collectionView)
        contentView.addSubview(collectionView)
        
        collectionView.backgroundColor = UIColor.purple
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let groupIndex = indexPath.section
        let convoIndex = indexPath.row - 1
        
        if indexPath.row == 0 {
            
        } else {
            if let defaultConvo = delegate?.getSearchViewData().keys[groupIndex],
                let cs = delegate?.getSearchViewData()[defaultConvo],
                let uuid = cs[convoIndex].uuid {
                delegate?.convoSelected(uuid: uuid)
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
            
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let defaultConvo = delegate?.getSearchViewData().keys[collectionView.tag] {
            return delegate?.getSearchViewData()[defaultConvo]?.count ?? 0
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: SearchCollectionViewCell
        let groupIndex = indexPath.section
        let convoIndex = indexPath.row - 1
        if indexPath.row == 0 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: conversationReuseIdentifier, for: indexPath) as! SearchCollectionViewCell
            cell.photoImageView.image = UIImage(named: "new_conversation")
            cell.delegate = self.delegate
            cell.type = SearchViewType.newConversation
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: conversationReuseIdentifier, for: indexPath) as! SearchCollectionViewCell
            cell.delegate = self.delegate
            cell.type = SearchViewType.conversation
            if let svd = delegate?.getSearchViewData() {
                let defaultConvo = svd.keys[groupIndex]
                //cell.photoImageView.image = svd[defaultConvo]?[convoIndex].photo
                cell.photoImageView.image = UIImage(named: "rahul_test_pic")
                cell.customTextLabel.text = svd[defaultConvo]?[convoIndex].text
            }
        }
        return cell
    }
    
    // MARK: Private
    
    func configureCollectionView(collectionView: UICollectionView) {
        collectionView.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: conversationReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.tag = section
    }
}

private struct Constants {
    static let cellWidth: CGFloat = 80.0
    static let betweenCellSpace: CGFloat = 10.0
}
