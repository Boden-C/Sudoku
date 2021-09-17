   
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

let squareLengthGap = 2
let squareHeightGap = 1
let gridSize = 9
var cellSize = 3
var cursorPosRow = 0
var cursorPosCol = 0

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
//Stat up Colors
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
mainWindow.write(" v1.0a")
mainWindow.cursor.popPosition()
mainWindow.turnOff(Attribute.dim)
msg("Note: Upgrade to the premium package to get colors")

func checkWindowSize(size:Int) -> Bool {
    let fullBoardSize = size*gridSize
    if ((fullBoardSize+(squareHeightGap*4) <= mainWindow.size.height) && (fullBoardSize+(squareLengthGap*4) <= mainWindow.size.width)) {
        return true
    } else {
        return false
    }
}


var showGuide = false
func turnOnGuide() {
    msg("Displaying Help Guide 1/1, press h to exit")
    mainWindow.cursor.pushPosition(newPosition:Point(x:0, y:3))
    mainWindow.write("Help Guide: \ne to exit \n+ and - to resize Sudoku Board \n↑ ↓ → ← to navigate the Sudoku Board \n1-9 to input numbers into the cell \nbackspace or 0 to remove numbers from cell \nh to open/exit the help guide \nctrl-c to forcefully close")
    mainWindow.cursor.popPosition()
    makeSudokuBoard()
}
func turnOffGuide() {
    mainWindow.clear()
    makeSudokuBoard()
    msg("Exited Help Guide")
}



func makeSudokuBoard() {
    let cellHeight = cellSize + 1
    let cellWidth = Int(Double(cellHeight + 1) * 1.9) - 1
    var beginPoint = Point(x:(mainWindow.size.width-(cellWidth * 10))/2,
                           y:(mainWindow.size.height-(cellHeight * 9))/2)
    mainWindow.cursor.position = beginPoint

    func drawCell(_ topLeft:Point) {
        let cell = Rect(topLeft:topLeft, size:Size(width:cellWidth+1,height:cellHeight+1))
        mainWindow.draw(cell)
    }

    func edgeLine(x:Int, y:Int, edge:String) {
        mainWindow.cursor.position = Point(x:x, y:y)
        for _ in 1...3 {
            for _ in 1...2 {
                mainWindow.cursor.position = Point(x:mainWindow.cursor.position.x + cellWidth, y:y)
                mainWindow.write(edge)
                mainWindow.cursor.position = Point(x:mainWindow.cursor.position.x - 1, y:y)
            }
            mainWindow.cursor.position = Point(x:mainWindow.cursor.position.x + cellWidth + squareLengthGap, y:y)
        }
    }
    
    func middleLine(x:Int, y:Int) {
        mainWindow.cursor.position = Point(x:x, y:y)
        for _ in 1...3 {
            mainWindow.write("┣")
            for _ in 1...2 {
                mainWindow.cursor.position = Point(x:mainWindow.cursor.position.x + cellWidth - 1, y:y)
                mainWindow.write("┿")
            }
            mainWindow.cursor.position = Point(x:mainWindow.cursor.position.x + cellWidth - 1, y:y)
            mainWindow.write("┫")
            mainWindow.cursor.position = Point(x:mainWindow.cursor.position.x + squareLengthGap - 1, y:y)
        }
    }
    
    var currentX = beginPoint.x
    var currentY = beginPoint.y
    var highlightPoint = beginPoint
    for rowNum in 0..<gridSize {
        for colNum in 0..<gridSize {
            drawCell(Point(x:currentX, y:currentY))
            mainWindow.cursor.position = Point(x:currentX + (cellWidth/2),y:currentY + (cellHeight/2))
            let middlePoint = Point(x:currentX + (cellWidth/2),
                                    y:currentY + (cellHeight/2))
            if cellSize >= 3 { grid[rowNum][colNum].writeCustom(mainWindow:mainWindow, middle:middlePoint)
            } else {
                grid[rowNum][colNum].write(mainWindow:mainWindow, middle:middlePoint)
            }
            if (rowNum == cursorPosRow) && (colNum == cursorPosCol) {
                highlightPoint = Point(x:currentX, y:currentY)
            }
            currentX += cellWidth
            if (colNum  + 1) % 3 == 0 {
                currentX += squareLengthGap
            }
        }
        currentX -= (cellWidth * gridSize) + (squareLengthGap * 3)
        currentY += cellHeight
        if (rowNum + 1) % 3 == 0 {
            currentY += squareHeightGap
        }
    }
    
    for _ in 1...3 {
        edgeLine(x:beginPoint.x, y:beginPoint.y, edge:"┳")
        middleLine(x:beginPoint.x, y:beginPoint.y + cellHeight)
        middleLine(x:beginPoint.x, y:beginPoint.y + (2 * cellHeight))
        edgeLine(x:beginPoint.x, y: beginPoint.y + (3 * cellHeight), edge:"┻")
        beginPoint = Point(x:beginPoint.x, y: (beginPoint.y + (3 * cellHeight) + squareHeightGap))
    }
    
    mainWindow.turnOn(redOnBlack)
    drawCell(highlightPoint)
    mainWindow.turnOff(redOnBlack)
}


