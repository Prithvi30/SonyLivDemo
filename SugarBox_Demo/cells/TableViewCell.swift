//
//  TableViewCell.swift
//  SugarBox_Demo
//
//  Created by Prithviraj Patil on 28/09/23.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate: CollectionViewCellDelegate?
    var sectionData: [Section] = []
    
    func configure(with sections: [Section]) {
        sectionData = sections
        collectionView.reloadData()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isUserInteractionEnabled = true
        collectionView.allowsSelection = true
        
        // UICollectionViewFlowLayout with horizontal scroll direction
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        // Calculate the cell width based on your requirements
        let cellsPerRow: CGFloat = 2.3
        let spacingBetweenCells: CGFloat = 10.0 // Adjust the spacing as needed
        
        // Calculate the total horizontal spacing
        let totalSpacing = (cellsPerRow - 1) * spacingBetweenCells
        
        // Calculate the cell width so that it fits the collection view width
        let collectionViewWidth = collectionView.frame.width
        let cellWidth = (collectionViewWidth - totalSpacing) / cellsPerRow 
        
        // Set the cell size with a height that matches the collectionView's height
        let collectionViewHeight = collectionView.frame.height
        flowLayout.itemSize = CGSize(width: cellWidth , height: collectionViewHeight )
        
        // Configure other flow layout properties
        flowLayout.minimumInteritemSpacing = spacingBetweenCells // Horizontal spacing
        // flowLayout.minimumLineSpacing = spacingBetweenCells // Vertical spacing
        
        // Assign the flow layout to the collection view
        collectionView.collectionViewLayout = flowLayout
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Register the CollectionViewCell
        collectionView.register(UINib(nibName: "ThumbnailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ThumbnailCollectionViewCell")
        
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        
        
    }
    
}

extension TableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section < sectionData.count {
            return sectionData[section].contents.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbnailCollectionViewCell", for: indexPath) as! ThumbnailCollectionViewCell
        
        if indexPath.section < sectionData.count && indexPath.item < sectionData[indexPath.section].contents.count {
            let content = sectionData[indexPath.section].contents[indexPath.item]
            print(sectionData[indexPath.section].title)
            print(content.title)
            // Ensure that the assets array within content is valid
            if indexPath.row < content.assets.count {
                let assetData = content.assets[indexPath.row]
                cell.configure(with: assetData)
            } else {
                // Handle the case where the row index is out of bounds for assets
                print("IndexPath.row is out of bounds for assets")
            }
            
        } else {
            // Handle the case where the section or item index is out of bounds
            print("IndexPath.section or IndexPath.item is out of bounds")
        }
        
        cell.delegate = delegate
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section < sectionData.count {
            let asset = sectionData[indexPath.section].contents[indexPath.row]
            print("TableViewCell didSelectItem called")
            delegate?.didSelectItem(at: indexPath, content: asset)
        } else {
            // Handle the case where the section index is out of bounds
        }
    }
}
