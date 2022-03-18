//
//  HomeView.swift
//  WorkoutDiary
//
//  Created by Lukas Kaibel on 24.09.21.
//

import SwiftUI
import CoreData

struct HomeView: View {
    
    @ObservedObject private var home: Home
    @State private var isShowingWorkoutRecorder: Bool = false
    @State private var isShowingProfile: Bool = false
    @State private var isShowingQuote: Bool = true
    
    init(context: NSManagedObjectContext) {
        self.home = Home(context: context)
    }
    
    var body: some View {
        NavigationView {
            List {
                Group {
                    AverageWorkoutsView
                    Section(content: {
                        ForEach(home.recentWorkouts, id:\.objectID) { (workout: Workout) in
                            WorkoutCellView(workout: workout)
                        }.onDelete { indexSet in
                            for index in indexSet {
                                home.delete(workout: home.recentWorkouts[index])
                            }
                        }
                    }, header: {
                        HStack {
                            Text("Recent Workouts")
                                .foregroundColor(.label)
                                .font(.title2.weight(.bold))
                                .fixedSize()
                            Spacer()
                            NavigationLink(destination: AllWorkoutsView(context: home.context)) {
                                Text("Show All")
                                    .foregroundColor(.accentColor)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }.padding(.vertical, 5)
                        .listRowSeparator(.hidden, edges: .top)
                    })
                    
                }
                Spacer(minLength: 50)
                    .listRowSeparator(.hidden, edges: .bottom)
            }.listStyle(.plain)
                .navigationTitle("LOGIT.")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isShowingProfile = true
                        }) {
                            Image(systemName: "person.crop.circle")
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Button(action: {
                            isShowingWorkoutRecorder = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("New Workout")
                            }.font(.body.weight(.bold))
                        }
                    }
                }
        } .navigationViewStyle(.stack)
        .fullScreenCover(isPresented: $isShowingWorkoutRecorder) {
            WorkoutRecorderView()
        }
        .sheet(isPresented: $isShowingProfile) {
            NavigationView {
                ProfileView()
            }
        }
    }
    
    private var QuoteView: some View {
        VStack(spacing: 10) {
            Text("\""+"He who says he can and he who says he can't are both usually right."+"\"")
                .foregroundColor(.separator)
                .multilineTextAlignment(.center)
                .font(.title2.weight(.bold))
            Text("Michael Jordan")
                .foregroundColor(.separator)
                .font(.body.weight(.medium))
        }
            .padding(.horizontal)
    }
    
    private var AverageWorkoutsView: some View {
        Section(content: {
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Weekly Average")
                            .foregroundColor(.secondaryLabel)
                        HStack(alignment: .lastTextBaseline) {
                            Text("\(home.averageWorkoutsPerWeek(for: home.numberOfWeeksInAnalysis)) per week")
                                .font(.title.weight(.medium))
                            Spacer()
                            HStack(spacing: 3) {
                                Image(systemName: "arrow.\(differenceBetweenLastTwoWeeks < 0 ? "down" : differenceBetweenLastTwoWeeks == 0 ? "right" : "up").circle.fill")
                                    .font(.body.weight(.bold))
                                Text("\(abs(differenceBetweenLastTwoWeeks)) from last week")
                                    .monospacedDigit()
                            }.foregroundColor(differenceBetweenLastTwoWeeks <= 0 ? .secondaryLabel : .green)
                        }
                    }
                    Spacer()
                }.padding()
                BarGraph(xValues: home.getWeeksString().reversed(),
                          yValues: home.workoutsPerWeek(for: home.numberOfWeeksInAnalysis).reversed(),
                          barColors: home.barColorsForWeeks().reversed())
                    .frame(height: 120)
                    .padding([.bottom, .horizontal])
                
            }.background(Color.secondaryBackground)
            .cornerRadius(10)
        }).listRowSeparator(.hidden)
    }
    
    private var differenceBetweenLastTwoWeeks: Int {
        let workoutsPerWeek = home.workoutsPerWeek(for: home.numberOfWeeksInAnalysis)
        if workoutsPerWeek.count > 1 {
            return workoutsPerWeek[0] - workoutsPerWeek[1]
        }
        return workoutsPerWeek.first ?? 0
    }
    
}



struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(context: Database.preview.container.viewContext)
    }
}






//Section {
//                        HStack {
//                            VStack(alignment: .leading, spacing: 15) {
//                                HStack(spacing: 3) {
//                                    Image(systemName: "target")
//                                    Text("WEEKLY GOAL")
//                                }.foregroundColor(.secondaryLabel)
//                                    .font(.caption.weight(.medium))
//                                VStack(alignment: .leading, spacing: -5) {
//                                    Text(String(home.goalPerWeek))
//                                        .font(.largeTitle)
//                                    Text("per week")
//                                }
//                                Spacer()
//                                VStack(spacing: 10) {
//                                    ProgressView(value: Float(home.workoutsPerWeek(for: 1).first ?? 0) / Float(home.goalPerWeek))
//                                        .progressViewStyle(LinearProgressViewStyle())
//                                        .tint(.accentColor)
//                                    HStack {
//                                        Text("This week")
//                                        Spacer()
//                                        Text("\(home.workoutsPerWeek(for: 1).first ?? 0)/\(home.goalPerWeek)")
//                                    }
//                                        .font(.footnote)
//                                }
//                            }.padding()
//                                .frame(maxWidth: .infinity, maxHeight: 180)
//                                .background(Color.secondaryBackground)
//                                .cornerRadius(10)
//                            NavigationLink(destination: WeightEntriesView()) {
//                                VStack(alignment: .leading, spacing: 15) {
//                                    HStack(spacing: 3) {
//                                        Image(systemName: "scalemass.fill")
//                                        Text("WEIGHT")
//                                        Spacer()
//                                    }.foregroundColor(.secondaryLabel)
//                                        .font(.caption.weight(.medium))
//                                    VStack(alignment: .leading, spacing: -5) {
//                                        Text("83")
//                                            .font(.largeTitle)
//                                        Text("kg")
//                                    }
//                                    Spacer()
//                                    Text("Tap to enter")
//                                        .font(.footnote)
//
//                                }
//                            }.padding()
//                                .frame(maxWidth: .infinity, maxHeight: 180)
//                                .background(Color.secondaryBackground)
//                                .cornerRadius(10)
//                        }
//                    }.listRowSeparator(.hidden)
