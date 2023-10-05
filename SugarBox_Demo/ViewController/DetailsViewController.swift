//
//  DetailsViewController.swift
//  SugarBox_Demo
//
//  Created by Prithviraj Patil on 28/09/23.
//

import UIKit
import AVKit
import AVFoundation

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionLabel: UILabel!
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    @IBOutlet weak var imageThree: UIImageView!
    
    var asset: Content?
    var videoPlayer: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageView.isUserInteractionEnabled = true
        // Hide the navigation bar
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar when navigating away from this view controller
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    @IBAction func closeButton(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLabel()
        self.titleLabel.text = asset?.title
        self.rating.text = "8.7"
        self.durationLabel.text = setupTime()
        self.descriptionLabel.text = asset?.description
        if let contentType = asset?.contentType {
            let contentTypeString = String(describing: contentType)
            self.typeLabel.text = contentTypeString
        }
        
        if let assetType = asset?.assets {
            configure(with: assetType.first!)
        }
        
        makeImageViewsRounded([imageOne, imageTwo, imageThree])
        
    }
    
    func setupTime() -> String {
        let durationInSeconds = asset?.metaData.duration ?? 0
        let formattedDuration = secondsToHoursMinutesSeconds(seconds: durationInSeconds)
        return formattedDuration
    }
    
    func setUpLabel() {
        styleLabelAsButton(rating)
        styleLabelAsButton(durationLabel)
        styleLabelAsButton(typeLabel)
        styleLabelAsButton(actionLabel)
    }
    
    
    func styleLabelAsButton(_ label: UILabel) {
          label.backgroundColor = UIColor.gray
          label.textColor = UIColor.white
          label.layer.cornerRadius = 5
          label.layer.masksToBounds = true
          label.textAlignment = .center
          label.isUserInteractionEnabled = true
      }
    
    func makeImageViewsRounded(_ imageViews: [UIImageView]) {
        for imageView in imageViews {
            imageView.layer.cornerRadius = imageView.frame.size.width / 2
            imageView.clipsToBounds = true
        }
    }
    
    func secondsToHoursMinutesSeconds(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = (seconds % 3600) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    fileprivate func playerControls() {
        // Create play/pause button
        let playPauseButton = UIButton(type: .system)
        playPauseButton.setImage(UIImage(named: "play"), for: .normal)
        playPauseButton.setImage(UIImage(named: "pause"), for: .selected)
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        playPauseButton.frame = CGRect(x: 160, y: imageView.bounds.height/2, width: 60, height: 30)
        playPauseButton.setTitleColor(.white, for: .normal)
        playPauseButton.setTitleColor(.white, for: .selected)
        playPauseButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        imageView.addSubview(playPauseButton)

        // Create seek forward button
        let seekForwardButton = UIButton(type: .system)
        seekForwardButton.setImage(UIImage(named: "forward"), for: .normal)
        seekForwardButton.addTarget(self, action: #selector(seekForwardButtonTapped), for: .touchUpInside)
        seekForwardButton.frame = CGRect(x: 280, y: imageView.bounds.height/2, width: 60, height: 30)
        seekForwardButton.setTitleColor(.white, for: .normal)
        seekForwardButton.setTitleColor(.white, for: .selected)
        seekForwardButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        imageView.addSubview(seekForwardButton)

        // Create seek backward button
        let seekBackwardButton = UIButton(type: .system)
        seekBackwardButton.setImage(UIImage(named: "rewind"), for: .normal)
        seekBackwardButton.addTarget(self, action: #selector(seekBackwardButtonTapped), for: .touchUpInside)
        seekBackwardButton.frame = CGRect(x: 30, y: imageView.bounds.height/2, width: 60, height: 30)
        seekBackwardButton.setTitleColor(.white, for: .normal)
        seekBackwardButton.setTitleColor(.white, for: .selected)
        seekBackwardButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        imageView.addSubview(seekBackwardButton)
    }

    
    func configure(with asset: Asset) {
        // Check the asset type
        switch asset.assetType {
        case .video:
            // Handle video assets
            if asset.type == .hls, let videoURL = URL(string: "https://cdn.flowplayer.com/a30bd6bc-f98b-47bc-abf5-97633d4faea0/hls/de3f6ca7-2db3-4689-8160-0f574a5996ad/playlist.m3u8") {
                // This is an HLS video asset
                
                videoPlayer = AVPlayer(url: videoURL)
                
                playerLayer = AVPlayerLayer(player: videoPlayer)
                playerLayer?.frame = imageView.bounds
                imageView.layer.addSublayer(playerLayer!)
                
                imageView.layer.addSublayer(playerLayer!)
                playerControls()
                
                // Play the video
                videoPlayer?.play()
            } else {
                // Handle other video types (e.g., MP4, etc.) if needed
            }
        case .image:
            // Handle image assets
            if let imageURL = URL(string: asset.sourceURL) {
                let task = URLSession.shared.dataTask(with: imageURL) { [weak self] (data, response, error) in
                    
                    if let error = error {
                        print("Error loading image: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self?.imageView.image = UIImage(named: "placeholder")
                        }
                        return
                    }
                    
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.imageView.image = image
                        }
                    } else {
                        DispatchQueue.main.async {
                            self?.imageView.image = UIImage(named: "placeholder")
                        }
                    }
                }
                task.resume()
            } else {
                imageView.image = UIImage(named: "placeholder")
            }
        }
    }
    
    @objc func playPauseButtonTapped() {
        if videoPlayer?.rate == 0 {
            videoPlayer?.play()
        } else {
            videoPlayer?.pause()
        }
    }
    
    @objc func seekForwardButtonTapped() {
        guard let player = videoPlayer else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = currentTime + 10.0
        let timeToSeek = CMTime(seconds: newTime, preferredTimescale: 1)
        player.seek(to: timeToSeek)
    }
    
    @objc func seekBackwardButtonTapped() {
        guard let player = videoPlayer else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = currentTime - 10.0
        let timeToSeek = CMTime(seconds: newTime, preferredTimescale: 1)
        player.seek(to: timeToSeek)
    }
}
