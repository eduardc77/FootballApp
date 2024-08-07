//
//  StagesView.swift
//  FootballApp
//

import SwiftUI

struct StagesView: View {
    @State private var model: StagesViewModel
    
    @Environment(ViewRouter.self) private var router
    @EnvironmentObject private var tabCoordinator: AppTabRouter
    @Environment(ModalScreenRouter.self) private var modalRouter
    
    init(model: StagesViewModel = StagesViewModel()) {
        self.model = model
    }
    
    var body: some View {
        baseView
            .navigationBar(title: "Stages")
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
                    Button("OK") {
                        //                        model.changeStateToEmpty()
                    }
                }
            }
        case .initial:
            ProgressView()
                .task {
                    if let seasonID = model.seasonID {
                        await model.fetchDataBySeasonID(seasonID)
                    } else {
                        await model.fetchAllData()
                    }
                }
        }
    }
}

// MARK: - Subviews

private extension StagesView {
    
    var gridView: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
            ForEach(model.data, id: \.id) { stage in
                VStack {
                    StageGridItem(item: stage)
                    
                    CTAButton(title: "Rounds/Fixtures") {
                        if let rounds = stage.rounds, !rounds.isEmpty {
                            router.push(rounds)
                        } else {
                            router.push(stage.fixtures)
                        }
                    }
                    
                    CTAButton(title: "Top Scorers") {
                        router.push(TopScorerDestination.stage(id: stage.id))
                    }
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
        StagesView()
    }
}
