//
//  TeamsViewModel.swift
//  FootballApp
//

import Foundation
import Network

final class TeamsViewModel: BaseViewModel<ViewState> {
    private let service: TeamsServiceable
    
    private(set) var responseModel: TeamsResponseModel?
    private(set) var data = [Team]()
    
    var currentPage: Int {
        (responseModel?.pagination?.currentPage ?? 0) + 1
    }
    
    var hasMoreContent: Bool {
        responseModel?.pagination?.hasMore ?? false
    }
    
    init(data: [Team] = [], service: TeamsServiceable = TeamsService()) {
        self.data = data
        self.service = service
    }
    
    @MainActor
    func fetchAllData(page: Int? = nil) async {
        guard state != .empty else { return }
        
        do {
            let result: TeamsResponseModel = try await service.getAllTeams(currentPage: page ?? currentPage)
            
            if currentPage == 1 || data.isEmpty {
                self.changeState(.loading)
            }
            if page == 1 {
                data = result.data
            } else {
                updateData(with: result)
            }
            responseModel = result
            changeState(.finished)
        } catch {
            changeState(.error(error: error.localizedDescription))
        }
    }
    
    func loadMoreContent() async {
        guard responseModel?.pagination?.nextPage != nil else { return }
        await fetchAllData()
    }
    
    func refresh() async {
        await fetchAllData(page: 1)
    }
    
    @MainActor
    func changeStateToEmpty() {
        changeState(.empty)
    }
    
    private func updateData(with result: TeamsResponseModel) {
        data += result.data
    }
}
