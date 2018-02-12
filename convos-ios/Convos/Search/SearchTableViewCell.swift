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
    var searchCollectionView: UICollectionView?
    var searchVC: SearchComponentDelegate?
    
    
    // MARK: Initalizers
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor.white
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if (searchCollectionView == nil) {
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: Constants.cellWidth, height: contentView.bounds.size.height)
            layout.minimumInteritemSpacing = Constants.betweenCellSpace
            searchCollectionView = UICollectionView(frame: contentView.bounds, collectionViewLayout: layout)
            configureCollectionView()
            contentView.addSubview(searchCollectionView!)
        }
        refreshCollectionView(tag: section)
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let groupIndex = collectionView.tag
        let convoIndex = indexPath.row - 1
        
        if indexPath.row == 0 {
            
        } else {
            if let defaultConvo = searchVC?.getSearchViewData().keys[groupIndex],
                let cs = searchVC?.getSearchViewData()[defaultConvo],
                let uuid = cs[convoIndex].uuid {
                searchVC?.convoSelected(uuid: uuid)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    // MARK: UICollectionViewDataSource
            
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let defaultConvo = searchVC?.getSearchViewData().keys[collectionView.tag],
            let nonDefaultConvos = searchVC?.getSearchViewData()[defaultConvo] {
            return nonDefaultConvos.count + 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: SearchCollectionViewCell
        let groupIndex = collectionView.tag
        let convoIndex = indexPath.row - 1
        if indexPath.row == 0 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: conversationReuseIdentifier, for: indexPath) as! SearchCollectionViewCell
            cell.photoImageView.image = UIImage(named: "new_conversation")
            cell.searchVC = self.searchVC
            cell.customTextLabel.text = nil
            cell.type = SearchViewType.newConversation
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: conversationReuseIdentifier, for: indexPath) as! SearchCollectionViewCell
            cell.searchVC = self.searchVC
            cell.type = SearchViewType.conversation
            if let svd = searchVC?.getSearchViewData() {
                let defaultConvo = svd.keys[groupIndex]
                cell.customTextLabel.text = svd[defaultConvo]?[convoIndex].text
                if let uri = svd[defaultConvo]?[convoIndex].photoURI {
                    cell.photoImageView.af_setImage(withURL: REST.imageURL(imageURI: uri))
                }
            }
        }
        cell.setNeedsLayout()
        return cell
    }
    
    // MARK: Public
    
    func refreshCollectionView(tag: Int) {
        searchCollectionView?.tag = tag
        searchCollectionView?.reloadData()
    }
    
    // MARK: Private
    
    private func configureCollectionView() {
        searchCollectionView?.backgroundColor = UIColor.clear
        searchCollectionView?.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: conversationReuseIdentifier)
        searchCollectionView?.delegate = self
        searchCollectionView?.dataSource = self
    }
    
}

private struct Constants {
    static let cellWidth: CGFloat = 60.0
    static let betweenCellSpace: CGFloat = 2.0
}
