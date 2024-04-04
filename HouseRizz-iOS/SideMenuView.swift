//
//  SideMenuView.swift
//  HouseRizz
//
//  Created by Krish Mittal on 01/04/24.
//

import SwiftUI

struct SideMenuView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showMenu: Bool = false
    @State private var selectedTab: Tab = .Home
    @State private var showSettings: Bool = false
    
    enum Tab: String, CaseIterable {
        case Home = "house.fill"
        case AR = "camera"
        var title: String {
            switch self {
            case .Home: return "Home"
            case .AR: return "AR"
            }
        }
    }
    
    var body: some View {
        SideMenu(showMenu: $showMenu) { safeArea in
            NavigationView {
                VStack {
                    switch selectedTab {
                    case .Home:
                        HomeView()
                    case .AR:
                        CameraView()
                    }
                }
                .navigationTitle(selectedTab.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: { showMenu.toggle() }, label: {
                            Image(systemName: showMenu ? "xmark" : "line.3.horizontal")
                                .foregroundStyle(Color.primary)
                                .contentTransition(.symbolEffect)
                        })
                    }
                }
            }
        } menuView: { safeArea in
            SideBarMenuView(safeArea, selectedTab: $selectedTab)
                .background(colorScheme == .light ? Color.white : Color.black)
        }
        
    }
    
    @ViewBuilder
    func SideBarMenuView(_ safeArea: UIEdgeInsets, selectedTab: Binding<Tab>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Tab.allCases, id: \.self) { tab in
                SideBarButton(tab, isSelected: tab == selectedTab.wrappedValue) {
                    selectedTab.wrappedValue = tab
                    
                }
            }
            Spacer()
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 20)
        .padding(.top, safeArea.top)
        .padding(.bottom, safeArea.bottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    @ViewBuilder
    func SideBarButton(_ tab: Tab, isSelected: Bool, onTap: @escaping () -> () = { }) -> some View {
        Button(action: {
            onTap()
            showMenu = false
        }, label: {
            HStack(spacing: 12) {
                Image(systemName: tab.rawValue)
                    .font(.title3)
                Text(tab.title)
                    .font(.callout)
                Spacer(minLength: 0)
            }
            .foregroundColor(colorScheme == .light ? .black : .white)
            .padding(.vertical, 10)
            .padding(.horizontal,10)
            .contentShape(.rect)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.gray.opacity(0.2) : Color.clear)
            )
        })
    }
}

#Preview {
    SideMenuView()
}
