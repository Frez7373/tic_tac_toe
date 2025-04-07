-- server.lua (Server Side)
local modem = peripheral.find("modem")  -- Find connected modem
if not modem then
    print("No modem connected!")
    return
end

modem.open(123)  -- Open a channel for communication (e.g., 123)

-- Function to start the game
local function startGame()
    print("Waiting for opponent to connect...")

    -- Wait for the second player to connect
    local sender, message = os.pullEvent("modem_message")
    if message == "connected" then
        print("Opponent connected! Starting game...")
        modem.send(sender, 123, "start_game")
        gameLoop(sender)
    else
        print("Error: No opponent connected.")
    end
end

-- Main Game Loop
local function gameLoop(player)
    local board = {{" ", " ", " "}, {" ", " ", " "}, {" ", " ", " "}}  -- Tic-Tac-Toe Board
    local currentPlayer = "X"  -- First player is "X"

    -- Display the board
    local function displayBoard()
        for i = 1, 3 do
            print(table.concat(board[i], " | "))
            if i < 3 then print("--------") end
        end
    end

    while true do
        displayBoard()

        -- Wait for the player to make a move
        modem.send(player, 123, "your_turn")
        local sender, move = os.pullEvent("modem_message")

        if sender == player then
            local row, col = move[1], move[2]
            if board[row][col] == " " then
                board[row][col] = currentPlayer
                currentPlayer = currentPlayer == "X" and "O" or "X"
            else
                modem.send(player, 123, "invalid_move")
            end
        end

        -- Check for winner (simplified)
        if checkWinner(board) then
            displayBoard()
            print(currentPlayer .. " wins!")
            break
        end
    end
end

-- Check for a winner
local function checkWinner(board)
    -- Check rows, columns, and diagonals
    for i = 1, 3 do
        if board[i][1] == board[i][2] and board[i][2] == board[i][3] and board[i][1] ~= " " then
            return true
        end
        if board[1][i] == board[2][i] and board[2][i] == board[3][i] and board[1][i] ~= " " then
            return true
        end
    end
    if board[1][1] == board[2][2] and board[2][2] == board[3][3] and board[1][1] ~= " " then
        return true
    end
    if board[1][3] == board[2][2] and board[2][2] == board[3][1] and board[1][3] ~= " " then
        return true
    end
    return false
end

startGame()
