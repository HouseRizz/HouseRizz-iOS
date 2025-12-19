//
//  APIViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 20/06/24.
//

import Foundation
import Combine

class APIViewModel: ObservableObject {
    var cancellables = Set<AnyCancellable>()
    @Published var error: String = ""
    @Published var apis: [HRAPI] = []
    @Published var name: String = ""
    @Published var api: String = ""
    
    func addButtonPressed(){
        guard !name.isEmpty else {return}
        addAPI(name: name)
    }
    
    private func addAPI(name: String) {
        let newAPI = HRAPI(id: UUID(), name: name, api: api)
        FirestoreUtility.add(item: newAPI) { _ in }
    }
    
    func fetchAPI(){
        FirestoreUtility.fetch(sortBy: "name", ascending: true)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] (returnedItems: [HRAPI]) in
                self?.apis = returnedItems
            }
            .store(in: &cancellables)
    }
}
