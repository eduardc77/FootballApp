//
//  LeaguesView.swift
//  FootballApp
//

import SwiftUI

struct LeaguesView: View {
    @State private var model = LeaguesViewModel()
    
    @Environment(ViewRouter.self) private var router
    @EnvironmentObject private var tabCoordinator: AppTabRouter
    @Environment(ModalScreenRouter.self) private var modalRouter
    
    var body: some View {
        baseView
            .navigationBar(title: "Leagues")
            .refreshable {
                Task {
                    await model.refresh()
                }
            }
    }
    
    @ViewBuilder
    private var baseView: some View {
        switch model.state {
        case .empty:
            Label("No Data", systemImage: "newspaper")
        case .finished:
            ScrollView {
                gridView
            }
        case .loading:
            ProgressView("Loading")
        case .error(error: let error):
            VStack {
                Label("Error", systemImage: "alert")
                Text(error)
            }
            .onFirstAppear {
                modalRouter.presentAlert(title: "Error", message: error) {
                    Button("Ok") {
                        //                        model.changeStateToEmpty()
                    }
                }
            }
        case .initial:
            ProgressView()
                .task {
                    await model.fetchAllData()
                }
        }
    }
}

// MARK: - Subviews

private extension LeaguesView {
    
    var gridView: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
            ForEach(model.data, id: \.id) { league in
                Button {
                    router.push(league.seasons ?? [])
                } label: {
                    LeagueGridItem(item: league)
                }
            }
            
            if model.state != .loading, !model.data.isEmpty, model.hasMoreContent {
                ProgressView()
                    .task {
                        await model.loadMoreContent()
                    }
            }
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        LeaguesView()
    }
}
