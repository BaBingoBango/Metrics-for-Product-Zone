//
//  TodayTabView.swift
//  Metrics
//
//  Created by Ethan Marshall on 6/20/22.
//

import SwiftUI

struct TodayTabView: View {
    
    // MARK: View Variables
    /// Whether or not the transaction adder view is being presented.
    @State var showingAdderView = false
    /// The complete list of the user's transactions, fetched from Core Data.
    @FetchRequest(entity: Transaction.entity(), sortDescriptors: []) var transactions: FetchedResults<Transaction>
    /// A `TransactionServices` object used to interact with all of the user's transactions.
    var data: TransactionServices {
        return TransactionServices(transactions.reversed().reversed())
    }
    /// A `TransactionServices` object used to interact with all of the user's transactions from the current day.
    var todayData: TransactionServices {
        return TransactionServices(data.today())
    }
    /// A date formatter which provides date strings suitable for the Today view UI's heading.
    var todayViewDateFormatter: DateFormatter {
        let answer = DateFormatter()
        answer.dateStyle = .full
        answer.timeStyle = .none
        return answer
    }
    
    // Daily Goals variables
    /// Whether or not the user's daily goals should show in the Today view.
    @AppStorage("showGoalsInTodayView") var showGoalsInTodayView = true
    /// In percent, the user's daily AppleCare+ goal.
    @AppStorage("appleCareGoal") var appleCareGoal = 60
    /// The users daily business lead goal.
    @AppStorage("businessLeadsGoal") var businessLeadsGoal = 2
    /// In percent, the user's daily connectivity goal.
    @AppStorage("connectivityGoal") var connectivityGoal = 75
    
