//
//  SearchViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 12/06/24.
//

import Foundation

class SearchViewModel: ObservableObject {
    
    @Published var selectedCity: String = availableCities.delhi.title
}
