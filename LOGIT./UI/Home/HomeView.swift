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
    
    @StateObject var home = Home()
    @State private var isShowingWorkoutRecorder: Bool = false
    @State private var isShowingProfile: Bool = false
    @State private var isShowingTemplateEditor = false
    @State private var isShowingNewTemplate = false
    
    var body: some View {
        NavigationView {
            List {
                Group {
                    TargetWorkoutsView
                    Section {
                        HStack {
                            Button(action: { isShowingNewTemplate = true }) {
                                VStack(spacing: 5) {
                                    Image(systemName: "list.bullet.rectangle.portrait")
                                        .font(.body.weight(.semibold))
                                    Text(NSLocalizedString("createTemplate", comment: ""))
                                }.foregroundColor(.label)
                            }.padding(15)
                                .frame(maxWidth: .infinity)
                                .contentShape(Rectangle())
                                .background(Color.secondaryBackground)
                                .cornerRadius(10)
                            Button(action: { isShowingWorkoutRecorder = true }) {
                                VStack(spacing: 5) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.body.weight(.semibold))
                                    Text(NSLocalizedString("startWorkout", comment: ""))
                                        .fontWeight(.bold)
                                }.foregroundColor(.white)
                            }.padding(15)
                                .frame(maxWidth: .infinity)
                                .contentShape(Rectangle())
                                .background(Color.accentColor)
                                .cornerRadius(10)
                        }.font(.subheadline.weight(.semibold))
                    }.padding(.top)
                        .buttonStyle(.plain)
                        .listRowSeparator(.hidden)
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
                            Text(NSLocalizedString("recentWorkouts", comment: ""))
                                .foregroundColor(.label)
                                .font(.title2.weight(.bold))
                                .fixedSize()
                            Spacer()
                            NavigationLink(destination: AllWorkoutsView()) {
                                Text(NSLocalizedString("showAll", comment: ""))
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
                .navigationTitle(NSLocalizedString("home", comment: ""))
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isShowingProfile = true
                        }) {
                            Image(systemName: "person.crop.circle")
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
        .sheet(isPresented: $isShowingNewTemplate) {
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
                        Text(NSLocalizedString("workoutTarget", comment: ""))
                            .foregroundColor(.secondaryLabel)
                        HStack(alignment: .lastTextBaseline) {
                            Text("\(targetPerWeek) \(NSLocalizedString("perWeek", comment: ""))")
                                .font(.title.weight(.medium))
                            Spacer()
                            if let workoutsThisWeek = home.workoutsPerWeek(for: home.numberOfWeeksInAnalysis).reversed().last {
                                if workoutsThisWeek >= targetPerWeek {
                                    HStack(spacing: 3) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.title3.weight(.bold))
                                        Text(NSLocalizedString("completed", comment: ""))
                                            .font(.title3)
                                    }.foregroundColor(.green)
                                } else {
                                    HStack(spacing: 5) {
                                        Image(systemName: "arrow.right.circle.fill")
                                        Text("\(description(for: targetPerWeek - workoutsThisWeek)) \(NSLocalizedString("toGo", comment: ""))")
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
        case 0: return NSLocalizedString("zero", comment: "")
        case 1: return NSLocalizedString("one", comment: "")
        case 2: return NSLocalizedString("two", comment: "")
        case 3: return NSLocalizedString("three", comment: "")
        case 4: return NSLocalizedString("four", comment: "")
        case 5: return NSLocalizedString("five", comment: "")
        case 6: return NSLocalizedString("six", comment: "")
        case 7: return NSLocalizedString("seven", comment: "")
        case 8: return NSLocalizedString("eight", comment: "")
        case 9: return NSLocalizedString("nine", comment: "")
        default: return "\(digit)"
        }
    }
    
    private var AverageWorkoutsView: some View {
        Section(content: {
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(NSLocalizedString("weeklyAverage", comment: ""))
                            .foregroundColor(.secondaryLabel)
                        HStack(alignment: .lastTextBaseline) {
                            Text("\(home.averageWorkoutsPerWeek(for: home.numberOfWeeksInAnalysis)) \(NSLocalizedString("perWeek", comment: ""))")
                                .font(.title.weight(.medium))
                            Spacer()
                            HStack(spacing: 3) {
                                Image(systemName: "arrow.\(differenceBetweenLastTwoWeeks < 0 ? "down" : differenceBetweenLastTwoWeeks == 0 ? "right" : "up").circle.fill")
                                    .font(.body.weight(.bold))
                                Text("\(abs(differenceBetweenLastTwoWeeks)) \(NSLocalizedString("fromLastWeek", comment: ""))")
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
        HomeView()
    }
}
