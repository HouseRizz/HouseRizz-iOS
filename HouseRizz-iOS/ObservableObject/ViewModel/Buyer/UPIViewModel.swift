//
//  UPIViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 14/06/24.
//

import SwiftUI

class UPIViewModel: ObservableObject {
    @Published var installedAppList: [UPIAppListViewDataModel] = []
    @Published var selectedApp: String = ""
    var upiApps: [String] = []
    var upiImageUrl: [URL] = []
    
    let appSchemes: [String: String] = [
            "paytm": "Paytm",
            "phonepe": "PhonePe",
            "gpay": "Google Pay",
            "amazon": "Amazon",
            "bhim": "Bhim",
            "cred": "Cred",
            "payzapp": "PayZapp",
            "amazonToAlipay": "AmazonToAlipay",
            "whatsapp": "Whatsapp",
            "slice": "Slice",
            "mobikwik": "Mobikwik",
            "kiwi": "Kiwi",
            "freecharge": "FreeCharge",
            "myjio": "MyJIO"
        ]
    
    init() {
        checkUPIInstalledAppsInDevice()
    }
    
    func checkUPIInstalledAppsInDevice() {
        var resourceFileDictionary: NSDictionary?
           
        // Load content of Info.plist into resourceFileDictionary dictionary
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            resourceFileDictionary = NSDictionary(contentsOfFile: path)
        }
           
        if let resourceFileDictionaryContent = resourceFileDictionary {
            // Retrieve the value from plist
            upiApps = resourceFileDictionaryContent.object(forKey: "LSApplicationQueriesSchemes")! as! [String]
        }
        
        let app = UIApplication.shared
        for i in upiApps {
            let appScheme = "\(i)://app"
            if app.canOpenURL(URL(string: appScheme)!) {
                installedAppList.append(createDataModel(appName: i))
            }
        }
    }
    
    func launchIntentURLFromStr(intent: String, payeeVPA: String, payeeName: String, amount: String, currencyCode: String, transactionNote: String?) {
        if intent.isEmpty {
            return
        }
        
        var urlComponents = URLComponents(string: "\(intent)://upi/pay")!
        urlComponents.queryItems = [
            URLQueryItem(name: "pa", value: payeeVPA),
            URLQueryItem(name: "pn", value: payeeName),
            URLQueryItem(name: "am", value: amount),
            URLQueryItem(name: "cu", value: currencyCode)
        ]
        
        if let transactionNote = transactionNote {
            urlComponents.queryItems?.append(URLQueryItem(name: "tn", value: transactionNote))
        }
        
        guard let url = urlComponents.url else {
            return
        }
        
        UIApplication.shared.open(url)
    }
    
    func getAppIconURL(appName: String) -> URL? {
        let url = URL(string: "https://itunes.apple.com/search?term=\(appName)&entity=software&country=IN")!
        var icon: URL? = nil
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
     
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let results = json?["results"] as? [[String: Any]],
                   let iconURLString = results.first?["artworkUrl100"] as? String,
                   let iconURL = URL(string: iconURLString) {
                    icon = iconURL
                    return
                } else {
                    return
                }
            } catch {
                return
            }
        }.resume()
        return icon
    }
    
    func getAppName(itemName: String) -> String {
        
        for (scheme, appName) in appSchemes {
            if itemName.lowercased().contains(scheme) {
                return appName
            }
        }
        
        return itemName.uppercased()
    }

    
    func createDataModel(appName: String) -> UPIAppListViewDataModel {
        return UPIAppListViewDataModel(appname: appName)
    }
}


