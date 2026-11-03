//
//  JourneyPath.swift
//  Asphyr
//

import Foundation

struct JourneyStar {
    let name: String
    let goal: String
    /// Completed quests needed to light this star.
    let questsNeeded: Int
    let iconName: String
}

/// Where the user is on the constellation, worked out from completed quests.
struct JourneyProgress {
    enum State: Equatable {
        case newUser
        case onTheWay
        case starUnlocked
        case welcomeBack
        case allLit
    }

    static let welcomeBackDays = 3

    let stars: [JourneyStar]
    let completedQuests: Int
    let litStarsAlreadySeen: Int
    let lastCompletedAt: Date?

    static func stars(aspiration: String?) -> [JourneyStar] {
        JourneyPath.path(for: aspiration).stars
    }

    var litCount: Int {
        stars.filter { completedQuests >= $0.questsNeeded }.count
    }

    /// The next star to light. Nil once they're all lit.
    var currentIndex: Int? {
        litCount < stars.count ? litCount : nil
    }

    var questsUntilNextStar: Int {
        currentIndex.map { stars[$0].questsNeeded - completedQuests } ?? 0
    }

    func state(at date: Date = .now) -> State {
        if completedQuests == 0 { return .newUser }
        if litCount > litStarsAlreadySeen { return .starUnlocked }
        if currentIndex == nil { return .allLit }

        if let lastCompletedAt,
           let days = Calendar.current.dateComponents([.day], from: lastCompletedAt, to: date).day,
           days >= Self.welcomeBackDays {
            return .welcomeBack
        }
        return .onTheWay
    }
}

/// The stars for one aspiration. Each has its own names and goals, with the same
/// number of quests needed at every position. The last star masters one skill,
/// never the aspiration itself, because no one reaches a dream in 20 quests.
struct JourneyPath {
    private static let questsNeeded = [1, 3, 5, 8, 11, 15, 20]

    let stars: [JourneyStar]

    /// Star names and goals in order, ending with the destination. The third
    /// star uses the aspiration's own icon.
    private init(iconName: String, _ steps: [(name: String, goal: String)]) {
        let icons = ["iconJourneyFlag", "iconJourneyTarget", iconName, "iconJourneyCompass",
                     "iconAttributeProblemSolving", "iconQuestBook", "iconJourneyCrown"]

        stars = steps.indices.map { index in
            JourneyStar(
                name: steps[index].name,
                goal: steps[index].goal,
                questsNeeded: Self.questsNeeded[index],
                iconName: icons[index]
            )
        }
    }

    /// Matches listed and popular aspirations whatever their capitals or spacing.
    /// Anything else is a custom aspiration, which gets the general path.
    static func path(for aspiration: String?) -> JourneyPath {
        let name = aspiration?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return paths[name.lowercased()] ?? general
    }

    private static var general: JourneyPath {
        JourneyPath(iconName: "iconSparklesSmall", [
            ("First Steps", "Complete your first quest"),
            ("Consistency", "Keep showing up"),
            ("Apprentice", "Keep learning the basics"),
            ("Practitioner", "Put your skills to use"),
            ("Problem Solver", "Work through something hard"),
            ("Expert", "Go deeper than before"),
            ("Foundations Master", "Master the basics")
        ])
    }

