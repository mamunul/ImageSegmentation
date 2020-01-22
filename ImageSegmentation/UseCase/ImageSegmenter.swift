//
//  ImageSegmenter.swift
//  ImageSegmentation
//
//  Created by New User on 22/1/20.
//  Copyright © 2020 New User. All rights reserved.
//

import Foundation
import UIKit

class ImageSegmenter {
    func runModel(on imageName: String) {
        guard let model = makeModel() else { return }

        var image = UIImage(named: imageName)

        image = scaleDown(image: image!, withSize: CGSize(width: 513, height: 513))

        let pixelBuffer = buffer(from: image!)

        do {
            let result = try model.prediction(image: pixelBuffer!)
            
            print(result.semanticPredictions)
        } catch {
            print(error)
        }
    }

    private func makeModel() -> DeepLabV3? {
        let modelURL = Bundle.main.url(forResource: "DeepLabV3", withExtension: "mlmodelc")
        do {
            let model = try DeepLabV3(contentsOf: modelURL!)
            return model
        } catch {
            print(error)
        }

        return nil
    }

    private func scaleDown(image: UIImage, withSize: CGSize) -> UIImage {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(withSize, false, scale)
        image.draw(in: CGRect(x: 0, y: 0, width: withSize.width, height: withSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }

    private func buffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue,
        ] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard status == kCVReturnSuccess else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }
}
