//
//  SquadViewModel.swift
//  FootballApp
//

import Foundation
import Network

final class SquadViewModel: BaseViewModel<ViewState> {
    private let service: SquadsServiceable
    
    private(set) var responseModel: PlayersResponseModel?
    private(set) var data = [Player]()
    
    private(set) var teamID: Int
    
    var currentPage: Int {
        (responseModel?.pagination?.currentPage ?? 0) + 1
    }
    
    var hasMoreContent: Bool {
        responseModel?.pagination?.hasMore ?? false
    }
    
    init(teamID: Int, service: SquadsServiceable = SquadsService()) {
        self.teamID = teamID
        self.service = service
    }
    
    @MainActor
    func fetchDataByTeamID(page: Int? = nil) async {
        guard state != .empty else { return }
        
        do {
            let result: PlayersResponseModel = try await service.getSquadsByTeamID(teamID, currentPage: page ?? currentPage)
            
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
        guard responseModel?.pagination?.nextPage != nil, hasMoreContent else { return }
        await fetchDataByTeamID()
    }
    
    func refresh() async {
        await fetchDataByTeamID(page: 1)
    }
    
    @MainActor
    func changeStateToEmpty() {
        changeState(.empty)
    }
    
    private func updateData(with result: PlayersResponseModel) {
        data += result.data
    }
}
