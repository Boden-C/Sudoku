
public class Cell:CustomStringConvertible {
    var digit:Int
    var row:Int
    var col:Int
    var sqrRowNum:Int
    var sqrColNum:Int
    var problemCell:Bool
    //whether this cell has a possible list or is defined

    var temp:Bool
    //whether the digit imputed is temporary or not

    var possibleDigits:Set<Int>
    //all the possible digits in the location

    init(row:Int,col:Int) {
        precondition(row >= 1 && row <= 9, "Error: Invalid Row")
        precondition(col >= 1 && col <= 9, "Error: Invalid Column")

        self.digit = 0
        self.row = row
        self.col = col

        //find the square number based on row and col
        switch row {
        case 1...3:
            self.sqrRowNum = 0
        case 4...6:
            self.sqrRowNum = 3
        case 7...9:
            self.sqrRowNum = 6
        default:
            self.sqrRowNum = 0
        }
        switch col {
        case 1...3:
            self.sqrColNum = 0
        case 4...6:
            self.sqrColNum = 3
        case 7...9:
            self.sqrColNum = 6
        default:
            self.sqrColNum = 0
        }

        self.problemCell = false
        self.temp = false
        self.possibleDigits = [1,2,3,4,5,6,7,8,9]
        //remove digits from possibility once proven not possible
    }

    func returnRow() -> [Cell] {
        return grid[self.row-1]
    }

    func returnCol() -> [Cell] {
        var finalArray = [Cell]()
        for array in grid {
            finalArray.append(array[self.col-1])
        }
        return finalArray
    }

    func returnSqr() -> [Cell] {
        var finalArray = [Cell]()
        for rowNum in self.sqrRowNum...self.sqrRowNum+2 {
            for colNum in self.sqrColNum...self.sqrColNum+2 {
                finalArray.append(grid[rowNum][colNum])
            }
        }
        return finalArray
    }

    public var description:String {
        return("\(self.digit)")
    }
}

