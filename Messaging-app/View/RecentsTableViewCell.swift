//
//  RexentsTableViewCell.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/17.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit

protocol RecentTableViewCellDelegate {
    
    func avatarTapped(indexpath :IndexPath)
}



class RecentsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.contentMode = .scaleAspectFit
            avatarImageView.clipsToBounds = true
            
        }
    }
    
    @IBOutlet weak var fullNameLabel: UILabel! {
        didSet {
            fullNameLabel.font = UIFont.boldSystemFont(ofSize: 14)
        
        }
    }
    
    @IBOutlet weak var lastMessageLabel: UILabel! {
        didSet {
            lastMessageLabel.font = UIFont.systemFont(ofSize: 12)
        }
    }
    
    @IBOutlet weak var dateLabel: UILabel! {
        didSet {
            dateLabel.font = UIFont.systemFont(ofSize: 12)
        }
    }
    
    var indexPath :IndexPath!
    var delegate :RecentTableViewCellDelegate?
    let tapGesture = UITapGestureRecognizer()
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 70, height: 70)
        avatarImageView.layer.cornerRadius = 50 / 2
        avatarImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
         fullNameLabel.anchor(top: avatarImageView.topAnchor, left: avatarImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
          lastMessageLabel.anchor(top: fullNameLabel.bottomAnchor, left: avatarImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        dateLabel.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        
        configureAvatar()
        
       
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
    func generateCell(recentChat : NSDictionary, indexPath : IndexPath) {
        self.indexPath = indexPath
        
        self.fullNameLabel.text = recentChat[kWITHUSERFULLNAME] as? String
        self.lastMessageLabel.text = recentChat[kLASTMESSAGE] as? String
        
        if let avatarImage = recentChat[kAVATAR] {
            imageFromData(pictureData: avatarImage as! String) { (avatar) in
                self.avatarImageView.image = avatar!.circleMasked
            }
        }
        
        var date : Date!
        
        if let created = recentChat[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: created as! String)!
            }
        } else {
            date = Date()
        }
        
        self.dateLabel.text = timeElapsed(date: date)
        
    }
    
    private func configureAvatar() {
        tapGesture.addTarget(self, action: #selector(avatarTapped))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGesture)
        
    }
   
    @objc func avatarTapped() {
        delegate?.avatarTapped(indexpath: indexPath)
    }

}
