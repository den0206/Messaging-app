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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if FUser.currentUser() != nil {
            setupUI()
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
    

    
}
