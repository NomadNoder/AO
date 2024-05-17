math.randomseed(os.time()) -- Seed the random number generator

gameStates = gameStates or {}

-- Function to create a new game state for a player
function addPlayerGameState(playerName)
    gameStates[playerName] = {
        bulletPosition = math.random(1, 6),
        currentPosition = 1
    }
end

-- Function to end a player's game
function endGame(playerName)
    if gameStates[playerName] then
        gameStates[playerName] = nil
        print(playerName .. "'s game has ended and their state has been removed.")
    else
        print("No game state found for " .. playerName .. ".")
    end
end

-- Function to evaluate if a message should trigger the handler
local function isNewGameMessage(msg)
    if msg.Action == "PlayerMove" and msg.Direction == "StartGame" then
        print("This is a new game message")
        return true
    else
        return false
    end
end

Handlers.add(
    "PlayerMove",
    isNewGameMessage,
    function(msg)
        local playerName = msg.Player
        print(playerName .. " is attempting to start a game.")
        if gameStates[playerName] then
            print("Game already going")
            Send({
                Target = playerName,
                Action = "GameMessage",
                Data = "You already have an active game. You must finish it before starting a new one."
            })
        else
            addPlayerGameState(playerName)
            print(playerName .. " has started a game.")
            Send({
                Target = playerName,
                Action = "GameMessage",
                Data = "Game started! Type 'PullTrigger' to play."
            })
        end
    end
)

-- Function to handle pulling the trigger
local function isPullTriggerMessage(msg)
    if msg.Action == "PlayerMove" and msg.Direction == "PullTrigger" then
        print("This is a pull trigger message")
        return true
    else
        return false
    end
end

Handlers.add(
    "PlayerMove",
    isPullTriggerMessage,
    function(msg)
        local playerName = msg.Player
        local gameState = gameStates[playerName]

        if not gameState then
            Send({
                Target = playerName,
                Action = "GameMessage",
                Data = "You have no active game. Start one by sending 'StartGame' message."
            })
            return
        end

        print(playerName .. " pulls the trigger.")

        if gameState.currentPosition == gameState.bulletPosition then
            Send({
                Target = playerName,
                Action = "GameMessage",
                Data = "Bang! You're out. Game over."
            })
            endGame(playerName)
        else
            Send({
                Target = playerName,
                Action = "GameMessage",
                Data = "Click! You're safe. Next round."
            })
            gameState.currentPosition = gameState.currentPosition % 6 + 1
        end
    end
)

