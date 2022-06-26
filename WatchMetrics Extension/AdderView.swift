//
//  AdderView.swift
//  WatchMetrics Extension
//
//  Created by Ethan Marshall on 8/14/21.
//

import SwiftUI

struct AdderView: View {
    
    // State variable
    @State private var tabSelection = 1
    
    // Modal variable
    @SwiftUI.Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    // Core Data variable
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: Transaction Variables
    @State var deviceType = "No Device"
    @State var boughtAppleCare = false
    @State var isAppleCareStandalone = false
    @State var gotLead = false
    @State var connected = false
    
    var body: some View {
        NavigationView {
            TabView(selection: $tabSelection) {
                VStack {
                    HStack {
                        WatchDevicePurchasedOption(deviceType: $deviceType, tabSelection: $tabSelection, imageName: "iphone", deviceTypeName: "iPhone")
                        WatchDevicePurchasedOption(deviceType: $deviceType, tabSelection: $tabSelection, imageName: "ipad.landscape", deviceTypeName: "iPad")
                        WatchDevicePurchasedOption(deviceType: $deviceType, tabSelection: $tabSelection, imageName: "desktopcomputer", deviceTypeName: "Mac")
                    }
                    HStack {
                        WatchDevicePurchasedOption(deviceType: $deviceType, tabSelection: $tabSelection, imageName: "applewatch", deviceTypeName: "Apple Watch")
                        WatchDevicePurchasedOption(deviceType: $deviceType, tabSelection: $tabSelection, imageName: "appletv", deviceTypeName: "Apple TV")
                        WatchDevicePurchasedOption(deviceType: $deviceType, tabSelection: $tabSelection, imageName: "headphones", deviceTypeName: "Headphones")
                    }
                }
                .tag(1)
                
                ScrollView {
                    VStack {
                        if deviceType != "No Device" {
                            WatchAdditionsOption(buttonState: $boughtAppleCare, standaloneState: $isAppleCareStandalone, text: "AppleCare+", imageName: "applelogo", color: .red)
                        }
                        WatchAdditionsOption(buttonState: $gotLead, standaloneState: $isAppleCareStandalone, text: "Business Lead", imageName: "briefcase.fill", color: Color("brown"))
                        if deviceType == "iPhone" {
                            WatchAdditionsOption(buttonState: $connected, standaloneState: $isAppleCareStandalone, text: "Connected", imageName: "antenna.radiowaves.left.and.right", color: .blue)
                        }
                        Spacer()
                        Button(action: {
                            
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
                            
                        }) {
                            ZStack {
                                
                                Rectangle()
                                    .frame(height: 40)
                                    .cornerRadius(10)
                                    .foregroundColor(.green)
                                
                                Text("Save")
                                
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .tag(2)
                
            }
            .tabViewStyle(PageTabViewStyle())
            
            // MARK: Nav Bar Settings
        }
        
    }
}

struct AdderView_Previews: PreviewProvider {
    static var previews: some View {
        AdderView()
    }
}

struct WatchDevicePurchasedOption: View {
    
    // State Pass-Ins
    @Binding var deviceType: String
    @Binding var tabSelection: Int
    
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
            
            // Progress the tab view to the second screen
            tabSelection = 2
            
        }) {
            ZStack {
                
                Rectangle()
                    .foregroundColor(buttonSelected ? .green : .gray)
                    .opacity(buttonSelected ? 1.0 : 0.85)
                    .cornerRadius(10)
//                    .frame(height: 60)
                
                Image(systemName: imageName)
                    .imageScale(.large)
//                    .resizable()
//                    .scaledToFit()
                    .foregroundColor(buttonSelected ? .white : .black)
//                    .frame(height: 45)
                
            }
        }
        .buttonStyle(PlainButtonStyle())
        
    }
}

struct WatchAdditionsOption: View {
    
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
                    .opacity(buttonState ? 1.0 : 0.85)
                    .cornerRadius(10)
                    .frame(height: 40)
                
                HStack {
                    
                    Image(systemName: imageName)
                        .foregroundColor(buttonState ? .white : .black)
                    
                    Text(text)
                        .multilineTextAlignment(.center)
                        .foregroundColor(buttonState ? .white : .black)
                    
                }
                
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
