# This program solves Sudoku puzzles.

# Change 'PUZZLE' to be the puzzle you want it to solve.
# Put '0' in the empty cells.

# Super easy puzzle...
PUZZLE = [
  [6, 0, 0, 1, 0, 8, 2, 0, 3],
  [0, 2, 0, 0, 4, 0, 0, 9, 0],
  [8, 0, 3, 0, 0, 5, 4, 0, 0],
  [5, 0, 4, 6, 0, 7, 0, 0, 9],
  [0, 3, 0, 0, 0, 0, 0, 5, 0],
  [7, 0, 0, 8, 0, 3, 1, 0, 2],
  [0, 0, 1, 7, 0, 0, 9, 0, 6],
  [0, 8, 0, 0, 3, 0, 0, 2, 0],
  [3, 0, 2, 9, 0, 4, 0, 0, 5],
]

# # This one takes about 2 minutes...
# PUZZLE = [
#   [6, 0, 0, 0, 0, 8, 9, 4, 0],
#   [9, 0, 0, 0, 0, 6, 1, 0, 0],
#   [0, 7, 0, 0, 4, 0, 0, 0, 0],
#   [2, 0, 0, 6, 1, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 0, 2, 0, 0],
#   [0, 8, 9, 0, 0, 2, 0, 0, 0],
#   [0, 0, 0, 0, 6, 0, 0, 0, 5],
#   [0, 0, 0, 0, 0, 0, 0, 3, 0],
#   [8, 0, 0, 0, 0, 1, 6, 0, 0],
# ]
# # The above puzzle is from:
# # http://www.sudokuwiki.org/Weekly_Sudoku.asp?puz=28

# # This one takes about 30 seconds...
# PUZZLE = [
#   [8, 0, 0, 0, 0, 0, 0, 0, 0],
#   [0, 0, 3, 6, 0, 0, 0, 0, 0],
#   [0, 7, 0, 0, 9, 0, 2, 0, 0],
#   [0, 5, 0, 0, 0, 7, 0, 0, 0],
#   [0, 0, 0, 0, 4, 5, 7, 0, 0],
#   [0, 0, 0, 1, 0, 0, 0, 3, 0],
#   [0, 0, 1, 0, 0, 0, 0, 6, 8],
#   [0, 0, 8, 5, 0, 0, 0, 1, 0],
#   [0, 9, 0, 0, 0, 0, 4, 0, 0],
# ]
# # The above puzzle is from:
# # http://www.sudokuwiki.org/Arto_Inkala_Sudoku

# ----------------------------------------------------------------------------

# Each Sudoku cell can take on any value in 1 through 9.
POSSIBLE_VALUES = [1,2,3,4,5,6,7,8,9]
# A Sudoku puzzle is a 9x9 grid.
BOARD_SIZE = 9

# In Sudoku, each cell is a member of three "Constraints." A Constraint is
# a group of 9 cells in which every number from 1 to 9 occurs exactly once. An
# instance of this class represents one such constraint.
class Constraint

  def initialize(cells)
    # We represent a Constraint simply by the list of member Cells.
    @cells = cells
  end

  # When a Constraint is complete, exactly one Cell must have all of the values
  # in POSSIBLE_VALUES. This method returns the values that have *not* been
  # taken yet.
  def getRemainingValues
    return POSSIBLE_VALUES - @cells.map { |s| s.value }
  end

  # Returns true if the Constraint is not in conflict. A constraint is in
  # conflict when two Cells have the same value.
  def consistent?
    known = @cells.reject { |s| s.value == 0 }
    return known.uniq.size == known.size
  end

  # Make 'cell' a member of this Constraint.
  def addCell(cell)
    @cells << cell
  end

end

# Represents one cell in the Sudoku puzzle.
class Cell

  # We keep track of the Cell's value in @value. It's 0 if the cell is empty.
  attr_accessor :value

  def initialize(value)
    @value = value
    # We keep track of the constraints the Cell is a member of in @constraints.
    @constraints = []
  end

  # Returns true if the Cell is non-empty.
  def filled?
    @value != 0
  end

  # Returns a list of values this Cell could take on without creating conflicts
  # with any of its Constraints.
  def possibleValues
    if filled?
      return [value]
    else
      possible = POSSIBLE_VALUES
      @constraints.each do |constraint|
        possible = possible & constraint.getRemainingValues
      end
      return possible
    end
  end

  def addConstraint(constraint)
    @constraints << constraint
  end

  def to_s
    @value.to_s
  end

  def inspect
    @value.to_s
  end

