//
//  Utils.swift
//  Savary
//
//  Created by Pranav on 27/11/19.
//
import UIKit

struct Shoe {
    var id: Int
    var title: String
    var seller: String
    var price: String
  
    init(_ dictionary: [String: Any]) {
    self.id = dictionary["id"] as? Int ?? 0
    self.title = dictionary["title"] as? String ?? ""
    self.seller = dictionary["source"] as? String ?? ""
    self.price = dictionary["price"] as? String ?? ""
    }
}

func getShoeInfo(shoeName: String, userCompletionHandler: @escaping ([Shoe]?, Error?) -> Void){
    let urlString = "http://40.85.173.95/title_like/" + shoeName
    let escapedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    guard let url = URL(string: escapedURL!) else {return}
    var model = [Shoe]()
    let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
        guard let dataResponse = data, error == nil else {
            print(error?.localizedDescription ?? "Response Error")
            return
        }
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with: dataResponse, options: [])
            guard let jsonArray = jsonResponse as? [[String: Any]] else {
                return
            }
            model = jsonArray.compactMap{(dictionary) in return Shoe(dictionary)}
            userCompletionHandler(model,nil)
        }
        catch let parsingError {
            print("Error", parsingError)
            userCompletionHandler(nil,parsingError)
        }
    })
    task.resume()
}
