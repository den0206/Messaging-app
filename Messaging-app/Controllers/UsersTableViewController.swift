//
//  UsersTableViewController.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/17.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Firebase

class UsersTableViewController: UITableViewController {
    
    var allUsers : [FUser] = []
    
    var activityIndicator : NVActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Users"
        tableView.tableFooterView = UIView()
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: tableView.frame.width / 2 - 30, y: tableView.frame.height / 2 - 30, width: 60.0, height: 60.0), type: .ballPulse, color: #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1), padding: nil)
        
        loadUsers()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.leftBarButtonItem = cancelButton
        
        
    }
    

    // MARK: - Table view data source

   

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UsersTableViewCell
        
        return cell
    }
    
    //MARK: LoadUsers
    
    private func loadUsers() {
        
        startIndicator()
        
        // All users
        
        var query : Query!
        
        query = firebaseReferences(.User).order(by: kFISRSTNAME, descending: false)
        
        query.getDocuments { (snapshot, error) in
            
            if error != nil {
                print("\(error?.localizedDescription)")
                self.hideIndicator()
                self.tableView.reloadData()
                return
            }
            
            // no error
            guard let snapshot = snapshot else {
                self.hideIndicator()
                return
            }
            
            if !snapshot.isEmpty {
               
                for userDictionary in snapshot.documents {
                    let userDictionary = userDictionary.data() as NSDictionary
                    let user = FUser(_dictionary: userDictionary)
                    
                    if user.objectId != FUser.currentID() {
                        self.allUsers.append(user)
                    }
                }
                
               // split Data
            }
            
            self.tableView.reloadData()
            self.hideIndicator()
            print(self.allUsers.count)
            
        }
        
    }
    //MARK: Helpers
    
    private func startIndicator() {
        
        if activityIndicator != nil {
            self.view.addSubview(activityIndicator!)
            activityIndicator?.startAnimating()
        }
    }
    
    private func hideIndicator() {
        
        if activityIndicator != nil {
            activityIndicator?.removeFromSuperview()
            activityIndicator?.stopAnimating()
        }
    }
    

    
    @objc func cancel() {
        
        navigationController?.popViewController(animated: true)
    }
    
    
}
