//
//  JourneyChapterStars.swift
//  Asphyr
//

import Foundation

extension JourneyPath {
    /// Chapters 2 to 5 for each aspiration, as "Name|Goal", with one line per star
    /// of that chapter's constellation. Each grows from chapter 1 towards the
    /// aspiration without ever reaching it.
    static let laterChapters: [String: [[String]]] = [
        "game developer": [
            ["Daily Coder|Code a little each day", "Loop Maker|Tighten your core loop", "Input Tuner|Make controls feel sharp", "Asset Wrangler|Organize your game files", "Crash Fixer|Fix your worst crash", "Build Maker|Export a playable build", "Demo Sharer|Show a friend your demo", "Systems Master|Connect your game’s systems"],
            ["Story Sketcher|Give your game a story", "World Builder|Design a place to explore", "Enemy Designer|Create a fair challenge", "AI Tinkerer|Make enemies feel smart", "Boss Builder|Design a memorable boss", "Pacing Editor|Balance tension and rest", "Tutorial Writer|Teach without words", "Feedback Reader|Act on player notes", "World Master|Finish a complete world"],
            ["Art Direction|Choose a clear look", "Animator|Bring a character to life", "Sound Designer|Make actions feel loud", "Music Picker|Set the mood with music", "UI Crafter|Design a clear menu", "Juice Adder|Add satisfying effects", "Style Keeper|Keep your look consistent", "Trailer Maker|Show your game in a video", "Style Master|Finish a polished slice"],
            ["Store Page|Write your game’s page", "Launch Planner|Plan a small release", "Community Host|Gather your first players", "Patch Writer|Ship an update", "Dev Logger|Share your progress", "Mentor Dev|Help a new developer", "Studio Mindset|Think beyond one game"]
        ],
        "mechanical engineer": [
            ["Drive Learner|Learn how drives transfer power", "Linkage Builder|Build a moving linkage", "Bearing Student|Learn how bearings work", "Load Calculator|Calculate a simple load", "Fit Checker|Check how parts fit", "Assembly Tester|Test an assembly", "Motion Master|Design smooth motion"],
            ["Materials Student|Compare common materials", "Fastener Expert|Choose the right fastener", "Tolerance Reader|Read a tolerance", "Print Reader|Read an engineering drawing", "Shop Regular|Practice with a real tool", "Cost Counter|Estimate a part’s cost", "Failure Finder|Study a broken part", "Build Master|Make a part to spec"],
            ["Thermal Student|Learn how heat moves", "Fluid Thinker|Learn how fluids behave", "Simulation User|Run a simple simulation", "Test Planner|Plan a real test", "Data Reader|Learn from test results", "Design Reviewer|Critique a design", "Spec Writer|Write clear requirements", "Systems Master|Design a whole system"],
            ["Project Lead|Lead a small project", "Safety Checker|Review a design for safety", "Standards Reader|Learn one industry standard", "Field Visitor|See machines at work", "Portfolio Builder|Document your best work", "Shop Mentor|Teach someone a skill", "Design Mindset|Solve problems like a pro"]
        ],
        "psychologist": [
            ["Memory Student|Learn how memory works", "Attention Watcher|Learn what grabs attention", "Emotion Reader|Name emotions accurately", "Motivation Student|Learn what drives people", "Habit Studier|Learn how habits form", "Development Student|Study how people grow", "Social Observer|See how groups shape us", "Theory Comparer|Weigh two explanations", "Mind Master|Connect the core ideas"],
            ["Stress Student|Learn how stress works", "Self Carer|Practice looking after yourself", "Sleep Studier|Learn how sleep affects mood", "Anxiety Student|Understand anxiety", "Mood Student|Understand low mood", "Coping Coach|Learn a coping skill", "Ethics Reader|Learn the rules of care", "Boundary Keeper|Practice healthy boundaries", "Wellbeing Master|Understand mental health"],
            ["Open Questioner|Ask better questions", "Quiet Presence|Sit with silence", "Rapport Builder|Help someone feel at ease", "Reflective Voice|Reflect back what you hear", "Empathy Student|Understand without judging", "Story Hearer|Listen to a whole story", "Bias Checker|Notice your own bias", "Culture Student|Learn how culture shapes us", "Listening Master|Make someone feel heard"],
            ["Data Reader|Read a graph from a study", "Method Critic|Spot a flawed method", "Survey Writer|Write a fair question", "Paper Summarizer|Summarize a paper simply", "Field Explorer|Compare areas of psychology", "Mentor Finder|Learn from a practitioner", "Research Mindset|Think like a researcher"]
        ],
        "doctor": [
            ["Physiology Student|Learn how organs work together", "Pathology Student|Learn how disease develops", "Pharmacology Student|Learn how a drug works", "Lab Reader|Interpret a lab result", "Symptom Mapper|Link symptoms to causes", "Vital Signs|Learn what vitals reveal", "Case Reasoner|Reason through a case", "Evidence Reader|Read a clinical study", "Clinical Master|Think through a full case"],
            ["Long Study|Study through a hard stretch", "Exam Planner|Plan your revision", "Recall Trainer|Practice active recall", "Stamina Builder|Build longer study sessions", "Rest Keeper|Protect your sleep", "Stress Manager|Learn to handle pressure", "Mistake Reviewer|Learn from wrong answers", "Endurance Master|Keep a steady study pace"],
            ["Patient Listener|Hear what patients say", "Clear Explainer|Explain without jargon", "History Taker|Practice taking a history", "Exam Practicer|Practice a physical exam", "Calm Presence|Stay calm under pressure", "Hard Talks|Learn to share bad news", "Ethics Student|Think through an ethical case", "Care Teammate|Learn how care teams work", "Bedside Master|Earn a patient’s trust"],
            ["Specialty Explorer|Compare medical specialties", "Public Health|Learn how prevention works", "Global Health|See care around the world", "Shadow Student|Learn from a clinician", "Research Reader|Follow new medical research", "Volunteer|Help in your community", "Healer’s Mindset|Think about lifelong care"]
        ],
        "writer": [
            ["Line Editor|Cut every extra word", "Sound Checker|Read your work aloud", "Image Maker|Write one vivid image", "Rhythm Finder|Vary your sentences", "Voice Keeper|Sound like yourself", "Voice Master|Write a page only you could"],
            ["Idea Collector|Keep a notebook of ideas", "Character Builder|Create someone believable", "World Sketcher|Make a setting feel real", "Plot Weaver|Connect cause and effect", "Dialogue Writer|Make speech sound natural", "Tension Builder|Raise the stakes", "Theme Finder|Know what it’s about", "Mood Setter|Set a clear tone", "Craft Master|Finish a layered story"],
            ["Long Drafter|Work on something long", "Chapter Planner|Plan your next chapters", "Word Counter|Hit a weekly word count", "Block Breaker|Write through being stuck", "Midpoint Mover|Push past the middle", "Ending Finder|Write an ending that lands", "Second Drafter|Rewrite from the top", "Beta Reader|Learn from early readers", "Manuscript Master|Finish a long draft"],
            ["Submission Reader|Learn how publishing works", "Query Writer|Write a clear pitch", "Rejection Survivor|Keep going after a no", "Audience Finder|Find who your work is for", "Public Reader|Share your work out loud", "Writing Friend|Support another writer", "Author Mindset|Build a writing life"]
        ],
        "artist": [
            ["Form Student|Draw solid shapes", "Figure Drawer|Practice the human figure", "Perspective User|Draw depth correctly", "Value Student|Paint in light and dark", "Portrait Practicer|Capture a real face", "Anatomy Sketcher|Learn how bodies move", "Form Master|Draw with confidence"],
            ["Mood Maker|Make a piece feel something", "Story Painter|Tell a story in one image", "Series Starter|Start a connected series", "Style Tester|Try your own style", "Show and Tell|Share a finished piece", "Style Master|Make work that feels yours"],
            ["Large Canvas|Work bigger than usual", "Mixed Media|Combine two materials", "Texture Hunter|Bring texture to a surface", "Museum Visitor|Study art in person", "History Student|Learn an art movement", "Critique Partner|Trade honest feedback", "Reworker|Revisit an old piece", "Gallery Thinker|Plan how work is shown", "Body of Work|Finish a full series"],
            ["Portfolio Maker|Gather your best pieces", "Artist Statement|Explain what you make", "First Sale|Offer a piece to someone", "Commission Taker|Work for someone else", "Open Studio|Show your process", "Art Mentor|Help a new artist", "Lifelong Eye|Keep looking and learning"]
        ],
        "entrepreneur": [
            ["Market Reader|Learn who your customer is", "Niche Finder|Pick a focused audience", "Value Writer|State your value clearly", "Compass Setter|Write your long-term aim", "Priority Keeper|Choose what matters most", "Metric Picker|Track the right number", "Direction Master|Know where you’re heading"],
            ["First Version|Launch something small", "Tool Picker|Choose simple tools", "Process Builder|Write down a process", "Automator|Remove a repeated task", "Feedback Loop|Improve from customer notes", "Quality Keeper|Set a standard", "Product Master|Build something people return to"],
            ["Sales Practicer|Have a real sales talk", "Rejection Handler|Keep going after a no", "Cash Tracker|Know your money each week", "Budget Keeper|Plan your spending", "Price Tester|Try a new price", "Marketer|Test one marketing channel", "Partner Finder|Find a useful partner", "Growth Master|Grow for a full month"],
            ["First Hire|Learn how to delegate", "Team Builder|Work well with others", "Culture Keeper|Name what you value", "Investor Reader|Learn how funding works", "Legal Basics|Learn one legal basic", "Crisis Handler|Plan for what could go wrong", "Competitor Watcher|Learn from your rivals", "Network Builder|Meet people in your field", "Founder Mentor|Help another founder", "Founder Mindset|Think like a long-term owner"]
        ],
        "musician": [
            ["Rhythm Keeper|Practice with a metronome", "Tone Shaper|Work on your sound", "Dynamics Student|Play soft and loud", "Sight Reader|Read a new piece", "Technique Drills|Practice a hard exercise", "Memory Player|Play from memory", "Recording Listener|Hear yourself honestly", "Slow Practice|Master it slowly", "Technique Master|Play cleanly at speed"],
            ["Theory Student|Learn how chords work", "Key Explorer|Play in a new key", "Lyric Writer|Write words to a melody", "Hook Finder|Write a catchy idea", "Arranger|Add a second part", "Harmony Maker|Sing or play a harmony", "Home Recorder|Record your own song", "Producer|Mix a simple track", "Composition Master|Finish an original song"],
            ["Open Mic|Play for strangers", "Stage Presence|Connect with an audience", "Nerve Manager|Handle performance nerves", "Band Player|Play with others", "Listener Onstage|Respond to other players", "Set Builder|Plan a short set", "Song Teacher|Show someone a song", "Style Student|Study a great musician", "Performance Master|Play a full set"],
            ["Performance Sharer|Post a performance", "Gig Planner|Book a small gig", "Music Business|Learn how musicians earn", "Collaborator|Make music with someone new", "Teacher|Help a beginner", "Listener for Life|Explore new music", "Musician’s Mindset|Build a life in music"]
        ],
        "athlete": [
            ["Strength Base|Build basic strength", "Mobility Work|Improve your range", "Core Builder|Train your core", "Speed Work|Add a fast session", "Sleep Keeper|Protect your sleep", "Fuel Planner|Eat for your training", "Hydration Check|Build a water habit", "Rest Day Pro|Take recovery seriously", "Foundation Master|Train strong for a month"],
            ["Goal Setter|Set a real target", "Interval Runner|Push hard, then recover", "Pace Keeper|Hold a steady pace", "Weak Spot Worker|Train what you avoid", "Mental Rehearser|Picture your best effort", "Pressure Trainer|Practice under pressure", "Tracker|Log your sessions", "Personal Best|Beat an old number", "Injury Avoider|Warm up properly", "Performance Master|Hit a hard target"],
            ["First Event|Sign up for an event", "Race Planner|Plan your event day", "Taper Student|Learn to ease off", "Nerves Manager|Stay calm before starting", "Tactics Student|Study how experts compete", "Teammate|Train with someone", "Coach Finder|Get expert feedback", "Bounce Back|Learn from a bad result", "Competition Master|Finish an event you trained for"],
            ["Season Planner|Plan your whole season", "Training Partner|Push someone else forward", "Young Coach|Help a beginner", "Film Reviewer|Study your own footage", "Longevity Student|Train to last for years", "Community Runner|Join a local group", "Athlete’s Mindset|Make training your identity"]
        ],
        "teacher": [
            ["Student Watcher|Notice who’s struggling", "Patience Practice|Explain it a second way", "Encourager|Give specific praise", "Inclusive Planner|Plan for different learners", "Behavior Student|Learn calm classroom habits", "Parent Talker|Communicate with families", "Trust Builder|Earn a learner’s trust", "Feedback Giver|Give useful feedback", "Care Master|Support every learner"],
            ["Goal Writer|Write clear lesson goals", "Year Planner|Map out a term", "Assessment Designer|Check real understanding", "Pacing Keeper|Plan your timing", "Resource Finder|Build a teaching library", "Reflection Keeper|Review how lessons went", "Direction Master|Know where a course leads"],
            ["Storyteller|Teach through a story", "Voice Coach|Use your voice with care", "Discussion Host|Run a good discussion", "Curiosity Sparker|Open with a question", "Demo Maker|Show it in real life", "Engagement Master|Keep a whole room engaged"],
            ["Peer Observer|Learn from a colleague", "Curriculum Thinker|Improve an existing course", "Workshop Leader|Teach other teachers", "Ed Reader|Follow teaching research", "Tech User|Try a new teaching tool", "Community Link|Connect learning to real life", "Student Mentor|Guide someone long term", "Educator’s Mindset|Keep learning how to teach"]
        ],
        "designer": [
            ["Brief Reader|Understand the real problem", "Sketch First|Explore ideas on paper", "Grid User|Lay out with a grid", "Type Pairer|Choose fonts that work", "Color Picker|Build a clear palette", "Icon Drawer|Draw a simple icon set", "Accessibility Check|Design for everyone", "Motion Student|Add purposeful motion", "Visual Master|Make a clear, beautiful page"],
            ["Researcher|Interview a real user", "Flow Mapper|Map a task end to end", "Usability Tester|Watch someone try it", "Copy Writer|Write clear interface words", "Iterator|Improve from what you learn", "Experience Master|Solve a real user problem"],
            ["Component Builder|Make reusable parts", "Token Keeper|Define your styles", "Handoff Writer|Explain a design to builders", "Developer Friend|Learn how it gets built", "Critique Host|Run a design review", "Case Writer|Tell the story of a project", "Systems Master|Build a small design system"],
            ["Portfolio Maker|Show your best projects", "Client Listener|Understand what people need", "Pitch Presenter|Present your reasoning", "Trend Reader|Learn what’s changing", "Team Designer|Design with others", "Design Mentor|Review a beginner’s work", "Designer’s Mindset|See design everywhere"]
        ],
        "engineer": [
            ["Measure First|Measure before you build", "Math Refresher|Review a math basic", "Safety Student|Learn a safety rule", "Spec Reader|Read a technical spec", "Fundamentals Master|Know why it works"],
            ["System Mapper|Draw how parts connect", "Data Logger|Measure how it behaves", "Failure Student|Study a famous failure", "Test Writer|Write a real test", "Root Cause|Fix the cause, not the symptom", "Tradeoff Weigher|Compare two designs", "Docs Writer|Document what you built", "Reliability Master|Build something dependable"],
            ["Code Reviewer|Review someone’s work", "Scale Thinker|Plan for growth", "Cost Counter|Weigh cost against benefit", "Project Planner|Estimate a real project", "Team Builder|Build something together", "Requirement Writer|Define what’s needed", "User Listener|Learn what users need", "Delivery Master|Ship a complete project"],
            ["Standards Reader|Learn a field standard", "Ethics Thinker|Consider who it affects", "Tech Watcher|Learn what’s emerging", "Portfolio Builder|Document your best work", "Tech Talker|Explain your work simply", "Engineering Mentor|Help a newer engineer", "Engineer’s Mindset|Solve problems for life"]
        ]
    ]
}
