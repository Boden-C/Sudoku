 
import Foundation
import Curses

class Board {
    var grid:[[Cell]]
    var squareLengthGap:Int
    var squareHeightGap:Int
    var cursorRow:Int
    var cursorCol:Int
    var highlightColor:Attribute
    private(set) var cellSize:Int

    init(grid: [[Cell]], highlightColor:Attribute) {
        self.grid = grid
        self.squareLengthGap = 2
        self.squareHeightGap = 1
        self.cursorRow = 0
        self.cursorCol = 0
        self.highlightColor = highlightColor
        self.cellSize = 3
    }

    func render(mainWindow:Window) {
        let cellHeight = cellSize + 1
        let cellWidth = Int(Double(cellHeight + 1) * 1.9) - 1
        var beginPoint = Point(x:(mainWindow.size.width-(cellWidth * 10))/2,y:(mainWindow.size.height-(cellHeight * 9))/2)
        mainWindow.cursor.position = beginPoint

        func drawCell(_ topLeft:Point) {
            let cell = Rect(topLeft:topLeft, size:Size(width:cellWidth+1,height:cellHeight+1))
            mainWindow.draw(cell)
        }
// drawing the edge Line
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

        // drawing the middle line of the box/cell
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
        for rowNum in 0..<self.grid.count {
            for colNum in 0..<self.grid.count {
                drawCell(Point(x:currentX, y:currentY))
                mainWindow.cursor.position = Point(x:currentX + (cellWidth/2),y:currentY + (cellHeight/2))
                let middlePoint = Point(x:currentX + (cellWidth/2),
                                        y:currentY + (cellHeight/2))
                if cellSize >= 3 { grid[rowNum][colNum].writeCustom(mainWindow:mainWindow, middle:middlePoint)
                } else {
                    grid[rowNum][colNum].write(mainWindow:mainWindow, middle:middlePoint)
                }
                if (rowNum == cursorRow) && (colNum == cursorCol) {
                    highlightPoint = Point(x:currentX, y:currentY)
                }
                currentX += cellWidth
                if (colNum  + 1) % 3 == 0 {
                    currentX += squareLengthGap
                }
            }
            currentX -= (cellWidth * self.grid.count) + (squareLengthGap * 3)
            currentY += cellHeight
            if (rowNum + 1) % 3 == 0 {
                currentY += squareHeightGap
            }
        }
        // Defining the edges on where to start drawing 
        for _ in 1...3 {
            edgeLine(x:beginPoint.x, y:beginPoint.y, edge:"┳")
            middleLine(x:beginPoint.x, y:beginPoint.y + cellHeight)
            middleLine(x:beginPoint.x, y:beginPoint.y + (2 * cellHeight))
            edgeLine(x:beginPoint.x, y: beginPoint.y + (3 * cellHeight), edge:"┻")
            beginPoint = Point(x:beginPoint.x, y: (beginPoint.y + (3 * cellHeight) + squareHeightGap))
        }
// highlighting the box
        mainWindow.turnOn(redOnBlack)
        drawCell(highlightPoint)
        mainWindow.turnOff(redOnBlack)
    }

    // resizing the board till it fits the screen
    func resize(_ sizeDifference:Int) {
        guard (self.cellSize + sizeDifference) >= 1 else { self.cellSize = 1; return}
        self.cellSize = self.cellSize + sizeDifference
    }

    func clearHere() { grid[self.cursorRow][self.cursorCol].clear() }

    func inputHere(_ num:Int) { grid[self.cursorRow][self.cursorCol].input(num) }

    func returnHere() -> Cell { return grid[self.cursorRow][self.cursorCol] }

    func check() -> Bool { return grid[self.cursorRow][self.cursorCol].check() }

    func returnRow(cell:Cell) -> [Cell] { return grid[cell.row] }

    func returnCol(cell:Cell) -> [Cell] {
        var finalArray = [Cell]()
        for array in grid {
            finalArray.append(array[cell.col])
        }
        return finalArray
    }

    func returnBox(cell:Cell) -> [Cell] {
        var finalArray = [Cell]()
        for rowNum in cell.boxRowNum...cell.boxRowNum+2 {
            for colNum in cell.boxColNum...cell.boxColNum+2 {
                finalArray.append(grid[rowNum][colNum])
            }
        }
        return finalArray
    }
}