    // MARK: View Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        Text(todayViewDateFormatter.string(from: Date()).uppercased())
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .padding(.leading)
                        Spacer()
                    }
                    
                    Text("Good \(getGenericTimeDescription())!")
                        .font(.title)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)
                        .truncationMode(.middle)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .padding(.bottom, showGoalsInTodayView ? 0 : 15)

                    if showGoalsInTodayView {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .hidden()

                            if todayData.appleCarePercent() < appleCareGoal {
                                ProgressBar(progress: Double(todayData.appleCarePercent()) / 100.0, color: .red, lineWidth: 8.5, imageName: "")
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fit)
                                    .foregroundColor(.green)
                                    .padding(2.5)
                            }
                            
                            if todayData.numBusinessLeads() < businessLeadsGoal {
                                ProgressBar(progress: Double(todayData.numBusinessLeads()) / Double(businessLeadsGoal), color: Color("brown"), lineWidth: 8.5, imageName: "")
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fit)
                                    .foregroundColor(.green)
                                    .padding(2.5)
                            }
                            
                            if todayData.connectivityPercent() < connectivityGoal {
                                ProgressBar(progress: Double(todayData.connectivityPercent()) / 100.0, color: .blue, lineWidth: 8.5, imageName: "")
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fit)
                                    .foregroundColor(.green)
                                    .padding(2.5)
                            }

                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .hidden()
                        }
                        .padding(.bottom, 10)

                        Text("\(getDayOfWeekDescription()) \(getGoalProgressDescription())")
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .padding([.leading, .bottom, .trailing])
                        
                    }
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(.gray)
                            .opacity(0.15)
                            .cornerRadius(20)
                        
                        VStack {
                            HStack {
                                Image(systemName: "applelogo")
                                    .imageScale(.large)
                                    .foregroundColor(.red)
                                
                                Text("AppleCare+")
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                                Spacer()
                                
                                Text("\(todayData.appleCarePercent())%")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                            }
                            .padding([.top, .leading, .trailing])
                            
                            HStack(spacing: 0) {
                                
                                ProgressBar(progress: Double(todayData.customAppleCarePercent("iPhone")) / 100, color: .red, lineWidth: 8.5, imageName: "iphone")
                                    .aspectRatio(1, contentMode: .fit)
                                
                                Spacer()
                                
                                ProgressBar(progress: Double(todayData.customAppleCarePercent("iPad")) / 100, color: .red, lineWidth: 8.5, imageName: "ipad.landscape")
                                    .aspectRatio(1, contentMode: .fit)
                                
                                Spacer()
                                
                                ProgressBar(progress: Double(todayData.customAppleCarePercent("Mac")) / 100, color: .red, lineWidth: 8.5, imageName: "desktopcomputer")
                                    .aspectRatio(1, contentMode: .fit)
                            }
                            .padding(.horizontal)
                            
                            HStack(spacing: 0) {
                                ProgressBar(progress: Double(todayData.customAppleCarePercent("Apple Watch")) / 100, color: .red, lineWidth: 8.5, imageName: "applewatch")
                                    .aspectRatio(1, contentMode: .fit)
                                
                                Spacer()
                                
                                ProgressBar(progress: Double(todayData.customAppleCarePercent("Apple TV")) / 100, color: .red, lineWidth: 8.5, imageName: "appletv")
                                    .aspectRatio(1, contentMode: .fit)
                                
                                Spacer()
                                
                                ProgressBar(progress: Double(todayData.customAppleCarePercent("Headphones")) / 100, color: .red, lineWidth: 8.5, imageName: "headphones")
                                    .aspectRatio(1, contentMode: .fit)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.gray)
                                .opacity(0.15)
                                .cornerRadius(20)
                            
                            HStack {
                                VStack {
                                    HStack(alignment: .center) {
                                        Image(systemName: "briefcase.fill")
                                            .imageScale(.large)
                                            .foregroundColor(Color("brown"))
                                        
                                        Text("Leads")
                                            .fontWeight(.bold)
                                            .foregroundColor(Color("brown"))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.1)
                                    }
                                    .padding(.top)
                                    .padding(.horizontal, 5)
                                    
                                    ZStack {
                                        ProgressBar(progress: 0.0, color: Color("brown"), lineWidth: 8.5, imageName: "")
                                            .aspectRatio(1, contentMode: .fit)
                                        
                                        Text("\(todayData.numBusinessLeads())")
                                            .font(.system(size: 30))
                                            .fontWeight(.bold)
                                            .foregroundColor(Color("brown"))
                                    }
                                    .padding(.bottom)
                                }
                            }
                        }
                        .aspectRatio(1, contentMode: .fit)
                        
                        
                        ZStack {
                            Rectangle()
                                .foregroundColor(.gray)
                                .opacity(0.15)
                                .cornerRadius(20)
                            
                            HStack {
                                VStack {
                                    HStack(alignment: .center) {
                                        Image(systemName: "antenna.radiowaves.left.and.right")
                                            .imageScale(.large)
                                            .foregroundColor(.blue)
                                        
                                        Text("Connected")
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.1)
                                    }
                                    .padding(.top)
                                    .padding(.horizontal, 5)
                                    
                                    ZStack {
                                        ProgressBar(progress: Double(todayData.connectivityPercent()) / 100, color: .blue, lineWidth: 8.5, imageName: "")
                                            .aspectRatio(1, contentMode: .fit)
                                        
                                        Text("\(todayData.connectivityPercent())%")
                                            .font(.body)
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                    }
                                    .padding(.bottom)
                                }
                            }
                        }
                        .aspectRatio(1, contentMode: .fit)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Sharing")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding([.top, .leading])
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(.gray)
                            .opacity(0.15)
                            .cornerRadius(20)
                        
                        VStack {
                            HStack {
                                Image(systemName: "person.crop.circle")
                                    .font(.title)
                                    .imageScale(.large)
                                
                                Text("Elizabeth Lemon")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                Spacer()
                            }
                            .padding([.top, .leading])
                            
                            HStack {
                                ProgressBar(progress: 0, color: .red, lineWidth: 8.5, imageName: "applelogo")
                                    .aspectRatio(1, contentMode: .fit)
                                
                                Spacer()
                                
                                ProgressBar(progress: 0, color: Color("brown"), lineWidth: 8.5, imageName: "briefcase.fill")
                                    .aspectRatio(1, contentMode: .fit)
                                
                                Spacer()
                                
                                ProgressBar(progress: 0, color: .blue, lineWidth: 8.5, imageName: "antenna.radiowaves.left.and.right")
                                    .aspectRatio(1, contentMode: .fit)
                            }
                            .padding([.leading, .bottom, .trailing])
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            
            // MARK: Navigation View Settings
            .navigationTitle(Text("Today"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAdderView.toggle()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .sheet(isPresented: $showingAdderView) {
                        AdderView()
                    }
                }
            }
        }
    }
    
    // MARK: - View Functions
    /// Uses the current time to generate a generic word that describes the current part of the day.
    func getGenericTimeDescription() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let militaryTime = dateFormatter.string(from: Date())
        let hour = Int(militaryTime.components(separatedBy: ":")[0])!
        
        if hour >= 22 {
            // 9 PM - 11:59 PM
            return "evening"
        } else if hour >= 12 {
            // Noon - 9 PM
            return "afternoon"
        } else if hour >= 6 {
            // 6 AM - 11:59 AM
            return "morning"
        } else {
            // Midnight - 5:59 AM
            return "evening"
        }
    }
    /// Returns a short exclamatory string about the current day of the week.
    func getDayOfWeekDescription() -> String {
        if Date().dayOfWeek() == nil {
            return "Hello!"
        } else {
            switch Date().dayOfWeek()! {
            case "Monday":
                return [
                    "Happy Monday!",
                    "It's another week!",
                    "It's Monday..."
                ].randomElement()!
            case "Tuesday":
                return [
                    "Happy Tuesday!",
                    "Happy 2's day!",
                    "Happy not Monday!"
                ].randomElement()!
            case "Wednesday":
                return [
                    "Happy Wednesday!",
                    "Happy hump day!",
                    "Happy mid-week!"
                ].randomElement()!
            case "Thursday":
                return [
                    "Happy Thursday!",
                    "It's Thursday almost Friday!"
                ].randomElement()!
            case "Friday":
                return [
                    "Happy Friday!",
                    "TGIF!",
                    "It's Friday!!"
                ].randomElement()!
            case "Saturday":
                return [
                    "Happy Saturday!",
                    "Happy weekend!",
                    "It's the weekend!"
                ].randomElement()!
            case "Sunday":
                return [
                    "Happy Sunday!",
                    "Sunday funday!"
                ].randomElement()!
            default:
                return "Hello!"
            }
        }
    }
    /// Returns a string describing the user's progress on their Daily Goals.
    func getGoalProgressDescription() -> String {
        var goalsClear = 0
        if todayData.appleCarePercent() >= appleCareGoal { goalsClear += 1 }
        if todayData.numBusinessLeads() >= businessLeadsGoal { goalsClear += 1 }
        if todayData.connectivityPercent() >= connectivityGoal { goalsClear += 1 }
        
        switch goalsClear {
        case 0:
            return "It's a great time to get started on your goals! You can do it!"
        case 1:
            return "One down, two to go! Keep going, you got this!"
        case 2:
            return "You only have one goal to go! You're almost there!"
        case 3:
            return "All your goals are green right now! Great job, you did it!"
        default:
            return ""
        }
    }
}

// MARK: View Preview
struct TodayTabView_Previews: PreviewProvider {
    static var previews: some View {
        TodayTabView()
    }
}
