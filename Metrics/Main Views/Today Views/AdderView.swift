//
//  AdderView.swift
//  Metrics
//
//  Created by Ethan Marshall on 7/30/21.
//

import SwiftUI

/// The view which surfaces controls for adding a new transaction to the Core Data database.
struct AdderView: View {
    // MARK: - View Variables
    // Modal variable
    @SwiftUI.Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    // Core Data variable
    @Environment(\.managedObjectContext) private var viewContext
    
    // Transaction Variables
    @State var deviceType = "No Device"
    @State var boughtAppleCare = false
    @State var isAppleCareStandalone = false
    @State var gotLead = false
    @State var connected = false
    
    // MARK: - View Body
    var body: some View {
        NavigationView {
            
            ScrollView {
                VStack {
                    
                    // MARK: Device Sold Selection
                    SmallHeadingText(text: "Device Type")
                        .padding(.top, 20)
                    HStack {
                        DevicePurchasedOption(deviceType: $deviceType, imageName: "iphone", deviceTypeName: "iPhone")
                        DevicePurchasedOption(deviceType: $deviceType, imageName: "ipad.landscape", deviceTypeName: "iPad")
                        DevicePurchasedOption(deviceType: $deviceType, imageName: "desktopcomputer", deviceTypeName: "Mac")
                    }
                    .padding(.horizontal)
                    HStack {
                        DevicePurchasedOption(deviceType: $deviceType, imageName: "applewatch", deviceTypeName: "Apple Watch")
                        DevicePurchasedOption(deviceType: $deviceType, imageName: "appletv", deviceTypeName: "Apple TV")
                        DevicePurchasedOption(deviceType: $deviceType, imageName: "headphones", deviceTypeName: "Headphones")
                    }
                    .padding(.horizontal)
                    
                    // MARK: Additions Selection
                    SmallHeadingText(text: "Additions")
                        .padding(.top)
                    HStack {
                        if deviceType != "No Device" {
                            AdditionsOption(buttonState: $boughtAppleCare, standaloneState: $isAppleCareStandalone, text: "AppleCare+", imageName: "applelogo", color: .red)
                        }
                        AdditionsOption(buttonState: $gotLead, standaloneState: $isAppleCareStandalone, text: "Business Lead", imageName: "briefcase.fill", color: .brown)
                        if deviceType == "iPhone" {
                            AdditionsOption(buttonState: $connected, standaloneState: $isAppleCareStandalone, text: "Connected", imageName: "antenna.radiowaves.left.and.right", color: .blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Tap the AppleCare+ button twice to record standalone AppleCare+!")
                            .foregroundColor(.secondary)
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                        .padding(.horizontal)
                    
                    Spacer()
                    
                }
                .padding(.bottom)
            }
            
            // MARK: Nav Bar Settings
            .navigationBarTitle("Log Transaction", displayMode: .inline)
            .navigationBarItems(leading: Button(action: { self.presentationMode.wrappedValue.dismiss() }) { Text("Cancel").fontWeight(.regular) }, trailing: Button(action: {
                
                // Add the new transaction and dismiss the modal
                let newTransaction = Transaction(context: viewContext)
                newTransaction.id = UUID()
                newTransaction.date = Date()
                newTransaction.deviceType = deviceType
                newTransaction.boughtAppleCare = boughtAppleCare
                newTransaction.connected = connected
                newTransaction.gotLead = gotLead
                newTransaction.isAppleCareStandalone = isAppleCareStandalone
                do {
                    try viewContext.save()
                    print("Transaction saved!")
                } catch {
                    print(error.localizedDescription)
                }
                self.presentationMode.wrappedValue.dismiss()
                
            }) { Text("Save").fontWeight(.bold) })
            
        }
    }
}

struct AdderView_Previews: PreviewProvider {
    static var previews: some View {
        AdderView()
    }
}

/// A button representing a type of device that can be involved in a transaction.
struct DevicePurchasedOption: View {
    
    // State Pass-In
    @Binding var deviceType: String
    
    // Variables
    var imageName: String
    var deviceTypeName: String
    
    // Computed Properties
    var buttonSelected: Bool {
        return deviceType == deviceTypeName
    }
    
    var body: some View {
        
        Button(action: {
            
            if !buttonSelected {
                deviceType = deviceTypeName
            } else {
                deviceType = "No Device"
            }
            
        }) {
            ZStack {
                
                Rectangle()
                    .foregroundColor(buttonSelected ? .green : .gray)
                    .opacity(buttonSelected ? 1.0 : 0.5)
                    .cornerRadius(10)
                    .frame(height: 100)
                
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(buttonSelected ? .white : .black)
                    .frame(height: 45)
                
            }
        }
        
    }
}

/// A button representing an option for a transaction addition.
struct AdditionsOption: View {
    
    // State Pass-In
    @Binding var buttonState: Bool
    @Binding var standaloneState: Bool
    
    // Variables
    var text: String
    var imageName: String
    var color: Color
    
    // Computed Properties
    var isAppleCareButton: Bool {
        return text == "AppleCare+"
    }
    
    var body: some View {
        
        Button(action: {
            
            if !isAppleCareButton {
                
                buttonState.toggle()
                
            } else {
                
                if buttonState == false {
                    
                    buttonState = true
                    
                } else if buttonState == true && standaloneState == true {
                    
                    buttonState = false
                    standaloneState = false
                    
                } else if buttonState == true && standaloneState == false {
                    
                    standaloneState = true
                    
                }
                
            }
            
        }) {
            ZStack {
                
                Rectangle()
                    .foregroundColor(buttonState ? (standaloneState && isAppleCareButton ? .gold : color) : .gray)
                    .opacity(buttonState ? 1.0 : 0.5)
                    .cornerRadius(10)
                    .frame(height: 175)
                
                VStack {
                    
                    Image(systemName: imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                        .foregroundColor(buttonState ? .white : .black)
                    
                    Text(text)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top, 7.5)
                        .foregroundColor(buttonState ? .white : .black)
                        .padding(.horizontal, 5)
                        .lineLimit(text != "Business Lead" ? 1 : 2)
                        .minimumScaleFactor(0.1)
                    
                }
                
            }
        }
        
    }
}
