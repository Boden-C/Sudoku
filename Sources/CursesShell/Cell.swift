    
import Foundation
import Curses
let customNum = CustomDigitFont()

class Cell:CustomStringConvertible {
    private(set) var digit:Int?
    private(set) var possibleDigits: Set<Int>
//Should add better var names so it will be more orgnazised 
    private(set) var row:Int
    private(set) var col:Int
    private(set) var boxRowNum:Int
    private(set) var boxColNum:Int
    private(set) var isConfirmed:Bool

    init(row:Int, col:Int) {
        self.possibleDigits = Set(1...9)
        self.digit = nil
        self.row = row
        self.col = col
        self.isConfirmed = false

        //find the box number based on row and col
        self.boxRowNum = Int((Double(row/3)).rounded(.down))
        self.boxColNum = Int((Double(col/3)).rounded(.down))
    }
    
    var description: String {
        self.digit.map{ String($0) } ?? " "
    }
    // add spaces to clean up code

    func clear() { self.digit = nil }

    func input(_ num:Int) {
        guard (1...9).contains(num) else { self.digit = nil; return }
        self.digit = num
    }
    
    func check() -> Bool {
        guard possibleDigits.count == 1 else { return false }
        self.isConfirmed = true
        self.digit = possibleDigits.first!
        return true
    }

    func write(mainWindow:Window, middle:Point) {
        mainWindow.cursor.position = middle
        mainWindow.write("\(self)")
    }
//used to write custom font
    func writeCustom(mainWindow:Window, middle:Point) {
        for (index, line) in customNum.array((self.digit ?? 0)).enumerated() {
            mainWindow.cursor.position = Point(x:middle.x - 1, y:(middle.y - 1) + index)
            mainWindow.write("\(line)")
        }
    }
}
