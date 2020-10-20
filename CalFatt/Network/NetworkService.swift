//
//  NetworkService.swift
//  CalFatt
//
//  Created by Anil on 10/19/20.
//

import Foundation
import Firebase
import SwiftKeychainWrapper



enum ErrorMessage: String, Error {
    case invalidData = "Sorry. Something went wrong, try again"
    case invalidResponse = "Server error. Please modify your search and try again"
    case apiKeyError = "Something wrong with your api key please check it"
    case urlError = "Something wrong with the url"
    case foodsErrorEmty = "Foods Error is emty please check whether you enter food name correct or not"
}

class NetworkService{
    
    
    public static let shared: NetworkService = NetworkService()
    
    var ref: DatabaseReference!
    private var urlString:String?
    
    
    func getFoodResults(for query: String, completed: @escaping (Result<Search, ErrorMessage>) -> Void) {
        
        if let myApiKey = KeychainWrapper.standard.string(forKey: "myApiKey"), myApiKey != "No Key"{
            urlString = "https://api.nal.usda.gov/fdc/v1/foods/search?api_key=\(myApiKey)&query=\(query)&pageSize=25&pageNumber=1"
            //urlString = "https://api.nal.usda.gov/fdc/v1/food/454004?api_key=\(myApiKey)"
        }else{
            completed(.failure(.apiKeyError))
            return
        }
        guard let url = URL(string: urlString!) else {
            completed(.failure(.urlError))
            return}
       
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let _ = error {
                completed(.failure(.invalidData))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(.invalidResponse))
                return
            }
            
      
            
          
            guard let data = data else {
               
                completed(.failure(.invalidData))
                return
            }
            
            do {
                let deconder = JSONDecoder()
                deconder.keyDecodingStrategy = .convertFromSnakeCase
                let results = try deconder.decode(Search.self, from: data)
                
                if results.foods.isEmpty{
                    print("why")
                    completed(.failure(.foodsErrorEmty))
                    return
                }
                completed(.success(results))
                
                
            } catch {
                
                completed(.failure(.invalidData))
            }
            
            
        }
        task.resume()
        
        
        
    }
    
    func getApiKeyFromFirebase(){
        
        let _: Bool = KeychainWrapper.standard.removeObject(forKey: "myApiKey")
        
        var tempApiKey:String?
        
        ref = Database.database().reference()
        let myref = ref.child("apiKey")
        myref.observeSingleEvent(of: .value) { (snapshot) in
            tempApiKey = snapshot.value as? String
            let _: Bool = KeychainWrapper.standard.set(tempApiKey ?? "No Key", forKey: "myApiKey")
        }
        
        
        
    }
    
    
    
    
}
