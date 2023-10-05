//
//  ViewController.swift
//  SugarBox_Demo
//
//  Created by Prithviraj Patil on 26/09/23.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tabBar: UITabBar!
    
    var feedViewModel: ScreenDataViewModel!
    var imageNames = ["1","2","3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        handleScrollView()
        
        handlePageControl()
        feedViewModel = ScreenDataViewModel(networkManager: NetworkManager())
        
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        scrollView.isUserInteractionEnabled = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100

        if let tabBar = self.tabBar {
            // Set the selected item to the first tab
            tabBar.selectedItem = tabBar.items?.first
        }

        getData()
    }
    
 
    
    func handleScrollView() {
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        
        // Configure view content size
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(imageNames.count), height: scrollView.frame.size.height)
        
        // Add image views to the scroll view
        for (index, imageName) in imageNames.enumerated() {
            let imageView = UIImageView(image: UIImage(named: imageName))
            imageView.frame = CGRect(x: scrollView.frame.size.width * CGFloat(index), y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            imageView.contentMode = .scaleToFill
            scrollView.addSubview(imageView)
        }
    }
    
    func handlePageControl() {
        
        pageControl.numberOfPages = imageNames.count
        pageControl.currentPage = 0
        pageControl.frame = CGRect(x: scrollView.frame.size.width/2, y: scrollView.frame.size.height - 30, width: scrollView.frame.size.width, height: 30)
        
        view.addSubview(pageControl)
    }
    
    func getData() {
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        let loadingLabel = UILabel()
        loadingLabel.text = "Please wait while loading..."
        loadingLabel.textAlignment = .center
        loadingLabel.textColor = .gray
        loadingLabel.font = UIFont.systemFont(ofSize: 14)
        loadingLabel.sizeToFit()
        loadingLabel.center = CGPoint(x: view.center.x, y: view.center.y + 30)
        view.addSubview(loadingLabel)
        
        // Start animating the activity indicator
        activityIndicator.startAnimating()
        
        
        feedViewModel.getData { [weak self] screenData in
            DispatchQueue.main.async {
                guard let self = self else { return }
                activityIndicator.stopAnimating()
                loadingLabel.removeFromSuperview()
                if let screenData = screenData {
                    self.updateUI(with: screenData)
                } else {
                    // Handle the case where data couldn't be fetched
                }
            }
        }
    }
    
    func updateUI(with screenData: ScreenData) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return feedViewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        
        let section = feedViewModel.sections[indexPath.section]
        cell.titleLabel.text = section.title

        cell.configure(with: [section])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 155
    }
}

extension ViewController: CollectionViewCellDelegate {
    func didSelectItem(at indexPath: IndexPath, content: Content) {
        print("ViewController didSelectItem called")
        
        // Access the selected index item using indexPath.row
        let selectedContent = content
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        
        // Pass the selected content to the next view controller
        vc.asset = selectedContent
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Calculate the current page based on the content offset and scroll view width
        let currentPage = Int((scrollView.contentOffset.x / scrollView.frame.size.width).rounded())
        
        // Update the page control
        pageControl.currentPage = currentPage
    }
}
