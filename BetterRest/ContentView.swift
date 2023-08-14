//
//  ContentView.swift
//  BetterRest
//
//  Created by Eugene on 14/08/2023.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMsg = ""
    @State private var showingAlert = false
    
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute  = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
   
    
    var body: some View {

        NavigationView {
            Form {

                Section {
                    Text("When do you want to wake up?")
                        .font(.headline)

                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents:.hourAndMinute)
                        .onChange(of: wakeUp) { value in
                            self.calculateBedtime()
                        }
                    
        
                }
                
                Section {
                    Text("Desired amount of sleep").font(.headline)
                    
                    Stepper {
                        Text("\(sleepAmount.formatted()) hours")
                    }  onIncrement: {
                        if (sleepAmount == 12) {
                            return
                        }
                        sleepAmount += 0.25
                        
                        self.calculateBedtime()
                    }  onDecrement: {
                        if (sleepAmount == 4) {
                            return
                        }
                        sleepAmount -= 0.25

                        self.calculateBedtime()
                    }
                }
          
                Section {
                    Text("Daily coffee intake").font(.headline)

                    Picker("Test", selection: $coffeeAmount) {
                        ForEach(1...20, id: \.self) { number in
                            Text(number == 1 ? "\(number) cup" : "\(number) cups")
                        }
                    }.onChange(of: coffeeAmount) { value in
                        self.calculateBedtime()
                    }
                    
                
                }
                
                Section {
                    Text("Your recommended bedtime is \(alertMsg)")
                        .font(.title)
                        .fontWeight(.bold)
                        
                }
               
            }
            .navigationTitle("BetterRest")
            }
            .onAppear {
                self.calculateBedtime()   // 3)
            }

        
        }
        
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is"
            alertMsg = sleepTime.formatted(date: .omitted, time: .shortened)
            
            
        } catch {
            alertTitle = "Error"
            alertMsg = "Sorry, there was a problem calculating your bedtime"
            
        }
        
        showingAlert = true
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
