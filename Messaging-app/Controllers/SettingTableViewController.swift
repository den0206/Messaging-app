//
//  SettingTableViewController.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/16.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var fullnameLabel: UILabel!
    
    var tapGesture : UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if FUser.currentUser() != nil {
            setupUI()
            
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
            avatarImageView.isUserInteractionEnabled = true
            avatarImageView.addGestureRecognizer(tapGesture)
        }

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if section == 1 {
            return 5
        }
        
        return 2
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0
        }
        return 30
    }
    
    //MARK: IBActions
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        
        FUser.logOutCurrentUser { (success) in
            
            if success {
                print("Logout")
                self.showLoginVC()
            }
        }
    }
    
    //MARK: helpers
    
    private func setupUI() {
        
        let currentUser = FUser.currentUser()!
        
        fullnameLabel.text = currentUser.fullname
        
        if currentUser.avatar != "" {
            imageFromData(pictureData: currentUser.avatar) { (avatar) in
                
                avatarImageView.image = avatar!.circleMasked
            }
        }
        
    }
    
    private func showLoginVC() {
        let loginVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        loginVC.modalPresentationStyle = .fullScreen
        self.present(loginVC, animated: true, completion: nil)
    }
    
    @objc func avatarTapped() {
        
//        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileVC") as! ProfileTableViewController
//        profileVC.user = FUser.currentUser()
//
//        navigationController?.pushViewController(profileVC, animated: true)
        
        let profileVC = ProfileCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        profileVC.user = FUser.currentUser()
        
        navigationController?.pushViewController(profileVC, animated: true)
        
    }
    
    
    
}
