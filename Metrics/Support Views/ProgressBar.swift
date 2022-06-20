//
//  ProgressBar.swift
//  Metrics
//
//  Created by Ethan Marshall on 8/3/21.
//

import SwiftUI

struct ProgressBar: View {
    
    // Variables
    var progress: Double
    var color: Color
    var lineWidth: Double
    var imageName: String
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: CGFloat(lineWidth))
                .opacity(0.3)
                .foregroundColor(color)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: CGFloat(lineWidth), lineCap: .round, lineJoin: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270.0))
            
            Image(systemName: imageName)
                .imageScale(.large)
        }
        .padding(.horizontal)
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar(progress: 0.6, color: .red, lineWidth: 20.0, imageName: "iphone")
    }
}
