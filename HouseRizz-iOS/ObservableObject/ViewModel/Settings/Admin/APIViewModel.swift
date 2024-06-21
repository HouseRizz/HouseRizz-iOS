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
        guard let newAPI = HRAPI(id: UUID(), name: name, api: api) else {
            error = "Error creating item"
            return
        }
        
        CKUtility.add(item: newAPI) { _ in }
    }
    
    func fetchAPI(){
        let predicate = NSPredicate(value: true)
        let recordType = HRAPIModelName.itemRecord
        CKUtility.fetch(predicate: predicate, recordType: recordType, sortDescription: [NSSortDescriptor(key: "name", ascending: true)])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] returnedItems in
                self?.apis = returnedItems
            }
            .store(in: &cancellables)
    }
}