    private static let paths: [String: JourneyPath] = [
        "game developer": JourneyPath(iconName: "iconLaptop", [
            ("First Prototype", "Make something playable"),
            ("Game Jammer", "Finish small games often"),
            ("Mechanics Coder", "Build a mechanic that feels good"),
            ("Level Designer", "Design a level worth replaying"),
            ("Bug Hunter", "Track down a tricky bug"),
            ("Playtester", "Learn from people playing your game"),
            ("Prototype Master", "Finish a small game of your own")
        ]),
        "mechanical engineer": JourneyPath(iconName: "iconWrench", [
            ("First Sketch", "Draw your first design"),
            ("Tinkerer", "Take things apart and learn"),
            ("Drafter", "Model a part in detail"),
            ("Prototyper", "Build something that moves"),
            ("Troubleshooter", "Find out why a design failed"),
            ("Systems Thinker", "See how the parts work together"),
            ("Workshop Master", "Build a working model")
        ]),
        "psychologist": JourneyPath(iconName: "iconBulb", [
            ("First Question", "Get curious about the mind"),
            ("Observer", "Notice how people behave"),
            ("Student of Mind", "Learn the core theories"),
            ("Researcher", "Read and question a study"),
            ("Listener", "Practice listening with care"),
            ("Case Thinker", "Connect theory to real people"),
            ("Observation Master", "Understand how people behave")
        ]),
        "doctor": JourneyPath(iconName: "iconStethoscope", [
            ("First Lesson", "Begin your medical studies"),
            ("Study Habit", "Study a little every day"),
            ("Anatomy Student", "Learn how the body works"),
            ("Clinical Mind", "Practice reasoning through cases"),
            ("Diagnostician", "Work through a hard diagnosis"),
            ("Caregiver", "Learn to care for patients"),
            ("Anatomy Master", "Master the body’s basics")
        ]),
        "writer": JourneyPath(iconName: "iconPen", [
            ("First Page", "Write your first page"),
            ("Daily Writer", "Write a little every day"),
            ("Storyteller", "Finish a short piece"),
            ("Drafter", "Complete a full draft"),
            ("Editor", "Rewrite until it reads right"),
            ("Stylist", "Find your own voice"),
            ("Story Master", "Finish a story you’re proud of")
        ]),
        "artist": JourneyPath(iconName: "iconCreator", [
            ("First Sketch", "Make your first piece"),
            ("Daily Sketcher", "Draw a little every day"),
            ("Color Student", "Study color and light"),
            ("Composer", "Plan a piece with intention"),
            ("Experimenter", "Try a new medium"),
            ("Visionary", "Develop your own style"),
            ("Sketch Master", "Fill a sketchbook with finished work")
        ]),
        "entrepreneur": JourneyPath(iconName: "iconStrategist", [
            ("First Idea", "Write down a problem worth solving"),
            ("Validator", "Talk to people who have it"),
            ("Planner", "Shape the idea into a plan"),
            ("Builder", "Make a first version"),
            ("Problem Solver", "Get past a real setback"),
            ("Seller", "Win your first customers"),
            ("Idea Master", "Prove people want your idea")
        ]),
        "musician": JourneyPath(iconName: "iconSparklesSmall", [
            ("First Notes", "Play your first notes"),
            ("Daily Practice", "Practice a little every day"),
            ("Ear Trainer", "Learn to hear what you play"),
            ("Performer", "Learn a full piece"),
            ("Improviser", "Play without the page"),
            ("Songwriter", "Write something of your own"),
            ("Practice Master", "Play a full piece for someone")
        ]),
        "athlete": JourneyPath(iconName: "iconExplorer", [
            ("First Session", "Finish your first workout"),
            ("Regular", "Train on a steady schedule"),
            ("Trainee", "Learn the right technique"),
            ("Competitor", "Test yourself against a goal"),
            ("Comeback", "Push through a hard stretch"),
            ("Strategist", "Train with a plan"),
            ("Training Master", "Complete a full training block")
        ]),
        "teacher": JourneyPath(iconName: "iconScholar", [
            ("First Lesson", "Explain something to someone"),
            ("Lifelong Learner", "Study your subject every day"),
            ("Lesson Planner", "Plan a complete lesson"),
            ("Classroom Guide", "Teach a group"),
            ("Problem Solver", "Help a struggling learner"),
            ("Mentor", "Guide someone over time"),
            ("Lesson Master", "Teach a lesson that lands")
        ]),
        "designer": JourneyPath(iconName: "iconCreator", [
            ("First Draft", "Design your first screen or page"),
            ("Daily Designer", "Design a little every day"),
            ("Layout Student", "Learn type, color and layout"),
            ("Prototyper", "Make an idea you can try"),
            ("User Tester", "Learn from people using it"),
            ("Systems Designer", "Make a design consistent"),
            ("Layout Master", "Finish a design you’re proud of")
        ]),
        "engineer": JourneyPath(iconName: "iconWrench", [
            ("First Build", "Build something small"),
            ("Tinkerer", "Learn how things work"),
            ("Apprentice", "Learn the fundamentals"),
            ("Maker", "Build something people can use"),
            ("Debugger", "Fix a hard problem"),
            ("Systems Thinker", "See the whole system"),
            ("Build Master", "Finish a build that works")
        ])
    ]
}
