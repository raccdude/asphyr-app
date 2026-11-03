//
//  DailyQuests.swift
//  Asphyr
//

import Foundation

/// The system's daily quests, written for each aspiration and archetype, with a
/// different one each day. Custom aspirations and Login use the general set.
enum DailyQuests {
    private typealias Entry = (title: String, description: String)
    private typealias Pool = (category: String, quests: [Archetype: [Entry]])

    /// A new daily quest for that day. The archetype shapes the objective and
    /// its main attribute, and the aspiration's category gives the second.
    static func quest(aspiration: String?, archetype: Archetype?, on date: Date) -> Quest {
        let archetype = archetype ?? .explorer
        let key = aspiration?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        let pool = pools[key] ?? general
        let entries = pool.quests[archetype] ?? []
        let day = Int(Calendar.current.startOfDay(for: date).timeIntervalSinceReferenceDate / 86_400)
        let entry = entries[((day % entries.count) + entries.count) % entries.count]

        return Quest(
            type: .dailyQuest,
            title: entry.title,
            description: entry.description,
            objective: objective(for: archetype),
            iconName: JourneyPath.path(for: aspiration).stars[2].iconName,
            category: pool.category.uppercased(),
            difficulty: .moderate,
            durationMinutes: 30,
            xpReward: RewardRules.xp(minutes: 30, difficulty: .moderate),
            attributeRewards: attributes(archetype: archetype, category: pool.category),
            status: .available,
            generatedOn: date
        )
    }

    private static func objective(for archetype: Archetype) -> String {
        switch archetype {
        case .strategist: "Decide your approach first, then follow your plan."
        case .scholar: "Learn it well enough to explain it to someone."
        case .creator: "Finish with something you can show."
        case .explorer: "Try an approach you haven’t used before."
        }
    }

    private static func attributes(archetype: Archetype, category: String) -> [AttributeReward] {
        let main: String
        switch archetype {
        case .strategist: main = "PROBLEM SOLVING"
        case .scholar: main = "KNOWLEDGE"
        case .creator: main = "CREATIVITY"
        case .explorer: main = "DISCIPLINE"
        }

        let fromCategory = RewardRules.attributes(category: category, difficulty: .moderate).map(\.name)
        let second = fromCategory.first { $0 != main } ?? (main == "DISCIPLINE" ? "KNOWLEDGE" : "DISCIPLINE")
        return [AttributeReward(name: main, value: 5), AttributeReward(name: second, value: 2)]
    }

    private static let general: Pool = ("Other", [
        .strategist: [
            ("MAP YOUR NEXT MONTH", "Choose one goal and the steps to reach it."),
            ("FIND YOUR BOTTLENECK", "Work out what’s slowing your progress most."),
            ("REVIEW YOUR WEEK", "See what worked and what to change.")
        ],
        .scholar: [
            ("LEARN ONE NEW CONCEPT", "Pick something in your field you can’t explain yet."),
            ("READ AN EXPERT’S ADVICE", "Note the three most useful points."),
            ("TEACH YOURSELF A BASIC", "Go back to a fundamental you skipped.")
        ],
        .creator: [
            ("MAKE A SMALL THING", "Create something related to your goal."),
            ("SKETCH YOUR IDEA", "Get a rough version out of your head."),
            ("IMPROVE PAST WORK", "Take something old and make it better.")
        ],
        .explorer: [
            ("TRY A NEW METHOD", "Do a familiar task in an unfamiliar way."),
            ("ASK SOMEONE AHEAD OF YOU", "Find out what they wish they’d known."),
            ("SAMPLE A NEW CORNER", "Explore a part of your field you’ve never tried.")
        ]
    ])

