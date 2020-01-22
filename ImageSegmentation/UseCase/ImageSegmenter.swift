//
//  ImageSegmenter.swift
//  ImageSegmentation
//
//  Created by New User on 22/1/20.
//  Copyright © 2020 New User. All rights reserved.
//

import CoreML
import Foundation
import SwiftUI
import UIKit

class ImageSegmenter: ObservableObject {
    @Published var outputImage: UIImage?
    func runModel(on imageName: String) {
        guard let model = makeModel() else { return }

        var image = UIImage(named: imageName)

        image = image?.resized(to: CGSize(width: 513, height: 513))

        if image == nil { return }

        let pixelBuffer = image?.pixelBuffer(width: Int((image?.size.width)!), height: Int((image?.size.height)!))

        do {
            let result = try model.prediction(image: pixelBuffer!)
            previewResult(semanticPredictions: result.semanticPredictions)
        } catch {
            print(error)
        }
    }

    private func previewResult(semanticPredictions: MLMultiArray) {
        outputImage = semanticPredictions.image()
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
}
