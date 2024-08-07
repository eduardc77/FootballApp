//
//  PlayersCoordinator.swift
//  FootballApp
//

import SwiftUI

struct PlayersCoordinator: View {
    @State private var router = ViewRouter()
    @EnvironmentObject private var tabRouter: AppTabRouter
    @Environment(ModalScreenRouter.self) private var modalRouter
    
    var body: some View {
        NavigationStack(path: $router.path) {
            PlayersView(model: PlayersViewModel())
                .onReceive(tabRouter.$tabReselected) { tabReselected in
                    guard tabReselected, tabRouter.selection == .players, !router.path.isEmpty else { return }
                    router.popToRoot()
                }
        }
        .environment(router)
    }
}

#Preview {
    LeaguesCoordinator()
}
