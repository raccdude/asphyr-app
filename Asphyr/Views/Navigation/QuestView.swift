//
//  QuestView.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/17/26.
//

import SwiftUI

struct QuestView: View {

    enum QuestFilter: String, CaseIterable {
        case all = "ALL"
        case available = "AVAILABLE"
        case active = "ACTIVE"
        case completed = "COMPLETED"
    }
    
    @State private var selectedFilter: QuestFilter = .all
    @Namespace private var filterNamespace
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.asphyrBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        HStack {
                            Text("QUEST LOG")
                                .font(.system(size: 14, weight: .bold))
                                .tracking(1.5)
                                .foregroundStyle(Color.asphyrTextSecondary)
                            Spacer()
                        }
                        
                        Text("QUESTS")
                            .font(.system(size: 28, weight: .black))
                            .foregroundStyle(Color.asphyrTextPrimary)
                            
                        questFilterBar
                
                        Text("Showing \(selectedFilter.rawValue.capitalized) Quests")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.asphyrTextSecondary)
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
            }
        }
    }
    
    private var questFilterBar: some View {
        HStack(spacing: 2) {
            ForEach(QuestFilter.allCases, id: \.self) { filter in
                let isSelected = selectedFilter == filter
                
                Text(filter.rawValue)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(isSelected ? Color.asphyrTextPrimary : Color.asphyrTextSecondary)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.asphyrSurfaceElevated)
                                .matchedGeometryEffect(id: "activeFilterTab", in: filterNamespace)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                            selectedFilter = filter
                        }
                    }
            }
        }
        .padding(4)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.asphyrSurface))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.asphyrBorder, lineWidth: 1))
    }
}

#Preview {
    QuestView()
}