    private static let pools: [String: Pool] = [
        "game developer": ("Development", [
            .strategist: [
                ("PLAN A CORE LOOP", "Map what players do again and again."),
                ("SCOPE A TINY GAME", "Cut an idea down to one week of work."),
                ("BALANCE ONE MECHANIC", "Decide the numbers that make it fair.")
            ],
            .scholar: [
                ("STUDY A FAVORITE GAME", "Work out why one mechanic feels good."),
                ("LEARN A GAME PATTERN", "Read about one common code pattern."),
                ("BREAK DOWN A LEVEL", "Note how a great level teaches its player.")
            ],
            .creator: [
                ("BUILD A SMALL MECHANIC", "Turn a simple idea into a working feature."),
                ("DESIGN ONE CHARACTER", "Give it a look and a way to move."),
                ("MAKE A ONE-ROOM LEVEL", "Build one small space worth playing.")
            ],
            .explorer: [
                ("TRY A NEW GENRE", "Play something unlike what you usually make."),
                ("TEST A STRANGE IDEA", "Prototype a rule no game you know uses."),
                ("TRY A NEW ENGINE FEATURE", "Use a tool you’ve never opened.")
            ]
        ]),
        "mechanical engineer": ("Development", [
            .strategist: [
                ("PLAN A SIMPLE ASSEMBLY", "List its parts and the build order."),
                ("COMPARE TWO MATERIALS", "Choose one for a job and explain why."),
                ("FIND A WEAK POINT", "Work out where a design would fail first.")
            ],
            .scholar: [
                ("STUDY HOW GEARS WORK", "Learn how ratios change speed and force."),
                ("REVIEW STRESS AND STRAIN", "Work through one example by hand."),
                ("LEARN A MECHANISM", "Find out how a common machine moves.")
            ],
            .creator: [
                ("SKETCH A MECHANISM", "Draw a part that turns motion into work."),
                ("MODEL A SIMPLE PART", "Draft a bracket or hinge in detail."),
                ("BUILD A PAPER PROTOTYPE", "Test a moving idea with card and pins.")
            ],
            .explorer: [
                ("TAKE SOMETHING APART", "Open an old object and see how it works."),
                ("SPOT MACHINES AROUND YOU", "Work out how one everyday device moves."),
                ("TRY A NEW CAD TOOL", "Use a feature you’ve never touched.")
            ]
        ]),
        "psychologist": ("Learning", [
            .strategist: [
                ("DESIGN A SMALL STUDY", "Choose a question and how you’d test it."),
                ("MAP A THOUGHT PATTERN", "Trace how one belief shapes a behavior."),
                ("PLAN A HABIT CHANGE", "Use a known technique on one habit.")
            ],
            .scholar: [
                ("READ ABOUT A BIAS", "Learn one cognitive bias and an example."),
                ("SUMMARIZE A CLASSIC STUDY", "Note what it found and its limits."),
                ("COMPARE TWO THEORIES", "See where they agree and disagree.")
            ],
            .creator: [
                ("WRITE A CASE VIGNETTE", "Describe a fictional person and their struggle."),
                ("EXPLAIN A CONCEPT SIMPLY", "Make one idea clear for a friend."),
                ("KEEP A MOOD JOURNAL", "Record what shifted your mood today.")
            ],
            .explorer: [
                ("WATCH BEHAVIOR IN PUBLIC", "Notice one pattern in how people act."),
                ("PRACTICE ACTIVE LISTENING", "Try it in one real conversation."),
                ("TRY A MINDFULNESS EXERCISE", "Note what you notice in yourself.")
            ]
        ]),
        "doctor": ("Learning", [
            .strategist: [
                ("PLAN YOUR STUDY WEEK", "Divide one topic into daily sessions."),
                ("WORK THROUGH A CASE", "Reason from symptoms to a likely cause."),
                ("BUILD A DIAGNOSIS CHART", "Compare conditions with similar symptoms.")
            ],
            .scholar: [
                ("STUDY ONE BODY SYSTEM", "Learn how its main parts work together."),
                ("LEARN TEN TERMS", "Master ten medical terms from one topic."),
                ("REVIEW ONE CONDITION", "Learn its causes, signs and treatment.")
            ],
            .creator: [
                ("DRAW AN ANATOMY DIAGRAM", "Sketch and label one system from memory."),
                ("MAKE FLASHCARDS", "Create a set for a topic you find hard."),
                ("WRITE A PATIENT EXPLANATION", "Explain a condition in plain language.")
            ],
            .explorer: [
                ("READ ABOUT A SPECIALTY", "Learn what a day in it looks like."),
                ("LEARN A FIRST AID SKILL", "Pick one you don’t already know."),
                ("TALK WITH A HEALTH WORKER", "Ask what surprised them about the job.")
            ]
        ]),
        "writer": ("Creative", [
            .strategist: [
                ("OUTLINE A SHORT STORY", "Plan its beginning, middle and end."),
                ("MAP A CHARACTER ARC", "Decide how someone changes and why."),
                ("PLAN A REVISION", "List what one draft needs most.")
            ],
            .scholar: [
                ("STUDY A GREAT OPENING", "Work out why one first page hooks you."),
                ("LEARN A STRUCTURE", "Read about one way stories are built."),
                ("ANALYZE A SCENE", "Note how a writer builds its tension.")
            ],
            .creator: [
                ("WRITE ONE SCENE", "Put two characters in a tense moment."),
                ("WRITE 300 WORDS", "Draft without stopping to edit."),
                ("REWRITE A PARAGRAPH", "Make one of your own passages sharper.")
            ],
            .explorer: [
                ("WRITE IN A NEW GENRE", "Draft a short piece outside your usual style."),
                ("WRITE FROM A STRANGER’S VIEW", "Imagine someone you noticed today."),
                ("USE A RANDOM PROMPT", "Start from a word you didn’t choose.")
            ]
        ]),
        "artist": ("Creative", [
            .strategist: [
                ("PLAN A COMPOSITION", "Make three thumbnails and choose one."),
                ("BUILD A COLOR PALETTE", "Pick colors for a mood and test them."),
                ("SET A SERIES THEME", "Plan three pieces that belong together.")
            ],
            .scholar: [
                ("STUDY AN ARTIST YOU LOVE", "Note how they use light and color."),
                ("LEARN A SHADING TECHNIQUE", "Practice it on one simple object."),
                ("COPY A MASTER’S DETAIL", "Learn by redrawing one small section.")
            ],
            .creator: [
                ("DRAW FROM LIFE", "Sketch one object in front of you."),
                ("FINISH A SMALL PIECE", "Take one idea from start to done."),
                ("PAINT A MOOD", "Show one feeling using only color.")
            ],
            .explorer: [
                ("TRY A NEW MEDIUM", "Use a material you’ve never worked with."),
                ("DRAW WITHOUT LOOKING", "See what your hand does on its own."),
                ("SKETCH OUTDOORS", "Capture something outside your usual space.")
            ]
        ]),
        "entrepreneur": ("Career", [
            .strategist: [
                ("MAP YOUR COMPETITORS", "Compare three and find what’s missing."),
                ("WORK OUT YOUR PRICING", "Estimate your costs and a fair price."),
                ("SET ONE QUARTERLY GOAL", "Choose the number that matters most.")
            ],
            .scholar: [
                ("STUDY A FOUNDER’S STORY", "Note one decision that changed everything."),
                ("LEARN ONE BUSINESS MODEL", "See how a company you use makes money."),
                ("LEARN A FINANCE BASIC", "Understand cash flow or margin.")
            ],
            .creator: [
                ("WRITE A ONE-LINE PITCH", "Say who it’s for and why it matters."),
                ("MOCK UP YOUR OFFER", "Make a simple page describing your idea."),
                ("DRAFT A CUSTOMER EMAIL", "Write to someone who has the problem.")
            ],
            .explorer: [
                ("TALK TO A CUSTOMER", "Ask one person about their problem."),
                ("FIND A NEW PROBLEM", "List three annoyances you noticed today."),
                ("TEST AN IDEA CHEAPLY", "Find the smallest way to learn if it works.")
            ]
        ]),
        "musician": ("Creative", [
            .strategist: [
                ("PLAN A PRACTICE ROUTINE", "Split your time across three skills."),
                ("BREAK DOWN A HARD PASSAGE", "Find the exact bars holding you back."),
                ("MAP A SONG’S STRUCTURE", "Chart its sections and changes.")
            ],
            .scholar: [
                ("LEARN A SCALE", "Master one scale slowly and evenly."),
                ("STUDY A CHORD PROGRESSION", "Find out why it sounds the way it does."),
                ("LISTEN CLOSELY TO A SONG", "Follow one instrument from start to end.")
            ],
            .creator: [
                ("WRITE A SHORT MELODY", "Compose eight bars you can hum."),
                ("ARRANGE A FAVORITE SONG", "Make it your own with one big change."),
                ("RECORD A SHORT TAKE", "Play something and keep the recording.")
            ],
            .explorer: [
                ("PLAY A NEW GENRE", "Learn a groove from unfamiliar music."),
                ("IMPROVISE FOR A WHILE", "Play with no plan and no page."),
                ("TRY A NEW SOUND", "Experiment with a technique you’ve avoided.")
            ]
        ]),
        "athlete": ("Health", [
            .strategist: [
                ("PLAN YOUR TRAINING WEEK", "Balance hard days, easy days and rest."),
                ("SET A MEASURABLE GOAL", "Choose a target and test it today."),
                ("REVIEW YOUR RECOVERY", "Check your sleep, food and rest.")
            ],
            .scholar: [
                ("STUDY YOUR TECHNIQUE", "Watch an expert and note one difference."),
                ("LEARN ONE MUSCLE GROUP", "Find out how it works and trains."),
                ("READ ABOUT RECOVERY", "Learn one thing that speeds it up.")
            ],
            .creator: [
                ("DESIGN A WORKOUT", "Build your own 30-minute session."),
                ("FILM YOUR FORM", "Record a movement and review it."),
                ("MAKE A WARM-UP ROUTINE", "Create one you’ll want to repeat.")
            ],
            .explorer: [
                ("TRY A NEW EXERCISE", "Add one movement you’ve never done."),
                ("TRAIN SOMEWHERE NEW", "Take your session to a different place."),
                ("TRY ANOTHER SPORT’S DRILL", "See what it teaches you about yours.")
            ]
        ]),
        "teacher": ("Career", [
            .strategist: [
                ("PLAN A LESSON", "Set one goal and a way to check it."),
                ("MAP A UNIT", "Order five lessons so each builds on the last."),
                ("DESIGN A SHORT QUIZ", "Write questions that reveal understanding.")
            ],
            .scholar: [
                ("STUDY A TEACHING METHOD", "Learn one way to help ideas stick."),
                ("DEEPEN YOUR SUBJECT", "Learn something beyond what you’d teach."),
                ("READ HOW PEOPLE LEARN", "Note one idea you can use.")
            ],
            .creator: [
                ("MAKE A CLASS ACTIVITY", "Turn one idea into something hands-on."),
                ("DRAW A TEACHING DIAGRAM", "Explain a hard idea with a picture."),
                ("WRITE A GOOD ANALOGY", "Connect a hard concept to everyday life.")
            ],
            .explorer: [
                ("EXPLAIN SOMETHING TO A FRIEND", "See where they get confused."),
                ("WATCH ANOTHER TEACHER", "Note one thing they do differently."),
                ("TRY A NEW FORMAT", "Teach an idea through a game or story.")
            ]
        ]),
        "designer": ("Creative", [
            .strategist: [
                ("MAP A USER FLOW", "Plan every step of one simple task."),
                ("AUDIT A SCREEN", "List what makes it hard to use."),
                ("SET A TYPE SCALE", "Choose sizes that work together.")
            ],
            .scholar: [
                ("STUDY A DESIGN YOU LOVE", "Work out why its layout feels right."),
                ("LEARN A TYPE PRINCIPLE", "Practice one rule on a real example."),
                ("READ ABOUT COLOR CONTRAST", "Check one design against what you learn.")
            ],
            .creator: [
                ("REDESIGN A SMALL SCREEN", "Improve one app screen you use daily."),
                ("MAKE A BUTTON SET", "Design every state of one button."),
                ("DESIGN A POSTER", "Say one thing with type alone.")
            ],
            .explorer: [
                ("TRY AN UNFAMILIAR STYLE", "Design in a look you’d never choose."),
                ("WATCH SOMEONE USE AN APP", "Note where they hesitate."),
                ("TRY A NEW DESIGN TOOL", "Use a feature you’ve never opened.")
            ]
        ]),
        "engineer": ("Development", [
            .strategist: [
                ("BREAK DOWN A PROBLEM", "Split one big task into small parts."),
                ("WEIGH TWO SOLUTIONS", "List the tradeoffs and choose one."),
                ("PLAN A SMALL SYSTEM", "Draw its parts and how they connect.")
            ],
            .scholar: [
                ("LEARN ONE CORE CONCEPT", "Pick a fundamental you’ve been avoiding."),
                ("STUDY HOW SOMETHING WORKS", "Trace one everyday system end to end."),
                ("WORK A PRACTICE PROBLEM", "Solve one by hand before checking.")
            ],
            .creator: [
                ("BUILD A SMALL TOOL", "Make something that saves you a step."),
                ("IMPROVE AN OLD PROJECT", "Fix one thing you’ve been meaning to."),
                ("MAKE A WORKING MODEL", "Test an idea with something real.")
            ],
            .explorer: [
                ("TRY A NEW TOOL", "Use something unfamiliar for a small job."),
                ("INVESTIGATE A FAILURE", "Find out why something broke."),
                ("EXPLORE ANOTHER FIELD", "See how a different kind of engineer works.")
            ]
        ])
    ]
}
