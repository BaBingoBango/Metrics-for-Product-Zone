//
//  ergiwywfqe.swift
//  Metrics
//
//  Created by Ethan Marshall on 7/4/22.
//

import SwiftUI

struct ergiwywfqe: View {
    var body: some View {
        VStack {
            HStack {
                Image("sharing image")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .hidden()
                
                Image("sharing image")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .scaleEffect(0.8)
                
                Image("sharing image")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .hidden()
            }
            
            Text("Accepting Shared Data")
                .fontWeight(.bold)
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.1)
                .padding([.leading, .bottom, .trailing])
            
            ProgressView()
                .scaleEffect(1.5)
            
            Spacer()
        }
        .padding(.top)
    }
}

struct ergiwywfqe_Previews: PreviewProvider {
    static var previews: some View {
        ergiwywfqe()
    }
}
