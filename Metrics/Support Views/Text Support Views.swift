//
//  Text Support Views.swift
//  Metrics
//
//  Created by Ethan Marshall on 7/30/21.
//

import SwiftUI

// MARK: Small Heading Text
/// A text view given the `title3` font, the `bold` weight, and left-alignment with padding.
struct SmallHeadingText: View {
    
    // Variables
    var text: String
    
    var body: some View {
        
        HStack {
            Text(text)
                .font(.title3)
                .fontWeight(.bold)
            Spacer()
        }
        .padding(.leading)
        
    }
}
