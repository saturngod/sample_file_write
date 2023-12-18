//
//  HomeViewModel.swift
//  FileManagerSample
//
//  Created by Htain Lin Shwe on 18/12/2023.
//

import UIKit

protocol HomeViewModelProtocol {
    func saveTheImage(name: String,type: String, image: UIImage, completion:@escaping ((_ success: Bool) -> Void))
    func loadTheImage(name: String, completion: @escaping ((_ image: UIImage?) -> Void))
}

final class HomeViewModel: HomeViewModelProtocol {
   
    private var fileManager = FileManager.default
    private var directoryURL : URL?
    private var directoryName : String
    
    init(directoryName: String = "tmpImages") {
        self.directoryName = directoryName
    }
    
    func saveTheImage(name: String, type: String, image: UIImage, completion: @escaping ((_ success: Bool) -> Void)) {

        DispatchQueue.global(qos: .userInteractive).async { [weak self] in

            guard let self = self else {
                completion(false)
                return
            }
            
            let created = self.directorySetup(name: self.directoryName)
            
            if (created == false) {
                completion(false)
            }
            
            guard let imageData = self.convertImageToData(image, type: type) else {
                completion(false)
                return
            }
            
            guard let directoryURL = self.directoryURL else {
                completion(false)
                return
            }
            
            let imageUrl = self.getImageUrl(directoryURL, name)
            let result = self.createFile(imageUrl, imageData)
            
            completion(result)
        }
    }
    
    func loadTheImage(name: String, completion: @escaping ((_ image: UIImage?) -> Void)) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            
            guard let self = self else {
                completion(nil)
                return
            }
            
            let created = self.directorySetup(name: self.directoryName)
            if (created == false) {
                completion(nil)
            }
            
            guard let directoryURL = self.directoryURL else {
                completion(nil)
                return
            }
            
            let imageUrl = self.getImageUrl(directoryURL, name)
            
            guard let fileData = self.getImageFile(imageUrl) else {
                completion(nil)
                return
            }
            
            let image = UIImage(data: fileData)
            completion(image)
        }
    }
    
    private func directorySetup(name: String) -> Bool {
        
        directoryURL =  fileManager.urls(for: .documentDirectory, in: .allDomainsMask).first?.appendingPathComponent(name)
        
        guard let directoryURL = directoryURL else {
            return false
        }
        
        let fileExist = fileManager.fileExists(atPath: directoryURL.path)
        if  !fileExist {
            createDirectory()
        }
        return true

    }
    
    private func createDirectory() {
        guard let directoryURL = directoryURL else {
            return
        }
        do {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        } catch {
            print("Error \(error.localizedDescription)")
        }
    }
    

    
}

extension HomeViewModel {
    private func convertImageToData(_ image:UIImage, type: String) -> Data? {
        switch type.lowercased() {
            case "png":
                return image.pngData()
            case "jpg", "jpeg":
                return image.jpegData(compressionQuality: 75)
            default:
                return nil
        }
    }
    
    private func getImageUrl(_ directoryURL: URL, _ name: String) -> URL {
        return directoryURL.appending(path: name)
    }
    
    private func createFile(_ imageUrl: URL,_ imageData: Data?) -> Bool {
        return fileManager.createFile(atPath: imageUrl.path, contents: imageData)
    }
    
    private func getImageFile(_ imageUrl: URL) -> Data? {
        return fileManager.contents(atPath: imageUrl.path)
    }
}
