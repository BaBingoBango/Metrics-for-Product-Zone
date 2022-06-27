//
//  GoalEditorView.swift
//  Metrics
//
//  Created by Ethan Marshall on 6/25/22.
//

import SwiftUI

/// A view which surfaces controls for editing one of the user's Daily Goals.
struct GoalEditorView: View {
    
    // MARK: - View Variables
    /// Whether or not this view is being presented.
    @SwiftUI.Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    /// The name of the goal this view should edit.
    var goalName: String
    /// The goal this view should edit.
    @Binding var goal: Int
    /// Whether or not a % sign should be displayed after the goal.
    var shouldShowPercent: Bool {
        switch goalName {
        case "AppleCare+":
            return true
        case "Business Leads":
            return false
        case "Connectivity":
            return true
        default:
            return false
        }
    }
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
            return "Attachment Rate"
        case "Business Leads":
            return "Leads"
        case "Connectivity":
            return "Connection Rate"
        default:
            return ""
        }
    }
    
    // MARK: - View Body
    var body: some View {
        let isLeftButtonDisabled = goal == 0
        let isRightButtonDisabled = goal == 100 && shouldShowPercent
        
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            goal -= 1
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(!isLeftButtonDisabled ? accentColor : .gray)
                        }
                        .disabled(isLeftButtonDisabled)
                        
                        Spacer()
                        
                        Text("\(goal)\(shouldShowPercent ? "%" : "")")
                            .font(.system(size: 50))
                            .fontWeight(.heavy)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                            .frame(width: geometry.size.width / 2.5, height: 75)
                        
                        Spacer()
                        
                        Button(action: {
                            goal += 1
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(!isRightButtonDisabled ? accentColor : .gray)
                        }
                        .disabled(isRightButtonDisabled)
                        
                        Spacer()
                    }
                    
                    Text(description)
                        .fontWeight(.bold)
                        .foregroundColor(accentColor)
                    
                    Spacer()
                }
            }
            
            // MARK: - Navigation View Settings
            .navigationTitle(Text("Daily \(goalName) Goal"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                            .fontWeight(.bold)
                            .foregroundColor(accentColor)
                    }
                }
            })
        }
    }
}

struct GoalEditorView_Previews: PreviewProvider {
    static var previews: some View {
        GoalEditorView(goalName: "AppleCare+", goal: .constant(99))
    }
}
