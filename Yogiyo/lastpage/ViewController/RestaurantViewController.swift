//
//  RestaurantViewController.swift
//  TableViewYogiyo
//
//  Created by Kira on 28/11/2018.
//  Copyright © 2018 Kira. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class RestaurantViewController: UIViewController {
    var restaurantId: Int?
    
    lazy var menuData: [MenuElement] = {
        var menu = [MenuElement]()
        return menu
    }()
    
    lazy var reviewData: Review = {
        var review = [ReviewElement]()
        return review
    }()
    
    let infoTableView = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
    private let paymentView = PaymentView()
    
    private let headerView = HeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 320))
    private let footerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
    
    private var tableViewData = [MenuCellData]()
    
    private var recommendMenuViews: [RecommendMenuView] = []
    
    private var categoryTag = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        configureLayout()
        cellOfReview()
        dataPass(id: restaurantId ?? 0)

      
    }
    
    private func dataPass(id: Int) {
        print("333",id)
        Alamofire.request("https://jogiyo.co.kr/restaurants/api/\(id)/menu/").responseData(completionHandler: { response in
            if let jsonData = response.result.value {
                let result = try? JSONDecoder().decode(Menu.self, from: jsonData)
                self.menuData = result!
            }
            
            self.createRecommendMenuView(data: self.menuData[0].food)
            self.createMenuData()
            self.infoTableView.reloadData()
        
            self.headerView.titleInfoView.storeTitleLabel.text = self.menuData[0].restaurant.name
            self.headerView.titleInfoView.ratingLabel.text = self.menuData[0].restaurant.reviewAvg
            self.headerView.titleInfoView.discountLabel.text = "\(self.menuData[0].restaurant.minOrderAmount)"
            self.headerView.titleInfoView.intervalLabel.text = self.menuData[0].restaurant.estimatedDeliveryTime
            
            let url = self.menuData[0].restaurant.logoURL
            Alamofire.request(url).responseImage { response in
                switch response.result {
                case .success(_): if let image = response.result.value {
                    let img = image
                    self.headerView.titleImageView.image = img
                    self.headerView.titleImageView.clipsToBounds = true
                    self.headerView.titleImageView.contentMode = .scaleAspectFit
                    }
                case .failure(let err) : print("에러: \(err)")
                }
            }
        })
    }
    
    private func configure() {
        let resNib = UINib(nibName: "ReviewTableViewCell", bundle: nil)

        headerView.categoryButtonsView.deldgate = self
   
        infoTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        infoTableView.sectionHeaderHeight = 3
        infoTableView.sectionFooterHeight = 3
        infoTableView.tableHeaderView = headerView
        footerView.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        infoTableView.tableFooterView = footerView
        infoTableView.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        infoTableView.delegate = self
        infoTableView.dataSource = self
        // 메뉴 셀
        infoTableView.register(RecommendMenuViewCell.self, forCellReuseIdentifier: "RecommendMenuViewCell")
        infoTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell1")
        infoTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell2")
        infoTableView.register(resNib, forCellReuseIdentifier: "ReviewTableViewCell")
        
        // 리뷰 셀
        infoTableView.register(RatingTableViewCell.self, forCellReuseIdentifier: "RatingTableViewCell")
        infoTableView.register(ReviewTopTableViewCell.self, forCellReuseIdentifier: "ReviewTopTableViewCell")
        
        view.addSubview(infoTableView)
        
        view.addSubview(paymentView)
    }
    
    private struct Standard {
        static let space: CGFloat = 10
        
        static let paymentViewHeight: CGFloat = 50
    }
    
    private func configureLayout() {
        infoTableView.translatesAutoresizingMaskIntoConstraints = false
        infoTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        infoTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        infoTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        infoTableView.bottomAnchor.constraint(equalTo: paymentView.topAnchor).isActive = true
        
        paymentView.translatesAutoresizingMaskIntoConstraints = false
        paymentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        paymentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        paymentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        paymentView.heightAnchor.constraint(equalToConstant: Standard.paymentViewHeight).isActive = true
    }
    
    func cellOfReview(){
        print(restaurantId,",1111")
        Alamofire.request("https://jogiyo.co.kr/restaurants/api/\(restaurantId!)/review/", method: .get
            , encoding: JSONEncoding.default).responseData { response in
                debugPrint(response)
                if let jsonData = response.result.value {
                    let result = try? JSONDecoder().decode(Review.self, from: jsonData)
                    self.reviewData = result!
                }
            self.infoTableView.reloadData()
        }
    }
    
    func createRecommendMenuView(data: [Food]) {
        for index in 0..<data.count {
            let tempRecommentMenuView = RecommendMenuView()
            tempRecommentMenuView.tag = index
            var img = Image()
            let url = data[index].image
            Alamofire.request(url!).responseImage { response in
                switch response.result {
                case .success(_): if let image = response.result.value {
                    img = image
                    }
                case .failure(let err) : print("에러: \(err)")
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                tempRecommentMenuView.imageView.image = img
            }
            tempRecommentMenuView.nameLabel.text = data[index].name
            tempRecommentMenuView.priceLabel.text = String(data[index].price)
            tempRecommentMenuView.translatesAutoresizingMaskIntoConstraints = false
            recommendMenuViews.append(tempRecommentMenuView)
        }
    }
    
    private func createMenuData() {
        for index in 1..<menuData.count{
            tableViewData.append(MenuCellData(
                id: menuData[index].id,
                opened: returnBool(index: index),
                title: menuData[index].name,
                sectionData: menuData[index].food))
        }
    }
    private func returnBool(index: Int) -> Bool {
        if index == 1 {return true} else {return false}
    }
}

