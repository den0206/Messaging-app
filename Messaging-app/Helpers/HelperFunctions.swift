//
//  helperFunctions.swift
//  InsCopy
//
//  Created by 酒井ゆうき on 2020/01/12.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import Foundation
import  UIKit
import FirebaseFirestore

//MARK: GLOBAL FUNCTIONS
private let dateFormat = "yyyyMMddHHmmss"

func dateFormatter() -> DateFormatter {
    
    let dateFormatter = DateFormatter()
    
    dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
    
    dateFormatter.dateFormat = dateFormat
    
    return dateFormatter
}


func imageFromData(pictureData: String, withBlock: (_ image: UIImage?) -> Void) {
    
    var image: UIImage?
    
    let decodedData = NSData(base64Encoded: pictureData, options: NSData.Base64DecodingOptions(rawValue: 0))
    
    image = UIImage(data: decodedData! as Data)
    
    withBlock(image)
}

func downloadImageFromData(pictureData: String) -> UIImage? {
    
    let imageFileName = (pictureData.components(separatedBy: "%").last!).components(separatedBy: "?").first!


    if fileExistPath(path: imageFileName) {

        if let comtentsOfFile = UIImage(contentsOfFile: fileInDocumentDirectry(fileName: imageFileName)) {


            return comtentsOfFile
        } else {
            print("couldnt generateimage")
            return nil
        }
    } else {
        //        let data = NSData(contentsOf: imageURL! as URL)
       let data = NSData(base64Encoded: imageFileName, options: NSData.Base64DecodingOptions(rawValue: 0))

        if data != nil {
            var docURL = getDocumentUrl()

            docURL = docURL.appendingPathComponent(imageFileName, isDirectory: false)
            data!.write(to: docURL, atomically: true)

            let imageToReturn = UIImage(data: data! as Data)
            return imageToReturn

        } else {

            print("No image in Database")
            return nil

        }

    }
}


func isValidEmail(_ string: String) -> Bool {
       let emailRegEx = "[A-Z0-9a-z._+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
       let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
       let result = emailTest.evaluate(with: string)
       return result
}

func timeElapsed(date: Date) -> String {
    
    let seconds = NSDate().timeIntervalSince(date)
    
    var elapsed: String?
    
    
    if (seconds < 60) {
        elapsed = "Just now"
    } else if (seconds < 60 * 60) {
        let minutes = Int(seconds / 60)
        
        var minText = "min"
        if minutes > 1 {
            minText = "mins"
        }
        elapsed = "\(minutes) \(minText)"
        
    } else if (seconds < 24 * 60 * 60) {
        let hours = Int(seconds / (60 * 60))
        var hourText = "hour"
        if hours > 1 {
            hourText = "hours"
        }
        elapsed = "\(hours) \(hourText)"
    } else {
        let currentDateFormater = dateFormatter()
        currentDateFormater.dateFormat = "dd/MM/YYYY"
        
        elapsed = "\(currentDateFormater.string(from: date))"
    }
    
    return elapsed!
}

// snapshot to NSDictionary

func dictionaryFromSnapshots(snapshots : [DocumentSnapshot]) -> [NSDictionary] {
    
    var allMassages : [NSDictionary] = []
    for snapshot in snapshots {
        allMassages.append(snapshot.data() as! NSDictionary)
    }
    return allMassages
}

