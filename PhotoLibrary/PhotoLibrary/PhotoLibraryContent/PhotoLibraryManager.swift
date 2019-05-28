//
//  PhotoLibraryManager.swift
//  PhotoLibrary
//
//  Created by Joe on 2019/5/24.
//  Copyright © 2019年 tony. All rights reserved.
//

import UIKit
import Photos
import AssetsLibrary


class PhotoLibraryManager: NSObject {
    
    static let shared = PhotoLibraryManager()
    private override init() {
        print("PhotoLibraryManager init!")
    }
    
    // MARK: - 检查相册的权限
    func checkPhotoLibraryAuthorization(block: @escaping((Bool) -> ())) {
        // 先判断是否创建过albumName的相册
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized {
                    block(true)
                }else {
                    block(false)
                }
            }
        case .authorized:
            block(true)
        case .denied:
            block(false)
        case .restricted:
            block(false)
        default:
            block(false)
        }
    }
    
    // MARK: - 判断指定名称的相册是否存在
    func isExistPhotoAlbum(albumName: String) -> Bool {
        // 先判断是否有图库权限
        let collections: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        var isExistCollection = false
        collections.enumerateObjects { (assetCollection, index, stop) in
            if assetCollection.localizedTitle == albumName {
                isExistCollection = true
            }
        }
        return isExistCollection
    }
    
    // MARK: - 创建相册
    func createPhotoAlbum(albumName: String) {
        // 先判断是否创建过albumName的相册
        let isExistCollection = self.isExistPhotoAlbum(albumName: albumName)
        if isExistCollection {
            print("已经存在\(albumName)相册")
        }else {
            var createdCollectionId = ""
            PHPhotoLibrary.shared().performChanges({
                createdCollectionId = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName).placeholderForCreatedAssetCollection.localIdentifier
            }, completionHandler: { (isSuccess, error) in
                print("创建的\(albumName)相册id=\(createdCollectionId)")
                print("创建的\(albumName)相册-%d",isSuccess ? "成功":"失败")
            })
        }
    }
    
    // MARK: - 向系统图库添加照片
    func addPictureToSystemPhotoAlbum(image: UIImage, resultBlock: @escaping((Bool,Error?) -> ())) {
        var systemAssetId: String? = nil
        PHPhotoLibrary.shared().performChanges({
            // 异步执行保存图片 添加图片到相机胶卷
            systemAssetId = PHAssetChangeRequest.creationRequestForAsset(from: image).placeholderForCreatedAsset?.localIdentifier
        }) { (isSuccess, error) in
            print("添加到系统相册的图片id=\(systemAssetId ?? "")")
            resultBlock(isSuccess,error)
        }
    }
    
    // MARK: - 向自定义图库添加照片
    func addPictureToMyPhotoAlbum(image: UIImage, photoAlbumName: String, resultBlock: @escaping((Bool,Error?) -> ())) {
        var systemAssetId: String? = nil
        var createAssetId: String? = nil
        self.createPhotoAlbum(albumName: photoAlbumName)
        let getCollection = self.getPhotoAlbum(albumName: photoAlbumName)
        PHPhotoLibrary.shared().performChanges({
            // 异步执行保存图片 添加图片到相机胶卷
            systemAssetId = PHAssetChangeRequest.creationRequestForAsset(from: image).placeholderForCreatedAsset?.localIdentifier
        }) { (isSuccess, error) in
            print("添加到系统相册的图片id=\(systemAssetId ?? "")")
            PHPhotoLibrary.shared().performChanges({
                //添加到自定义相册
                if let collection = getCollection {
                    let collectionChangeRequest = PHAssetCollectionChangeRequest.init(for: collection)
                    let asset = PHAsset.fetchAssets(withLocalIdentifiers: [systemAssetId ?? ""], options: nil)
                    createAssetId = asset.lastObject?.localIdentifier
                    collectionChangeRequest?.addAssets(asset)
                }
            }) { (isSuccess, error) in
                print("添加到\(photoAlbumName)相册的图片id=\(createAssetId ?? "")")
                resultBlock(isSuccess,error)
            }
        }
    }
    
    // MARK: - 获得自定义图库
    private func getPhotoAlbum(albumName: String) -> PHAssetCollection? {
        let isExistCollection = self.isExistPhotoAlbum(albumName: albumName)
        if isExistCollection {
            var getCollection: PHAssetCollection? = nil
            let collections: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
            collections.enumerateObjects { (assetCollection, index, stop) in
                if assetCollection.localizedTitle == albumName {
                    getCollection = assetCollection
                }
            }
            return getCollection
        }
        return nil
    }
    
}
