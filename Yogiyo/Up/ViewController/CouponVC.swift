//
//  testViewController.swift
//  Yogiyo
//
//  Created by EunKyung Park on 11/30/18.
//  Copyright © 2018 EunKyung Park. All rights reserved.
//

import Alamofire
import UIKit


class CouponVC: UIViewController {
    final let url = URL(string: "https://jogiyo.co.kr/restaurants/api/restaurant/?ordering=-review_avg")
    
    lazy var restaurantData: [FoodlistElement] = {
        var restaurants = [FoodlistElement]()
        return restaurants
    }()


    @IBOutlet weak var NavBar: UINavigationBar!
    @IBAction func onMoreTapped() {
        print("more tapped")
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)    }

    @IBAction func goBackToOneButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "unwindSegueToMenu", sender: self)
    }
    


    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NavBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.regular)]
        let height: CGFloat = 50
        let bounds = self.navigationController!.navigationBar.bounds
        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + height)
        downloadJSON()
        
      
    }


    
    func downloadJSON() {
        guard let downloadURL = url else { return }
        URLSession.shared.dataTask(with: downloadURL) { data, urlResponse, error in
            guard let data = data, error == nil, urlResponse != nil else {
                return
            }
            print("Downloaded")
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(Foodlist.self, from: data)
                self.restaurantData = result
                let reviewAverage = result.map { ($0.reviewAvg) }
                let reviewName = result.map { ($0.name) }
                let reviewFloat = reviewAverage.map { ($0 as NSString).floatValue}

//                 print(reviewFloat)
//                 print(reviewName)
                    for i in 1...6 {
                        let rating = reviewAverage
                      
                        print(self.restaurantData[i].name)
                        print(self.restaurantData[i].reviewAvg)
                        print(self.restaurantData[i].reviewCount)
                    }
            } catch { print("something went wrong ") }
        }.resume()
    }

}

