

import Foundation
import FirebaseFirestore
import Firebase
import MBProgressHUD

let storage = Storage.storage()

//MARK: Image Section

func uploadImage(image : UIImage, chatRoomId : String, view : UIView, completion : @escaping(_ imageLink : String?) -> Void) {
    
    let MB = MBProgressHUD.showAdded(to: view, animated: true)
    MB.mode = .determinateHorizontalBar
    
    let dateString = dateFormatter().string(from: Date())
    let photoFileName = "PictureMessages/" + FUser.currentID() + "/" + chatRoomId + "/" + dateString + ".jpg"
    
    let storageRef = storage.reference(forURL: kFILEREFERENCE).child(photoFileName)

    // make ImageData
    let imageData = image.jpegData(compressionQuality: 0.3)
    var task : StorageUploadTask!
    
    // upload
    
    task = storageRef.putData(imageData!, metadata: nil, completion: { (metaData, error) in
        
        task.removeAllObservers()
        MB.hide(animated: true)
        
        if error != nil {
            print(error!.localizedDescription)
            return
        }
        // no error
        storageRef.downloadURL { (url, error) in
            
            guard let downloadUrl = url else {
                completion(nil)
                return
            }
            completion(downloadUrl.absoluteString)
            
        }

    })
    
    // show HUD
    
    task.observe(StorageTaskStatus.progress) { (snapshot) in
        MB.progress = Float((snapshot.progress?.completedUnitCount)!) / Float((snapshot.progress?.totalUnitCount)!)
    }
}

func downLoadImage(imageLink : String) -> UIImage?{
    let imageUrl = NSURL(string: imageLink)
    let imageFileName = (imageLink.components(separatedBy: "%").last!).components(separatedBy: "?").first!
    
    // check Exist
    if fileExistPath(path: imageLink) {
        
        if let componentsFile = UIImage(contentsOfFile: fileInDocumentDirectry(fileName: imageFileName)) {
            return componentsFile
        } else {
            return nil
        }
    } else {
        let nsData = NSData(contentsOf: imageUrl! as URL)
        
        if nsData != nil {
            // add To documentsUrl
            var docURL = getDocumentUrl()
            
            docURL = docURL.appendingPathComponent(imageFileName, isDirectory: false)
            nsData!.write(to: docURL, atomically: true)
            
            let imageToReturn = UIImage(data: nsData! as Data)
            return imageToReturn
            
        } else {
            print("No Image Database")
            return nil
        }
    }
    
    
    
    
}

//MARK: Helpers

func fileExistPath(path : String) -> Bool{
    var doesExist : Bool
    
    let filePath = fileInDocumentDirectry(fileName: path)
    let fileManger = FileManager.default

    
    if fileManger.fileExists(atPath: filePath) {
        doesExist = true
    } else {
        doesExist = false
    }
    
    return doesExist
    
}

func fileInDocumentDirectry(fileName : String) -> String {
    let fileURL = getDocumentUrl().appendingPathComponent(fileName)
    
    return fileURL.path
    
}

func getDocumentUrl() ->URL {
     let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    return documentUrl!
}

