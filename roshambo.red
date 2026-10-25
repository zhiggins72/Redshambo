Red [
    Title: "Redshambo"
    Author: "Zachary Higgins"
    Version. 1.0.0
	Needs: 'View
	Config: [GUI-engine: 'terminal]
]

;without random/seed, you always get the same result
random/seed now/time
;initals for scoreboard
initials: ""
;for the bot to choose a weapon
weapons: [rock paper scissors]
winStreak: 0
bot: none

;for saving/retrieving highscores
gameDir: dirize to-file rejoin [get-env "HOME" "/.Roshambo/"]
scoresFile: append copy gameDir %scores.red

if not exists? gameDir [make-dir gameDir]
;initialize scoreboard
scoreboard: [
    []
    []
    []
]
;retrieves scores if a scoreboard is saved in scoresFile already
if exists? scoresFile [
    scoreboard: load scoresFile
]
updateInitials: does [
    view [
        text "New highscore! Enter your initials: "
        fieldInitials: field 3x1 initials
        button "Complete" [
            initials: uppercase initials
            unview face/parent
        ]
    ]
]
updateScoreboard: func [streak][
    if streak = 0 [exit]
    either empty? scoreboard/3 [
        ;view [
        ;    text "New highscore! Enter your initials: "
        ;    fieldInitials: field 3x1 initials
        ;    button "Complete" [unview face/parent]
        ;]
        updateInitials
        ;initials: uppercase copy/part trim ask "New highscore! Enter your initials: " 3
        append scoreboard/3 streak
        append scoreboard/3 now/date
        append scoreboard/3 initials
    ][
        if streak > scoreboard/3/1 [ 
            updateInitials
            ;initials: uppercase copy/part trim ask "New highscore! Enter your initials: " 3
            scoreboard/3/1: streak
            scoreboard/3/2: now/date
            scoreboard/3/3: initials
        ]
    ]
    sort/reverse scoreboard
    save scoresFile scoreboard
    showScoreboard
]

showScoreboard: does [
    foreach i [1 2 3] [
        entry: scoreboard/:i ;if i = 1 entry gets set to scoreboard/1 etc.
        face: get pick [s1 s2 s3] i
        face/text: either empty? entry [
            rejoin [i ". ---"]
        ][
            rejoin [i ". " entry/1 " wins - " entry/2 " - " entry/3]
        ]
    ]
]
    
setBot: does [
    bot: pick weapons random length? weapons
]

updateWinStreak: func [result][
    case [
        result = 1 [winStreak: winStreak + 1]
        result = 0 [winStreak: 0]
        ;it's a tie - do nothing
        result = 2 []
    ]
]

getResult: func [player bot /local result][
    case [
        same? player bot [gameText/text: rejoin ["Bot chooses " bot ". It's a tie!"]    result: 2]
        all [player = 'rock    bot = 'paper][
            gameText/text: "Bot chooses paper. Paper covers rock. You lose!"      
            result: 0
        ]
        all [player = 'rock    bot = 'scissors][
            gameText/text: "Bot chooses scissors. Rock smashes scissors. You win!" 
            result: 1
        ]
        all [player = 'paper   bot = 'rock][
            gameText/text: "Bot chooses rock. Paper covers rock. You win!"         
            result: 1
        ]
        all [player = 'paper   bot = 'scissors][
            gameText/text: "Bot chooses scissors. Scissors cuts paper. You lose!"  
            result: 0
        ]
        all [player = 'scissors bot = 'rock][
            gameText/text: "Bot chooses rock. Rock smashes scissors. You lose!"   
            result: 0
        ]
        all [player = 'scissors bot = 'paper][
            gameText/text: "Bot chooses paper. Scissors cut paper. You win!"      
            result: 1
        ]
    ]
    if result = 0 [updateScoreboard winStreak]  ; only on loss, before streak resets
    updateWinStreak result
    playAgain/text: rejoin ["Pick a weapon to play again. Current win streak: " winStreak]
]

view [
    gameText: text 60x1 "Choose your weapon and battle the bot!"
    return
    playAgain: text 60x1 ""
    return
    rockb: button "rock" [
        setBot
        getResult 'rock bot
    ]
    paperb: button "paper" [
        setBot
        getResult 'paper bot
    ]
    scissorb: button "scissors" [
        setBot
        getResult 'scissors bot
    ]
    return
    highScores: group-box " Highscores " 35x7 options [border-corners: round][
        below
        s1: text 33x1 "1. ---"
        s2: text 33x1 "2. ---"
        s3: text 33x1 "3. ---"
    ]
    do [showScoreboard]
]