extension RestaurantViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        switch categoryTag {
        case 0:
            return tableViewData.count + 1
        case 1:
            return 2
        default:
            return 2
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch categoryTag {
        case 0:
            if section == 0 {
                return 1
            } else {
                if tableViewData[section - 1].opened == true {
                    return tableViewData[section - 1].sectionData.count + 1
                } else {
                    return 1
                }
            }
        case 1:
            if section == 0 {
                return 1
            } else {
                return 10
            }
        default:
            return 10
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch categoryTag {
        case 0:
            let dataIndex = indexPath.row - 1
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RecommendMenuViewCell") as! RecommendMenuViewCell
                cell.recommendViews = recommendMenuViews
                return cell
            } else {
                if indexPath.row == 0 {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell1") else {return UITableViewCell()}
                    cell.textLabel?.text = tableViewData[indexPath.section - 1].title
                    return cell
                } else {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell2") else {return UITableViewCell()}
                    cell.textLabel?.text = tableViewData[indexPath.section - 1].sectionData[dataIndex].name
                    return cell
                }
            }
        case 1:
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RatingTableViewCell") as! RatingTableViewCell
                return cell
            } else {
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTopTableViewCell") as! ReviewTopTableViewCell
                    cell.delegete = self
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTableViewCell", for: indexPath)  as! ReviewTableViewCell
                    cell.idLabel.text = reviewData[indexPath.row].user.username.rawValue
                    cell.commentLabel.text = reviewData[indexPath.row].comment
                    return cell
                }
                
            }
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath)
            cell.textLabel?.text = "\(indexPath.section) --- \(indexPath.row)"
            return cell
        }
    }
}

extension RestaurantViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch categoryTag {
        case 0:
            if indexPath.section == 0 {
                return 200
            } else {
                if indexPath.row == 0 {
                    return 50
                } else {
                    return 100
                }
            }
        case 1:
            if indexPath.section == 0 {
                return 100
            } else {
                if indexPath.row == 0 {
                    return 50
                } else {
                    return 148
                }
            }
        default:
            if indexPath.section == 0 {
                return 100
            } else {
                return 100
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch categoryTag {
        case 0:
            if indexPath.section == 0 {
            } else {
                let dataIndex = indexPath.row - 1
                if indexPath.row == 0 {
                    if tableViewData[indexPath.section - 1].opened == true {
                        tableViewData[indexPath.section - 1].opened = false
                        let sections = IndexSet.init(integer: indexPath.section)
                        tableView.reloadSections(sections, with: UITableView.RowAnimation.automatic)
                    } else {
                        tableViewData[indexPath.section - 1].opened = true
                        let sections = IndexSet.init(integer: indexPath.section)
                        tableView.reloadSections(sections, with: UITableView.RowAnimation.automatic)
                    }
                } else {
                    print(tableViewData[indexPath.section - 1].sectionData[dataIndex].name)
                }
            }
        case 1:
            break
        default:
            break
        }
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(scrollView.contentOffset.y)
//
//        if scrollView.contentOffset.y > 250 {
//            headerView.guidanceCategoryButtonViewTop?.priority = UILayoutPriority(999)
//        } else {
//            headerView.guidanceCategoryButtonViewTop?.priority = .defaultLow
//        }
//        infoTableView.layoutIfNeeded()
//    }
}

extension RestaurantViewController: CategoryButtonsViewDelegate {
    func categoryChange(sender: UIButton) {
        categoryTag = sender.tag
        infoTableView.reloadData()
    }
}

extension RestaurantViewController: ReviewTopTableViewCellDelegate {
    func photoSwitchValueChageed(sender: Bool) {
        print(sender)
    }
}

extension RestaurantViewController : SendDataDelegate {
    func sendData(data: Int) {
        restaurantId = data
    }
    
}