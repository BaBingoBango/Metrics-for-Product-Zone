//
//  ComplicationViews.swift
//  WatchMetrics Extension
//
//  Created by Ethan Marshall on 8/14/21.
//

import SwiftUI
import ClockKit

struct ComplicationViews: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ComplicationViewCircular: View {

  var body: some View {
    
    ZStack {
        Circle()
            .opacity(0.2)
        
        Image(systemName: "chart.bar.fill")
            .imageScale(.large)
            .foregroundColor(.green)
    }
    
  }
}

struct ComplicationViews_Previews: PreviewProvider {
    static var previews: some View {
        Group {
          CLKComplicationTemplateGraphicCircularView(
            ComplicationViewCircular()
          ).previewContext()
        }
    }
}
