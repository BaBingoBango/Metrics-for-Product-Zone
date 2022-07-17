//
//  ProgressBar.swift
//  Metrics
//
//  Created by Ethan Marshall on 8/3/21.
//

import SwiftUI

/// A circular progress indicator that can have a color and an SF symbol.
struct ProgressBar: View {
    
    // MARK: - View Variables
    /// The amount of progress this view represents.
    var progress: Double
    /// The color used in this view.
    var color: Color
    /// The width of this view's circle.
    var lineWidth: Double
    /// The name of an SF symbol to use in this view.
    var imageName: String
    
    // MARK: - View Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .stroke(lineWidth: CGFloat(lineWidth))
                    .opacity(0.3)
                    .foregroundColor(color)
                    .padding(.horizontal, lineWidth / 1.5)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: CGFloat(lineWidth), lineCap: .round, lineJoin: .round))
                    .foregroundColor(color)
                    .rotationEffect(Angle(degrees: 270.0))
                    .padding(.horizontal, lineWidth / 1.5)
                
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: geometry.size.height / 2.85)
            }
        }
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar(progress: 0.6, color: .red, lineWidth: 20.0, imageName: "iphone")
    }
}