while cellSize > 1 {
    if checkWindowSize(size:cellSize+1) {
        makeSudokuBoard()
        break
    } else {
        cellSize -= 1
    }
    msg("The board has been shrunk to fit the window")
}
if checkWindowSize(size:cellSize+1) == false {
    msg("The current window is too small, resize the window and rerun")
}


//Loop until key press
let errorMsg = " is an invalid key sequence, press h for help"
while true {

    let key = keyboard.getKey(window:mainWindow)
    if key.keyType == .isCharacter {
        switch (key.character!) {
        case "0":
            msg("Emptied cell (\(cursorPosRow + 1),\(cursorPosCol + 1)).")
            grid[cursorPosRow][cursorPosCol].clear()
            makeSudokuBoard()
        case "1"..."9":
            msg("Entered \(Int(String(key.character!))!) into cell (\(cursorPosRow + 1),\(cursorPosCol + 1)). Press backspace or 0 to remove.")
            grid[cursorPosRow][cursorPosCol].input(Int(String(key.character!))!)
            makeSudokuBoard()
        case "+":
            guard checkWindowSize(size:cellSize+2) else {
                msg("The screen can not fit a larger board")
                continue
            }
            mainWindow.clear()
            cellSize += 1
            makeSudokuBoard()
            msg("Enlarged Sudoku Board to Size[\(cellSize)]    Tip: Zoom in with emacs instead")
        case "-":
            guard (cellSize-1) >= 1 else {
                msg("Size[1] is the smallest size possible")
                continue
            }
            mainWindow.clear()
            cellSize -= 1
            makeSudokuBoard()
            msg("Reduced Sudoku Board to Size[\(cellSize + 1)]    Tip: Zoom out with emacs instead")
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
        switch (key.keyType) {
        case .arrowDown:
            guard cursorPosRow + 1 <= 8 else {
                msg("You can not move down any further")
                continue
            }
            cursorPosRow += 1
            msg("Moved down to cell (\(cursorPosRow + 1),\(cursorPosCol + 1))")
            makeSudokuBoard()
        case .arrowUp:
            guard cursorPosRow - 1 >= 0 else {
                msg("You can not move up any further")
                continue
            }
            cursorPosRow -= 1
            msg("Moved down to cell (\(cursorPosRow + 1),\(cursorPosCol + 1))")
            makeSudokuBoard()
        case .arrowRight:
            guard cursorPosCol + 1 <= 8 else {
                msg("You can not move right any further")
                continue
            }
            cursorPosCol += 1
            msg("Moved down to cell (\(cursorPosRow + 1),\(cursorPosCol + 1))")
            makeSudokuBoard()
        case .arrowLeft:
            guard cursorPosCol - 1 >= 0 else {
                msg("You can not move left any further")
                continue
            }
            cursorPosCol -= 1
            msg("Moved down to cell (\(cursorPosRow + 1),\(cursorPosCol + 1))")
            makeSudokuBoard()
        case .backspace:
            msg("Emptied cell (\(cursorPosRow + 1),\(cursorPosCol + 1))")
            grid[cursorPosRow][cursorPosCol].clear()
            makeSudokuBoard()
        case .enter:
            msg("One day I'll actually let it calculate it. Not today.")

        default:
            msg("That" + errorMsg)
            
        }
    }
}
