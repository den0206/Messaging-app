//
//  ProfileTableViewController.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/18.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var fullnameLabel: UILabel!
    
    @IBOutlet weak var messageButtonOutlet: UIButton!
    
    @IBOutlet weak var blockUserButtonOutlet: UIButton!
    
    
    @IBOutlet weak var cell1: UITableViewCell!
    
    @IBOutlet weak var cell2: UITableViewCell!
    
    @IBOutlet weak var cell3: UITableViewCell!
    

    
    
    var user : FUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        setConstrait()
        
        setupUI()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
          // #warning Incomplete implementation, return the number of sections
          return 3
      }

      override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          // #warning Incomplete implementation, return the number of rows
          return 1
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
      
      override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
          return UIView()
      }
    //MARK: IBActions
    
    @IBAction func messageButtonPressed(_ sender: Any) {
        print("a")
    }
    
    @IBAction func blockUserButtonPressed(_ sender: Any) {
        var currentBlockId = FUser.currentUser()!.blockedUsers
        
        if currentBlockId.contains(user!.objectId) {
            currentBlockId.remove(at: currentBlockId.firstIndex(of: user!.objectId)!)
        } else {
            currentBlockId.append(user!.objectId)
        }
        
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID : currentBlockId]) { (error) in
            
            if error != nil {
                print("\(error?.localizedDescription)")
                return
            }
            
            self.updateBlockButton()
            
        }
    }
    
    private func updateBlockButton() {
        
        if FUser.currentUser()!.blockedUsers.contains(user!.objectId) {
            
            blockUserButtonOutlet.setTitleColor(.red, for: .normal)
            blockUserButtonOutlet.backgroundColor = .white
            blockUserButtonOutlet.setTitle("UnBlock", for: .normal)
            
        } else {
            blockUserButtonOutlet.setTitleColor(.white, for: .normal)
            blockUserButtonOutlet.backgroundColor = .red
            blockUserButtonOutlet.setTitle("Block", for: .normal)
        }
        
    }
    
    //MARK: set constracts
    private func setConstrait() {
        
        avatarImageView.anchor(top: nil, left: cell1.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 14, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        avatarImageView.centerYAnchor.constraint(equalTo: cell1.centerYAnchor).isActive = true
        
        fullnameLabel.anchor(top: nil, left: avatarImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        fullnameLabel.centerYAnchor.constraint(equalTo: cell1.centerYAnchor).isActive = true
        
        messageButtonOutlet.anchor(top: cell2.topAnchor, left: cell2.leftAnchor, bottom: cell2.bottomAnchor, right: cell2.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: cell2.frame.width, height: cell2.frame.height)
        
        blockUserButtonOutlet.anchor(top: cell3.topAnchor, left: cell3.leftAnchor, bottom: cell3.bottomAnchor, right: cell3.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    private func setupUI() {
        
        if user != nil {
            self.title = user?.fullname
            fullnameLabel.text = user?.fullname
            
            updateBlockButton()
            
            imageFromData(pictureData: user!.avatar) { (avatar) in
                self.avatarImageView.image = avatar?.circleMasked
            }
        }
    }
    
   
    
    

    
}
