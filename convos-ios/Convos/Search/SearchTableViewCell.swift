//
//  SearchTableViewCell.swift
//  Convos
//
//  Created by Rahul Madduluri on 1/10/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

private let conversationReuseIdentifier = "SearchConversationCell"
private let newConversationCellReuseIdentifier = "SearchNewConversationCell"


class SearchTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, SearchUIComponent {
    
    var section = 0
    var row = 0
    var uuid: String?
    var delegate: SearchTableComponentDelegate?
    var searchCollection: UICollectionView?
    
    // MARK: Initalizers
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor.blue
        self.selectionStyle = .none
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        searchCollection = UICollectionView(frame: self.bounds)
        configureCollectionView()
        contentView.addSubview(searchCollection!)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let group = delegate?.getSearchViewData().keys[indexPath.section],
            let cs = delegate?.getSearchViewData()[group],
            let uuid = cs[collectionView.tag].uuid {
            delegate?.convoSelected(uuid: uuid)
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let group = delegate?.getSearchViewData().keys[section] {
            return delegate?.getSearchViewData()[group]?.count ?? 0
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: SearchCollectionViewCell
        if indexPath.row == 0 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: newConversationCellReuseIdentifier, for: indexPath) as? SearchCollectionViewCell ?? SearchCollectionViewCell()
            cell.delegate = self.delegate
            cell.type = SearchViewType.defaultConversation
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: newConversationCellReuseIdentifier, for: indexPath) as? SearchCollectionViewCell ?? SearchCollectionViewCell()
            cell.delegate = self.delegate
            cell.type = SearchViewType.conversation
        }
        return cell
    }
    
    // MARK: Private
    
    func configureCollectionView() {
        searchCollection?.delegate = self.delegate as? UICollectionViewDelegate
        searchCollection?.dataSource = self.delegate as? UICollectionViewDataSource
        searchCollection?.tag = row
    }
}

private struct Constants {
}
