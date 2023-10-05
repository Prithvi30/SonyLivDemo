//
//  ThumbnailCollectionViewCell.swift
//  SugarBox_Demo
//
//  Created by Prithviraj Patil on 28/09/23.
//

import UIKit
import AVKit
import AVFoundation

protocol CollectionViewCellDelegate: AnyObject {
    func didSelectItem(at indexPath: IndexPath, content: Content)
}

class ThumbnailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var delegate: CollectionViewCellDelegate?
    var indexPath: IndexPath?
    var assetItem : Asset?
    var content: Content?
    var imageCache = NSCache<NSString, UIImage>()
    private static var imageCache = NSCache<NSString, UIImage>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        thumbnailImageView.layer.cornerRadius = 15
        thumbnailImageView.clipsToBounds = true
    }
    
    func configure(with indexPath: IndexPath, asset: Asset, content: Content) {
        self.indexPath = indexPath
        self.assetItem = asset
        self.content = content
        
        // tap gesture recognizer for cell
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func cellTapped(_ sender: UITapGestureRecognizer) {
        if let indexPath = indexPath, let content = content {
            delegate?.didSelectItem(at: indexPath, content: content)
        }
    }
    
    // load and cache an image
    private func loadImage(withURL imageURL: URL) {
        // Check if the image is already cached
        if let cachedImage = ThumbnailCollectionViewCell.imageCache.object(forKey: imageURL.absoluteString as NSString) {
            // If cached, set the image from the cache
            self.thumbnailImageView.image = cachedImage
            return
        }
        
        // If not cached, download the image
        let task = URLSession.shared.dataTask(with: imageURL) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.thumbnailImageView.image = UIImage(named: "placeholder")
                }
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                // Cache the downloaded image
                ThumbnailCollectionViewCell.imageCache.setObject(image, forKey: imageURL.absoluteString as NSString)
                
                DispatchQueue.main.async {
                    self.thumbnailImageView.image = image
                }
            } else {
                DispatchQueue.main.async {
                    self.thumbnailImageView.image = UIImage(named: "placeholder")
                }
            }
        }
        task.resume()
    }
    
    func configure(with asset: Asset) {
        // Check the asset type
        switch asset.assetType {
        case .video:
            // Handle video assets
            if asset.type == .hls, let videoURL = URL(string: asset.sourceURL) {
                let videoPlayer = AVPlayer(url: videoURL)
                
                // AVPlayerLayer to display the video
                let playerLayer = AVPlayerLayer(player: videoPlayer)
                playerLayer.frame = thumbnailImageView.bounds
                
                // Add the player layer to the image layer
                thumbnailImageView.layer.addSublayer(playerLayer)
                
                // Play the video
                videoPlayer.play()
            } else {
                // Handle other video types like MP4
                
            }
        case .image:
            // Handle image assets
            if let imageURL = URL(string: asset.sourceURL) {
                loadImage(withURL: imageURL) // Load and cache the image
            } else {
                thumbnailImageView.image = UIImage(named: "placeholder")
            }
        }
    }
}
