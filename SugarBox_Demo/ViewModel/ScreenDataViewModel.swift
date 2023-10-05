//
//  ScreenDataViewModel.swift
//  SugarBox_Demo
//
//  Created by Prithviraj Patil on 26/09/23.
//

import Foundation

struct Section {
    let title: String
    let contents: [Content]
}

class ScreenDataViewModel {
    private let networkManager: NetworkManagerProtocol
    var sections: [Section] = []

    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func fetchAPIData(page: Int, perPage: Int, completion: @escaping (Result<ScreenData, Error>) -> Void) {
        let endpoint = FeedEndpoint.getFeed(page: page, perPage: perPage)
        networkManager.fetchData(from: endpoint) { [weak self] (result: Result<ScreenData, Error>) in
            guard self != nil else {
                return
            }
            completion(result)
        }
    }
    
    func getData(completion: @escaping (ScreenData?) -> Void) {
        let pageCount = 1
        let perPage = 20
        self.fetchAPIData(page: pageCount, perPage: perPage) { [weak self] result in
            guard let self = self else {
                completion(nil)
                return
            }
            switch result {
            case .success(let screenData):
                self.sections = self.organizeAssetsIntoSections(from: screenData.data)
                completion(screenData)
            case .failure(let error):
                print("Error fetching data: \(error)")
                completion(nil)
            }
        }
    }

    private func organizeAssetsIntoSections(from pageData: [PageData]) -> [Section] {
        return pageData.map { page in
            let sectionTitle = page.title
            let cellData = page.contents
            return Section(title: sectionTitle, contents: cellData)
        }
    }
}
