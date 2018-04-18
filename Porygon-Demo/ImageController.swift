//
//  ImageController.swift
//  Porygon-Demo
//
//  Created by Pavel Kozlov on 05/04/2018.
//  Copyright © 2018 DevinShine. All rights reserved.
//

import Foundation
import YPImagePicker

@objc protocol ImageGetDelegate {
    func imageDidGet(_ image: UIImage)
}


class ImageController: NSObject {
    let picker: YPImagePicker!
    weak var imageDidGetter: ImageGetDelegate?
    
    override init() {
        
        var config = YPImagePickerConfiguration()
        config.onlySquareImagesFromLibrary = false
        config.onlySquareImagesFromCamera = true
        config.showsFilters = true
        config.startOnScreen = .library
        config.showsCrop = .rectangle(ratio: (1/1))
//        config.wordings.libraryTitle = "Gallery"
//        config.hidesStatusBar = false
        // Build a picker with your configuration
        picker = YPImagePicker(configuration: config)
    }
    
    func showImages() -> YPImagePicker {
        picker.didSelectImage = { [weak self] img in
//            print(img.size)
            self?.imageDidGetter?.imageDidGet(img)
            self?.picker.dismiss(animated: true, completion: nil)
        }
        return picker
    }
    
    deinit {
        print("asdf")
    }
}
