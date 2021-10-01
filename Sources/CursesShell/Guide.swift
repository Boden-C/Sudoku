import Curses

class Guide {
    //Display the guide
    var showGuide = false

    init(_ window:Window) {}
    
    func on(_ mainWindow:Window) {
        msg("Displaying Help Guide 1/1, press h to exit")
        mainWindow.cursor.pushPosition(newPosition:Point(x:0, y:3))
        mainWindow.write("Help Guide: \ne to exit \n+ and - to resize Sudoku Board \n↑ ↓ → ← to navigate the Sudoku Board \n1-9 to input numbers into the cell \nbackspace or 0 to remove numbers from cell \nh to open/exit the help guide \nctrl-c to forcefully close")
        mainWindow.cursor.popPosition()
        board.render(mainWindow:mainWindow)
    }
    func off(_ mainWindow:Window) {
        mainWindow.clear()
        board.render(mainWindow:mainWindow)
        msg("Exited Help Guide")
    }
}
