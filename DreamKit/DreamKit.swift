//
//  DreamKit.swift
//  DreamKitDemo
//
//  Created by Chris Webb on 3/30/17.
//  Copyright © 2017 MuseWorks. All rights reserved.
//

import UIKit

public extension CGSize {
    public func scaledIn(size: CGSize, contentMode: DMKContentMode) -> CGSize {
        let scale = dmk_contentScaleForSizeInSize(self, size, contentMode)
        let size = CGSize(width: self.width * scale.width, height: self.height * scale.height)
        return size
    }
}

public extension CIImage {
    public func applyingOrientation(_ orientation: UIImageOrientation) -> CIImage {
        let exifOrientation = dmk_exifOrientationFromUIImageOrientation(orientation)
        return self.oriented(forExifOrientation: exifOrientation)
    }
    
    public func applyingRecipes(_ recipes: [DMKRecipe?]) -> CIImage {
        var workingImage = self
        
        for recipe in recipes {
            guard let recipe = recipe else { continue }
            guard let appliedImage = recipe.applyAdjustments(to: workingImage) else { continue }
            workingImage = appliedImage
        }
        
        return workingImage
    }
}
