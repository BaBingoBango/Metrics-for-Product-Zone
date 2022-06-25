//
//  GoalEditorView.swift
//  Metrics
//
//  Created by Ethan Marshall on 6/25/22.
//

import SwiftUI

struct GoalEditorView: View {
    
    // MARK: - View Variables
    /// The name of the goal this view should edit.
    var goalName: String
    /// The goal this view should edit.
    @Binding var goal: Int
    /// Whether or not a % sign should be displayed after the goal.
    var shouldShowPercent: Bool
    /// The accent color for the goal this view displays.
    var accentColor: Color {
        switch goalName {
        case "AppleCare+":
            return Color.red
        case "Business Leads":
            return Color("brown")
        case "Connectivity":
            return Color.blue
        default:
            return Color.primary
        }
    }
    /// The description text for the goal this view displays.
    var description: String {
        switch goalName {
        case "AppleCare+":
            return "eeeeee"
        case "Business Leads":
            return ""
        case "Connectivity":
            return ""
        default:
            return ""
        }
    }
    
    // MARK: - View Body
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: {
                        goal -= 1
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(accentColor)
                    }
                    
                    Text("\(goal)\(shouldShowPercent ? "%" : "")")
                        .font(.system(size: 70))
                        .fontWeight(.heavy)
                        .foregroundColor(.primary)
                    
                    Button(action: {
                        goal += 1
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(accentColor)
                    }
                }
                
                Text(description)
                
                Spacer()
            }
            
            // MARK: - Navigation View Settings
            .navigationTitle(Text("Daily \(goalName) Goal"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct GoalEditorView_Previews: PreviewProvider {
    static var previews: some View {
        GoalEditorView(goalName: "AppleCare+", goal: .constant(60), shouldShowPercent: true)
    }
}
