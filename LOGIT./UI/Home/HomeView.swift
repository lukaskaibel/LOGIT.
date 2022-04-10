//
//  HomeView.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 24.09.21.
//

import SwiftUI
import CoreData

struct HomeView: View {
        
    @AppStorage("workoutPerWeekTarget") var targetPerWeek: Int = 3
    
    @ObservedObject private var home: Home
    @State private var isShowingWorkoutRecorder: Bool = false
    @State private var isShowingProfile: Bool = false
    @State private var isShowingTemplateEditor = false
    @State private var isShowingQuote: Bool = true
    
    init(context: NSManagedObjectContext) {
        self.home = Home(context: context)
    }
    
    var body: some View {
        NavigationView {
            List {
                Group {
                    TargetWorkoutsView
                    Section(content: {
                        ForEach(home.recentWorkouts, id:\.objectID) { (workout: Workout) in
                            WorkoutCellView(workout: workout, canNavigateToTemplate: .constant(true))
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
                    }).listRowSeparator(.hidden)
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
        .sheet(isPresented: $isShowingTemplateEditor) {
            TemplateWorkoutEditorView(templateWorkoutEditor: TemplateWorkoutEditor())
        }
    }
    
//    private var QuoteView: some View {
//        VStack(spacing: 10) {
//            Text("\""+"He who says he can and he who says he can't are both usually right."+"\"")
//                .foregroundColor(.separator)
//                .multilineTextAlignment(.center)
//                .font(.title2.weight(.bold))
//            Text("Michael Jordan")
//                .foregroundColor(.separator)
//                .font(.body.weight(.medium))
//        }
//            .padding(.horizontal)
//    }
    
    private var TargetWorkoutsView: some View {
        Section(content: {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Workout target")
                            .foregroundColor(.secondaryLabel)
                        HStack(alignment: .lastTextBaseline) {
                            Text("\(targetPerWeek) per week")
                                .font(.title.weight(.medium))
                            Spacer()
                            if let workoutsThisWeek = home.workoutsPerWeek(for: home.numberOfWeeksInAnalysis).reversed().last {
                                if workoutsThisWeek >= targetPerWeek {
                                    HStack(spacing: 3) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.title3.weight(.bold))
                                        Text("Completed")
                                            .font(.title3)
                                    }.foregroundColor(.green)
                                } else {
                                    HStack(spacing: 5) {
                                        Image(systemName: "arrow.right.circle.fill")
                                        Text("\(description(for: targetPerWeek - workoutsThisWeek)) to go")
                                    }.foregroundColor(.secondaryLabel)
                                        .font(.title3)
                                }
                            }
                        }
                    }
                    Spacer()
                }
                TargetPerWeekGraph(xValues: home.getWeeksString().reversed(),
                                  yValues: home.workoutsPerWeek(for: home.numberOfWeeksInAnalysis).reversed(),
                                  target: targetPerWeek)
                    .frame(height: 170)
            }.tileStyle()
        }).listRowSeparator(.hidden)
    }
    
    private func description(for digit: Int) -> String {
        switch digit {
        case 0: return "Zero"
        case 1: return "One"
        case 2: return "Two"
        case 3: return "Three"
        case 4: return "Four"
        case 5: return "Five"
        case 6: return "Six"
        case 7: return "Seven"
        case 8: return "Eight"
        case 9: return "Nine"
        default: return "\(digit)"
        }
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
