  
import Foundation
import Curses

// Define interrupt handler to terminate Curses with CTRL-C
class Handler : CursesHandlerProtocol {
    func interruptHandler() {
        screen.shutDown()
        print("Forcefully exited program, execute run to restart")
        exit(0)
    }

    func windowChangedHandler() {
    }
}

let gridSize = 9

var grid = [[Cell]]()
for rowNum in  0..<gridSize {
    grid.append([])
    for colNum in 0..<gridSize {
        grid[rowNum].append(Cell(row:rowNum,col:colNum))
    }
}

// Start up Curses
let screen = Screen.shared
screen.startUp(handler:Handler())
let mainWindow = screen.window
let cursor = mainWindow.cursor
mainWindow.cursor.position = Point(x:0, y:0)
let keyboard = Keyboard.shared
//Start up Colors
let colors = Colors.shared
precondition(colors.areSupported, "This terminal doesn't support colors")
colors.startUp()
mainWindow.cursor.set(style: .invisible)
public enum StandardColor : String, CaseIterable {
    case black
    case red
    case green
    case yellow
    case blue
    case magenta
    case cyan
    case white
}
let red = Color.standard(.red)
let black = Color.standard(.black)
let redOnBlack = colors.newPair(foreground:red, background:black)
//////

var board = Board(grid:grid, highlightColor:redOnBlack)

//Chat
func msg(_ msg:String) {
    mainWindow.cursor.pushPosition(newPosition:Point(x:0, y:1))
    mainWindow.clearToEndOfLine()
    mainWindow.write("\(msgCount)) " + msg)
    msgCount += 1
    mainWindow.cursor.popPosition()
}


var msgCount = 0
let beginMsg = "Sudoku Board "
mainWindow.write(beginMsg)
mainWindow.turnOn(Attribute.dim)
mainWindow.cursor.pushPosition(newPosition:Point(x:beginMsg.count, y:0))
mainWindow.write(" v1.0b")
mainWindow.cursor.popPosition()
mainWindow.turnOff(Attribute.dim)
msg("Note: Upgrade to the premium package to get colors")

func checkWindowSize(size:Int) -> Bool {
    let fullSize = size*gridSize
    if ((fullSize+(board.squareHeightGap*4) <= mainWindow.size.height) && (fullSize+(board.squareLengthGap*4) <= mainWindow.size.width)) {
        return true
    } else {
        return false
    }
}
//Display the guide 
var showGuide = false
func turnOnGuide() {
    msg("Displaying Help Guide 1/1, press h to exit")
    mainWindow.cursor.pushPosition(newPosition:Point(x:0, y:3))
    mainWindow.write("Help Guide: \ne to exit \n+ and - to resize Sudoku Board \n↑ ↓ → ← to navigate the Sudoku Board \n1-9 to input numbers into the cell \nbackspace or 0 to remove numbers from cell \nh to open/exit the help guide \nctrl-c to forcefully close")
    mainWindow.cursor.popPosition()
    board.render(mainWindow:mainWindow)
}
func turnOffGuide() {
    mainWindow.clear()
    board.render(mainWindow:mainWindow)
    msg("Exited Help Guide")
}

//Checking the board size and shrinking it till it fits then it will print

while board.cellSize > 1 {
    if checkWindowSize(size:board.cellSize+1) {
        board.render(mainWindow:mainWindow)
        break
    } else {
        board.resize(-1)
    }
    msg("The board has been shrunk to fit the window")
}
if checkWindowSize(size:board.cellSize+1) == false {
    msg("The current window is too small, resize the window and rerun")
}


//Loop until key press
let errorMsg = " is an invalid key sequence, press h for help"
while true {
// assinging an Int value to the array in the board in each cell
    let key = keyboard.getKey(window:mainWindow)
    if key.keyType == .isCharacter {
        switch (key.character!) {
        case "0":
            msg("Emptied cell (\(board.cursorRow + 1),\(board.cursorCol + 1)).")
            board.clearHere()
            board.render(mainWindow:mainWindow)
        case "1"..."9":
            msg("Entered \(Int(String(key.character!))!) into cell (\(board.cursorRow + 1),\(board.cursorCol + 1)). Press backspace or 0 to remove.")
            board.inputHere(Int(String(key.character!))!)
            board.render(mainWindow:mainWindow)
        case "+":
            guard checkWindowSize(size:board.cellSize+2) else {
                msg("The screen can not fit a larger board")
                continue
            }
            mainWindow.clear()
            board.resize(1)
            board.render(mainWindow:mainWindow)
            msg("Enlarged Sudoku Board to Size[\(board.cellSize)]    Tip: Zoom in with emacs instead")
        case "-":
            mainWindow.clear()
            board.resize(-1)
            board.render(mainWindow:mainWindow)
            msg("Reduced Sudoku Board to Size[\(board.cellSize)]    Tip: Zoom out with emacs instead")
        case "h":
            showGuide = !showGuide
            if showGuide {
                turnOnGuide()
            } else {
                turnOffGuide()
            }
        case "e":
            screen.shutDown()
            exit(0)
        default:
            msg("\(key.character!)"  + errorMsg)
        }

    } else if key.keyType == .isControl {
        msg("ctrl-\(key.control!)" + errorMsg)
    } else {
        // Resizing the board using different keys 
        switch (key.keyType) {
        case .arrowDown:
            guard board.cursorRow + 1 <= 8 else {
                msg("You can not move down any further")
                continue
            }
            board.cursorRow += 1
            msg("Moved down to cell (\(board.cursorRow + 1),\(board.cursorCol + 1))")
            board.render(mainWindow:mainWindow)
        case .arrowUp:
            guard board.cursorRow - 1 >= 0 else {
                msg("You can not move up any further")
                continue
            }
            board.cursorRow -= 1
            msg("Moved down to cell (\(board.cursorRow + 1),\(board.cursorCol + 1))")
            board.render(mainWindow:mainWindow)
        case .arrowRight:
            guard board.cursorCol + 1 <= 8 else {
                msg("You can not move right any further")
                continue
            }
            board.cursorCol += 1
            msg("Moved down to cell (\(board.cursorRow + 1),\(board.cursorCol + 1))")
            board.render(mainWindow:mainWindow)
        case .arrowLeft:
            guard board.cursorCol - 1 >= 0 else {
                msg("You can not move left any further")
                continue
            }
            board.cursorCol -= 1
            msg("Moved down to cell (\(board.cursorRow + 1),\(board.cursorCol + 1))")
            board.render(mainWindow:mainWindow)
        case .backspace:
            msg("Emptied cell (\(board.cursorRow + 1),\(board.cursorCol + 1))")
            board.clearHere()
            board.render(mainWindow:mainWindow)
        case .enter:
            msg("One day I'll actually let it calculate it. Not today.")

        default:
            msg("That" + errorMsg)

        }
    }
}
