//
//  ManageProductCategoriesViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 19/06/24.
//

import SwiftUI
import Combine

class ManageProductCategoriesViewModel: ObservableObject {
    @Published var isSignedInToiCloud: Bool = false
    @Published var error: String = ""
    @Published var permissionStatus: Bool = false
    @Published var categories: [HRProductCategory] = []
    @Published var selectedPhotoData = [Data]()
    var cancellables = Set<AnyCancellable>()
    
    init(){
        getiCloudStatus()
        requestPermission()
        fetchCategories()
    }
    
    private func getiCloudStatus(){
        CKUtility.getiCloudStatus()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] success in
                self?.isSignedInToiCloud = success
            }
            .store(in: &cancellables)
    }
    
    func requestPermission(){
        CKUtility.requestApplicationPermission()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] success in
                self?.permissionStatus = success
            }
            .store(in: &cancellables)
    }
    
    func fetchCategories(){
        let predicate = NSPredicate(value: true)
        let recordType = HRProductCategoryModelName.itemRecord
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
                self?.categories = returnedItems
            }
            .store(in: &cancellables)
    }
}
