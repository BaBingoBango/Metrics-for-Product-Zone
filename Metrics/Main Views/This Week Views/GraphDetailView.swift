//
//  GraphDetailView.swift
//  Metrics
//
//  Created by Ethan Marshall on 8/5/21.
//

import SwiftUI

/// A view showing a detailed and customizable graph for a certain metric.
struct GraphDetailView: View {
    // MARK: - View Variables
    // Modal variable
    @SwiftUI.Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    // Time picker variables
    var dateChoices = ["Weekly", "Monthly", "Yearly"]
    @State private var selectedDateChoice = "Weekly"
    
    // TransactionServices objects
    var data: TransactionServices
    
    /// The name of the metric that this graph view displays the data for.
    var stat: String
    
    /// These represent how far back the user is looking. A value of 0 means that the user is viewing the current week, or the current month, or the current year. These values will be used in the jump functions.
    @State var weeklyOffset: Int = 0
    @State var monthlyOffset: Int = 0
    @State var yearlyOffset: Int = 0
    
    // MARK: - View Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Picker("", selection: $selectedDateChoice) {
                        ForEach(dateChoices, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding([.top, .leading, .trailing])
                    
                    HStack {
                        Button(action: {
                            processLeft()
                        }) {
                            ChevronButton(direction: "left", color: getStatColor())
                        }
                        Spacer()
                        Text(getDateText())
                        Spacer()
                        Button(action: {
                            processRight()
                        }) {
                            ChevronButton(direction: "right", color: getStatColor())
                        }
                    }
                    .padding([.top, .leading, .trailing])
                    
                    let graphData = generateGraphData()
                    
                    BarGraphRow(labels: getLabelText(), percents: [graphData[0], graphData[1], graphData[2], graphData[3], graphData[4], graphData[5], graphData[6]], color: getStatColor())
                        .frame(height: 260)
                    
                    // Extra stats section
                    ZStack {
                        
                        Rectangle()
                            .foregroundColor(.gray)
                            .opacity(0.2)
                            .edgesIgnoringSafeArea(.bottom)
                        
                        VStack {
                            
                            HStack {
                                Text("Highlights")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.leading)
                                Spacer()
                            }
                            
                            if stat == "AppleCare+" {
                                
                                HStack {
                                    Spacer()
                                    ColorTextWithCaption(color: .red, number: String(Int(graphData[7])), caption: "AppleCare+ \(Int(graphData[7]) == 1 ? "Unit" : "Units")")
                                    Spacer()
                                    ColorTextWithCaption(color: .red, number: String(Int(graphData[8])), caption: "Total \(Int(graphData[8]) == 1 ? "Device" : "Devices")")
                                    Spacer()
                                }
                                .padding(.top)
                                ColorTextWithCaption(color: .red, number: String(Int(graphData[9])) + "%", caption: "Total Attach Rate")
                                .padding(.top)
                                
                            } else if stat == "Business Leads" {
                                
                                HStack {
                                    Spacer()
                                    ColorTextWithCaption(color: Color("brown"), number: String(Int(graphData[7])), caption: "Total \(Int(graphData[7]) == 1 ? "Lead" : "Leads")")
                                    Spacer()
                                    ColorTextWithCaption(color: Color("brown"), number: String(Int(graphData[7])), caption: "Average Per Day")
                                    Spacer()
                                }
                                .padding(.top)
                                
                            } else {
                                
                                HStack {
                                    Spacer()
                                    ColorTextWithCaption(color: .blue, number: String(Int(graphData[7])), caption: "Connected \(Int(graphData[7]) == 1 ? "Device" : "Devices")")
                                    Spacer()
                                    ColorTextWithCaption(color: .blue, number: String(Int(graphData[8])), caption: "Total \(Int(graphData[8]) == 1 ? "Device" : "Devices")")
                                    Spacer()
                                }
                                .padding(.top)
                                ColorTextWithCaption(color: .blue, number: String(Int(graphData[9])) + "%", caption: "Total Connectivity Rate")
                                .padding(.top)
                                
                            }
                            
                            Spacer()
                            
                        }
                        .edgesIgnoringSafeArea(.bottom)
                        .padding(.vertical)
                        
                    }
                    .padding(.top)
                    .edgesIgnoringSafeArea(.bottom)
                    
//                    Spacer()
                    
                }
                .edgesIgnoringSafeArea(.bottom)
                
                // MARK: Nav Bar Settings
                .navigationBarTitle(Text(stat), displayMode: .inline)
                .navigationBarItems(trailing: Button(action: { self.presentationMode.wrappedValue.dismiss() }) { Text("Done").fontWeight(.bold) })
            }
            
        }
        
    }
    
    // MARK: Functions
    func getStatColor() -> Color {
        if stat == "AppleCare+" {
            return .red
        } else if stat == "Business Leads" {
            return Color("brown")
        } else {
            return .blue // (Connectivity)
        }
    }
    
    func getDateText() -> String {
        if selectedDateChoice == "Weekly" {
            if weeklyOffset == 0 {
                return "This Week"
            } else if weeklyOffset == 1 {
                return "1 Week Ago"
            } else {
                return "\(weeklyOffset) Weeks Ago"
            }
        } else if selectedDateChoice == "Monthly" {
            return "\(monthlyOffset * 7) - \((monthlyOffset * 7) + 6) Weeks Ago"
        } else {
            return "\(yearlyOffset * 7) - \((yearlyOffset * 7) + 6) Months Ago"
        }
    }
    
    func getLabelText() -> [String] {
        if selectedDateChoice == "Weekly" {
            return ["S", "M", "T", "W", "T", "F", "S"]
        } else if selectedDateChoice == "Monthly" {
            return [String((monthlyOffset * 7) + 6) + "w", String((monthlyOffset * 7) + 5) + "w", String((monthlyOffset * 7) + 4) + "w", String((monthlyOffset * 7) + 3) + "w", String((monthlyOffset * 7) + 2) + "w", String((monthlyOffset * 7) + 1) + "w", String((monthlyOffset * 7)) + "w"]
        } else {
            return [String((yearlyOffset * 7) + 6) + "m", String((yearlyOffset * 7) + 5) + "m", String((yearlyOffset * 7) + 4) + "m", String((yearlyOffset * 7) + 3) + "m", String((yearlyOffset * 7) + 2) + "m", String((yearlyOffset * 7) + 1) + "m", String((yearlyOffset * 7)) + "m"]
        }
    }
    
    func processRight() {
        if selectedDateChoice == "Weekly" {
            if weeklyOffset != 0 {
                weeklyOffset -= 1
            }
        } else if selectedDateChoice == "Monthly" {
            if monthlyOffset != 0 {
                monthlyOffset -= 1
            }
        } else {
            if yearlyOffset != 0 {
                yearlyOffset -= 1
            }
        }
    }
    
    func processLeft() {
        if selectedDateChoice == "Weekly" {
            weeklyOffset += 1
        } else if selectedDateChoice == "Monthly" {
            monthlyOffset += 1
        } else {
            yearlyOffset += 1
        }
    }
    
    /// This function takes in the date choice (weekly, monthly, or yearly), as well as the transactions (from data) and the offset value. From this, the function returns the seven correct graph heights to display. It will also return information about the data to be displayed under the graph (see key below).
    /// KEY FOR GRAPH DATA ARRAY:
    /// 0-6: Graph height values
    /// [AppleCare] 7: AC+ Units | 8: Total Devices | 9: Total %
    /// [Business Leads] 7: Total Leads | 8: Average/day
    /// [Connectivity] 7: Connected Devices | 8: Total Devices | 9: Total %
    func generateGraphData() -> [Double] {
        // Setup the answer variable
        var answer: [Double] = []
        if stat == "AppleCare+" {
            if selectedDateChoice == "Weekly" {
                
                // MARK: AC Weekly
                
                // Set up the variables
                let weekInQuestion = data.weekJump(weeklyOffset)
                var sunday: [Transaction] = []
                var monday: [Transaction] = []
                var tuesday: [Transaction] = []
                var wednesday: [Transaction] = []
                var thursday: [Transaction] = []
                var friday: [Transaction] = []
                var saturday: [Transaction] = []
                
                // Filter the week's transactions and place them into their weekday arrays
                for eachTransaction in weekInQuestion {
                    let weekday = DateFormatter().weekdaySymbols[Calendar.current.component(.weekday, from: eachTransaction.date!) - 1]
                    switch weekday {
                    case "Sunday": sunday.append(eachTransaction)
                    case "Monday": monday.append(eachTransaction)
                    case "Tuesday": tuesday.append(eachTransaction)
                    case "Wednesday": wednesday.append(eachTransaction)
                    case "Thursday": thursday.append(eachTransaction)
                    case "Friday": friday.append(eachTransaction)
                    case "Saturday": saturday.append(eachTransaction)
                    default: print("Default case hit in generateGraphData() in GraphDetailView!")
                    }
                }
                
                // Create TransactionServices objects and get the AC+ percentage. Then, place them in the answer array.
                answer.append(Double(TransactionServices(sunday).appleCarePercent()) / 100.0)
                answer.append(Double(TransactionServices(monday).appleCarePercent()) / 100.0)
                answer.append(Double(TransactionServices(tuesday).appleCarePercent()) / 100.0)
                answer.append(Double(TransactionServices(wednesday).appleCarePercent()) / 100.0)
                answer.append(Double(TransactionServices(thursday).appleCarePercent()) / 100.0)
                answer.append(Double(TransactionServices(friday).appleCarePercent()) / 100.0)
                answer.append(Double(TransactionServices(saturday).appleCarePercent()) / 100.0)
                
                // Add the extra stats for AppleCare+
                answer.append(Double(TransactionServices(weekInQuestion).appleCareNumerator()))
                answer.append(Double(TransactionServices(weekInQuestion).withDevice().count))
                answer.append(Double(TransactionServices(weekInQuestion).appleCarePercent()))
                
            } else if selectedDateChoice == "Monthly" {
                
                // MARK: AC Monthly
                
                // Get the weeks in question
                let jumpNum = 7 * monthlyOffset
                let week1 = data.weekJump(0 + jumpNum)
                let week2 = data.weekJump(1 + jumpNum)
                let week3 = data.weekJump(2 + jumpNum)
                let week4 = data.weekJump(3 + jumpNum)
                let week5 = data.weekJump(4 + jumpNum)
                let week6 = data.weekJump(5 + jumpNum)
                let week7 = data.weekJump(6 + jumpNum)
                
                // Add the AC+ percents to the answer variable
                answer.append(Double(TransactionServices(week7).appleCarePercent()) / 100.0)
                answer.append(Double(TransactionServices(week6).appleCarePercent()) / 100.0)
                answer.append(Double(TransactionServices(week5).appleCarePercent()) / 100.0)
                answer.append(Double(TransactionServices(week4).appleCarePercent()) / 100.0)
                answer.append(Double(TransactionServices(week3).appleCarePercent()) / 100.0)
                answer.append(Double(TransactionServices(week2).appleCarePercent()) / 100.0)
                answer.append(Double(TransactionServices(week1).appleCarePercent()) / 100.0)
                
                // Add the extra stats
                let sevenWeeks = week1 + week2 + week3 + week4 + week5 + week6 + week7
                answer.append(Double(TransactionServices(sevenWeeks).appleCareNumerator()))
                answer.append(Double(TransactionServices(sevenWeeks).withDevice().count))
                answer.append(Double(TransactionServices(sevenWeeks).appleCarePercent()))
                
            } else {
                
                // MARK: AC Yearly
                
                // Get the months in question
                let jumpNum = 7 * yearlyOffset
                let month1 = data.monthJump(0 + jumpNum)
                let month2 = data.monthJump(1 + jumpNum)
                let month3 = data.monthJump(2 + jumpNum)
                let month4 = data.monthJump(3 + jumpNum)
                let month5 = data.monthJump(4 + jumpNum)
                let month6 = data.monthJump(5 + jumpNum)
                let month7 = data.monthJump(6 + jumpNum)
                
                // Add the AC+ percents to the answer variable
                answer.append(Double(TransactionServices(month7).appleCarePercent()) / 100.0)
                answer.append(Double(TransactionServices(month6).appleCarePercent()) / 100.0)
                answer.append(Double(TransactionServices(month5).appleCarePercent()) / 100.0)
                answer.append(Double(TransactionServices(month4).appleCarePercent()) / 100.0)
                answer.append(Double(TransactionServices(month3).appleCarePercent()) / 100.0)
                answer.append(Double(TransactionServices(month2).appleCarePercent()) / 100.0)
                answer.append(Double(TransactionServices(month1).appleCarePercent()) / 100.0)
                
                // Add the extra stats
                let sevenMonths = month1 + month2 + month3 + month4 + month5 + month6 + month7
                answer.append(Double(TransactionServices(sevenMonths).appleCareNumerator()))
                answer.append(Double(TransactionServices(sevenMonths).withDevice().count))
                answer.append(Double(TransactionServices(sevenMonths).appleCarePercent()))
                
            }
            
        } else if stat == "Business Leads" {
            if selectedDateChoice == "Weekly" {
                
                // MARK: Leads Weekly
                
                // Set up the variables
                let weekInQuestion = data.weekJump(weeklyOffset)
                var sunday: [Transaction] = []
                var monday: [Transaction] = []
                var tuesday: [Transaction] = []
                var wednesday: [Transaction] = []
                var thursday: [Transaction] = []
                var friday: [Transaction] = []
                var saturday: [Transaction] = []
                
                // Filter the week's transactions and place them into their weekday arrays
                for eachTransaction in weekInQuestion {
                    let weekday = DateFormatter().weekdaySymbols[Calendar.current.component(.weekday, from: eachTransaction.date!) - 1]
                    switch weekday {
                    case "Sunday": sunday.append(eachTransaction)
                    case "Monday": monday.append(eachTransaction)
                    case "Tuesday": tuesday.append(eachTransaction)
                    case "Wednesday": wednesday.append(eachTransaction)
                    case "Thursday": thursday.append(eachTransaction)
                    case "Friday": friday.append(eachTransaction)
                    case "Saturday": saturday.append(eachTransaction)
                    default: print("Default case hit in generateGraphData() in GraphDetailView!")
                    }
                }
                
                // Create TransactionServices objects and get the leads percentage. Then, place them in the answer array.
                answer.append(Double(TransactionServices(sunday).numBusinessLeads()) / 5.0)
                answer.append(Double(TransactionServices(monday).numBusinessLeads()) / 5.0)
                answer.append(Double(TransactionServices(tuesday).numBusinessLeads()) / 5.0)
                answer.append(Double(TransactionServices(wednesday).numBusinessLeads()) / 5.0)
                answer.append(Double(TransactionServices(thursday).numBusinessLeads()) / 5.0)
                answer.append(Double(TransactionServices(friday).numBusinessLeads()) / 5.0)
                answer.append(Double(TransactionServices(saturday).numBusinessLeads()) / 5.0)
                
                // Add the extra stats for leads
                answer.append(Double(TransactionServices(weekInQuestion).numBusinessLeads()))
                answer.append(Double(TransactionServices(weekInQuestion).numBusinessLeads()) / Double((TransactionServices(weekInQuestion)).numUniqueDays()))
                
            } else if selectedDateChoice == "Monthly" {
                
                // MARK: Leads Monthly
                
                // Get the weeks in question
                let jumpNum = 7 * monthlyOffset
                let week1 = data.weekJump(0 + jumpNum)
                let week2 = data.weekJump(1 + jumpNum)
                let week3 = data.weekJump(2 + jumpNum)
                let week4 = data.weekJump(3 + jumpNum)
                let week5 = data.weekJump(4 + jumpNum)
                let week6 = data.weekJump(5 + jumpNum)
                let week7 = data.weekJump(6 + jumpNum)
                
                // Add the leads percents to the answer variable
                answer.append(Double(TransactionServices(week7).numBusinessLeads()) / 35.0)
                answer.append(Double(TransactionServices(week6).numBusinessLeads()) / 35.0)
                answer.append(Double(TransactionServices(week5).numBusinessLeads()) / 35.0)
                answer.append(Double(TransactionServices(week4).numBusinessLeads()) / 35.0)
                answer.append(Double(TransactionServices(week3).numBusinessLeads()) / 35.0)
                answer.append(Double(TransactionServices(week2).numBusinessLeads()) / 35.0)
                answer.append(Double(TransactionServices(week1).numBusinessLeads()) / 35.0)
                
                // Add the extra stats for leads
                let sevenWeeks = week1 + week2 + week3 + week4 + week5 + week6 + week7
                answer.append(Double(TransactionServices(sevenWeeks).numBusinessLeads()))
                answer.append(Double(TransactionServices(sevenWeeks).numBusinessLeads()) / Double((TransactionServices(sevenWeeks)).numUniqueDays()))
                
            } else {
                
                // MARK: Leads Yearly
                
                // Get the months in question
                let jumpNum = 7 * yearlyOffset
                let month1 = data.monthJump(0 + jumpNum)
                let month2 = data.monthJump(1 + jumpNum)
                let month3 = data.monthJump(2 + jumpNum)
                let month4 = data.monthJump(3 + jumpNum)
                let month5 = data.monthJump(4 + jumpNum)
                let month6 = data.monthJump(5 + jumpNum)
                let month7 = data.monthJump(6 + jumpNum)
                
                // Add the leads percents to the answer variable
                answer.append(Double(TransactionServices(month7).numBusinessLeads()) / 100.0)
                answer.append(Double(TransactionServices(month6).numBusinessLeads()) / 100.0)
                answer.append(Double(TransactionServices(month5).numBusinessLeads()) / 100.0)
                answer.append(Double(TransactionServices(month4).numBusinessLeads()) / 100.0)
                answer.append(Double(TransactionServices(month3).numBusinessLeads()) / 100.0)
                answer.append(Double(TransactionServices(month2).numBusinessLeads()) / 100.0)
                answer.append(Double(TransactionServices(month1).numBusinessLeads()) / 100.0)
                
                // Add the extra stats
                let sevenMonths = month1 + month2 + month3 + month4 + month5 + month6 + month7
                answer.append(Double(TransactionServices(sevenMonths).numBusinessLeads()))
                answer.append(Double(TransactionServices(sevenMonths).numBusinessLeads()) / Double((TransactionServices(sevenMonths)).numUniqueDays()))
                
            }
        } else {
            if selectedDateChoice == "Weekly" {
                
                // MARK: Connectivity Weekly
                
                // Set up the variables
                let weekInQuestion = data.weekJump(weeklyOffset)
                var sunday: [Transaction] = []
                var monday: [Transaction] = []
                var tuesday: [Transaction] = []
                var wednesday: [Transaction] = []
                var thursday: [Transaction] = []
                var friday: [Transaction] = []
                var saturday: [Transaction] = []
                
                // Filter the week's transactions and place them into their weekday arrays
                for eachTransaction in weekInQuestion {
                    let weekday = DateFormatter().weekdaySymbols[Calendar.current.component(.weekday, from: eachTransaction.date!) - 1]
                    switch weekday {
                    case "Sunday": sunday.append(eachTransaction)
                    case "Monday": monday.append(eachTransaction)
                    case "Tuesday": tuesday.append(eachTransaction)
                    case "Wednesday": wednesday.append(eachTransaction)
                    case "Thursday": thursday.append(eachTransaction)
                    case "Friday": friday.append(eachTransaction)
                    case "Saturday": saturday.append(eachTransaction)
                    default: print("Default case hit in generateGraphData() in GraphDetailView!")
                    }
                }
                
                // Create TransactionServices objects and get the connecticity percentage. Then, place them in the answer array.
                answer.append(Double(TransactionServices(sunday).connectivityPercent()) / 100.0)
                answer.append(Double(TransactionServices(monday).connectivityPercent()) / 100.0)
                answer.append(Double(TransactionServices(tuesday).connectivityPercent()) / 100.0)
                answer.append(Double(TransactionServices(wednesday).connectivityPercent()) / 100.0)
                answer.append(Double(TransactionServices(thursday).connectivityPercent()) / 100.0)
                answer.append(Double(TransactionServices(friday).connectivityPercent()) / 100.0)
                answer.append(Double(TransactionServices(saturday).connectivityPercent()) / 100.0)
                
                // Add the extra stats for connectivity
                answer.append(Double(TransactionServices(weekInQuestion).connectedUnits()))
                answer.append(Double(TransactionServices(weekInQuestion).withDevice().count))
                answer.append(Double(TransactionServices(weekInQuestion).connectivityPercent()))
                
            } else if selectedDateChoice == "Monthly" {
                
                // MARK: Connectivity Monthly
                
                // Get the weeks in question
                let jumpNum = 7 * monthlyOffset
                let week1 = data.weekJump(0 + jumpNum)
                let week2 = data.weekJump(1 + jumpNum)
                let week3 = data.weekJump(2 + jumpNum)
                let week4 = data.weekJump(3 + jumpNum)
                let week5 = data.weekJump(4 + jumpNum)
                let week6 = data.weekJump(5 + jumpNum)
                let week7 = data.weekJump(6 + jumpNum)
                
                // Add the connectivity percents to the answer variable
                answer.append(Double(TransactionServices(week7).connectivityPercent()) / 100.0)
                answer.append(Double(TransactionServices(week6).connectivityPercent()) / 100.0)
                answer.append(Double(TransactionServices(week5).connectivityPercent()) / 100.0)
                answer.append(Double(TransactionServices(week4).connectivityPercent()) / 100.0)
                answer.append(Double(TransactionServices(week3).connectivityPercent()) / 100.0)
                answer.append(Double(TransactionServices(week2).connectivityPercent()) / 100.0)
                answer.append(Double(TransactionServices(week1).connectivityPercent()) / 100.0)
                
                // Add the extra stats
                let sevenWeeks = week1 + week2 + week3 + week4 + week5 + week6 + week7
                answer.append(Double(TransactionServices(sevenWeeks).connectedUnits()))
                answer.append(Double(TransactionServices(sevenWeeks).withDevice().count))
                answer.append(Double(TransactionServices(sevenWeeks).connectivityPercent()))
                
            } else {
                
                // MARK: Connectivity Yearly
                
                // Get the months in question
                let jumpNum = 7 * yearlyOffset
                let month1 = data.monthJump(0 + jumpNum)
                let month2 = data.monthJump(1 + jumpNum)
                let month3 = data.monthJump(2 + jumpNum)
                let month4 = data.monthJump(3 + jumpNum)
                let month5 = data.monthJump(4 + jumpNum)
                let month6 = data.monthJump(5 + jumpNum)
                let month7 = data.monthJump(6 + jumpNum)
                
                // Add the AC+ percents to the answer variable
                answer.append(Double(TransactionServices(month7).connectivityPercent()) / 100.0)
                answer.append(Double(TransactionServices(month6).connectivityPercent()) / 100.0)
                answer.append(Double(TransactionServices(month5).connectivityPercent()) / 100.0)
                answer.append(Double(TransactionServices(month4).connectivityPercent()) / 100.0)
                answer.append(Double(TransactionServices(month3).connectivityPercent()) / 100.0)
                answer.append(Double(TransactionServices(month2).connectivityPercent()) / 100.0)
                answer.append(Double(TransactionServices(month1).connectivityPercent()) / 100.0)
                
                // Add the extra stats
                let sevenMonths = month1 + month2 + month3 + month4 + month5 + month6 + month7
                answer.append(Double(TransactionServices(sevenMonths).connectedUnits()))
                answer.append(Double(TransactionServices(sevenMonths).withDevice().count))
                answer.append(Double(TransactionServices(sevenMonths).connectivityPercent()))
                
            }
        }
        
        return answer
        
    }
    
}

struct GraphDetailView_Previews: PreviewProvider {
    static var previews: some View {
        GraphDetailView(data: TransactionServices([]), stat: "Connectivity")
    }
}

struct ChevronButton: View {
    
    // Variables
    var direction: String
    var color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(.secondary)
                .frame(width: 37, height: 37)
                .opacity(0.3)
            Image(systemName: "chevron.\(direction)")
                .font(Font.title.weight(.bold))
                .imageScale(.small)
                .foregroundColor(color)
        }
    }
}
