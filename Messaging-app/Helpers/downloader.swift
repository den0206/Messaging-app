

import Foundation
import FirebaseFirestore
import Firebase
import MBProgressHUD
import AVFoundation

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



//MARK: Video Section

func uploadVideo(videoUrl : NSData, chatRoomId : String, view : UIView, completion : @escaping(_ videoLink : String?) -> Void) {
    
    let MB = MBProgressHUD.showAdded(to: view, animated: true)
    MB.mode = .determinateHorizontalBar
    
    let dateString = dateFormatter().string(from: Date())
    let videoFileName = "VideoMessages/" + FUser.currentID() + "/" + chatRoomId + "/" + dateString + ".mov"
    
    let storegeRef = storage.reference(forURL: kFILEREFERENCE).child(videoFileName)
    var task : StorageUploadTask!
    
    task = storegeRef.putData(videoUrl as Data, metadata: nil, completion: { (metaData, error) in
        task.removeAllObservers()
        MB.hide(animated: true)
        
        if error != nil {
            print(error!.localizedDescription)
            return
        }
        
        // no error
        storegeRef.downloadURL { (url, error) in
            
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

func downloadVideo(videoUrl : String, completion : @escaping(_ isReadyToPlay: Bool, _ videoFileName: String) -> Void) {
    
    let videoURL = NSURL(string: videoUrl)
   
    
    let videoFileName = (videoUrl.components(separatedBy: "%").last!).components(separatedBy: "?").first!

    
    if fileExistPath(path: videoFileName) {
        // exist
        
        completion(true, videoFileName)
        
    } else {
        // not exist
        let downloadQue = DispatchQueue(label: "videoDownloadQueue")
        downloadQue.async {
            let data = NSData(contentsOf: videoURL! as URL)
            
            if data != nil {
                var docURL = getDocumentUrl()
                
                docURL = docURL.appendingPathComponent(videoFileName, isDirectory: false)
                data!.write(to: docURL, atomically: true)
                
                
                DispatchQueue.main.async {
                    completion(true, videoFileName)
                }
            } else {
                DispatchQueue.main.async {
                    print("No video in Database")
                }
            }
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

func videoThmbnail(video: NSURL) -> UIImage {
    
    let asset = AVURLAsset(url: video as URL, options: nil)
    
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    
    let time = CMTime(seconds: 0.5, preferredTimescale: 1000)
    var actualTime = CMTime.zero
    
    var image : CGImage?
    
    do {
        image = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
    } catch let error as NSError {
        print(error.localizedDescription)
    }
    
    let thunmbnail = UIImage(cgImage: image!)
    
    return thunmbnail
}


