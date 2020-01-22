//
//  ContentView.swift
//  ImageSegmentation
//
//  Created by New User on 22/1/20.
//  Copyright © 2020 New User. All rights reserved.
//

import SwiftUI
import UIKit

struct MainView: View {
    @ObservedObject var segmenter = ImageSegmenter()
    @State var selectedImage = "0"

    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    ImageView(imageName: "1", selected: self.$selectedImage)
                    ImageView(imageName: "2", selected: self.$selectedImage)
                    ImageView(imageName: "3", selected: self.$selectedImage)
                    ImageView(imageName: "4", selected: self.$selectedImage)
                    ImageView(imageName: "5", selected: self.$selectedImage)
                    ImageView(imageName: "6", selected: self.$selectedImage)
                }
            }
            Button(
                action: {
                    self.segmenter.runModel(on: self.selectedImage)
                },
                label: {
                    Text("Run model").padding()
                }
            )

            Spacer()
            if self.$segmenter.outputImage.wrappedValue != nil {
                Image(uiImage: self.$segmenter.outputImage.wrappedValue!)
                    .frame(width: 250, height: 250)
            }
        }
    }
}

struct ImageView: View {
    var imageName: String
    @Binding var selected: String
    var body: some View {
        Image(uiImage: UIImage(named: imageName)!)
            .border(self.selected == imageName ? Color.blue : Color.clear, width: 3.0)
            .onTapGesture {
                self.selected = self.imageName
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
