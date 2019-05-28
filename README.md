# PhotoLibrary
相册的处理--包含向相册添加视频或图片，添加或删除相册等

## // MARK: - 检查相册的权限
### func checkPhotoLibraryAuthorization(block: @escaping((Bool) -> ()))
## // MARK: - 判断指定名称的相册是否存在
### func isExistPhotoAlbum(albumName: String) -> Bool
## // MARK: - 创建相册
### func createPhotoAlbum(albumName: String)
## // MARK: - 向系统图库添加照片
### func addPictureToSystemPhotoAlbum(image: UIImage, resultBlock: @escaping((Bool,Error?) -> ()))
## // MARK: - 向自定义图库添加照片
### func addPictureToMyPhotoAlbum(image: UIImage, photoAlbumName: String, resultBlock: @escaping((Bool,Error?) -> ()))
    
![image](https://github.com/yangguang521/PhotoLibrary/blob/master/photo.png)
![image](https://github.com/yangguang521/PhotoLibrary/blob/master/photoalbum.png)