end

class Sudoku

  # The Sudoku puzzle is constructed from a 9x9 2-dimensional array of integers.
  # Empty cells should be filled with zero.
  def initialize(board)

    # Convert the 2D array of integers into a 2D array of Cell.
    @board = []
    if board.size != BOARD_SIZE
      raise "Invalid number of rows"
    end
    board.each do |row|
      if row.size != BOARD_SIZE
        raise "Invalid row length"
      end
      @board << row.map { |cell| Cell.new(cell) }
    end

    # Create the constraints according to the rules of Sudoku
    setupConstraints()
  end

  def setupConstraints
    # In sudoku, there are three types of constraints:
    # 
    # Row constraints:
    #   All cells in the same row are members of a constraint for that row.
    #
    # Column constraints:
    #   All cells in the same column are members of a constraint for that
    #   column.
    #
    # Box constraints:
    #   The cells inside each non-overlapping 3x3 sub-grid are members of
    #   a constraint for that sub-grid.

    @constraints = []

    # Create the row constraints
    @board.each do |row|
      # Create the constraint for the whole row.
      constraint = Constraint.new(row)
      @constraints << constraint
      # Tell each cell in that row they're part of this constraint.
      row.each do |cell|
        cell.addConstraint(constraint)
      end
    end

    # Create the column constraints
    @board.transpose.each do |column|
      # Create the constraint for the whole column.
      constraint = Constraint.new(column)
      @constraints << constraint
      # Tell each cell in the column they're part of this constraint.
      column.each do |cell|
        cell.addConstraint(constraint)
      end
    end

    0.upto(2) do |box_row|
      0.upto(2) do |box_col|
        constraint = Constraint.new([])
        @constraints << constraint
        0.upto(2) do |row_in_box|
          0.upto(2) do |col_in_box|
            cell = @board[box_row*3 + row_in_box][box_col*3 + col_in_box]
            constraint.addCell(cell)
            cell.addConstraint(constraint)
          end
        end
      end
    end
  end

  # Returns true if the puzzle has been completely solved.
  def solved?
    # A Sudoku puzzle is finished when all cells have been filled with a number
    # between 1 and 9 and none of the constraints are in conflict.

    # First, make sure all the cells are filled.
    @board.each do |row|
      row.each do |cell|
        unless POSSIBLE_VALUES.include? cell.value
          return false
        end
      end
    end

    # Next, make sure none of the constraints are in conflict.
    if not consistent?
      return false
    end

    return true
  end

  # Returns true if none of the constraints are in conflict.
  def consistent?
    @constraints.each do |constraint|
      return false unless constraint.consistent?
    end
    return true
  end

  # Returns true if a solution was found.
  # Otherwise, returns false, and resets the board to how it was before it was
  # called.

  # Tries to solve the puzzle.
  # If the puzzle can be solved, it leaves it that way and returns true.
  # If the puzzle couldn't be solved, it reverts it back to the way it was and
  # returns false.
  def solve
    if solved?
      return true
    end

    # Select the first unknown cell.
    unknown = unsolvedCells.first

    if unknown.possibleValues.empty?
      # Inconsistent, return false.
      return false
    end

    # Try every possible value
    unknown.possibleValues.shuffle.each do |value|
      unknown.value = value
      if solve() == true
        return true
      else
        unknown.value = 0
      end
    end
  end

  def unsolvedCells
    unsolved = []
    @board.each do |row|
      row.each do |cell|
        unless cell.filled?
          unsolved << cell
        end
      end
    end
    return unsolved
  end

  def printGame
    @board.each_with_index do |row, idx|
      if idx % 3 == 0
        puts "+---+---+---+"
      end
      row.each_with_index do |cell, c_idx|
        if c_idx % 3 == 0
          print "|"
        end
        print cell.value.to_s
      end
      print "|\n"
    end
    print "+---+---+---+\n"
  end

end

game = Sudoku.new(PUZZLE)
game.solve
if game.solved?
  game.printGame
else
  puts "NOPE"
end
