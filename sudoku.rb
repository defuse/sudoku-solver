require 'pp'

POSSIBLE_VALUES = [1,2,3,4,5,6,7,8,9]
BOARD_SIZE = POSSIBLE_VALUES.size

# Represents a set of nine squares that must satisfy the "sudoku constraint"
# The sudoku constraint is:
#   The set must consist of nine squares and for each value in 1,2,3,4,5,6,7,8,9
#   exactly one of the squares has that value, and no square has any other
#   value.
class Constraint

  def initialize(squares)
    @squares = squares
  end

  def getRemainingValues
    return POSSIBLE_VALUES - @squares.map { |s| s.value }
  end

  def consistent?
    known = @squares.reject { |s| s.value == 0 }
    return known.uniq.size == known.size
  end

  def addSquare(square)
    @squares << square
  end

end

# Represents one square in the sudoku grid.
class Square

  def initialize(value)
    @value = value
    @constraints = []
  end

  def value
    @value
  end

  def setValue(newValue)
    @value = newValue
  end

  def known?
    @value != 0
  end

  def possibleValues
    if known?
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

  def initialize(board)
    @board = []
    if board.size != BOARD_SIZE
      raise "Invalid number of rows"
    end
    board.each do |row|
      if row.size != BOARD_SIZE
        raise "Invalid row length"
      end
      @board << row.map { |cell| Square.new(cell) }
    end

    @constraints = []

    setupConstraints()
  end

  def setupConstraints
    # In sudoku, there are three types of constraints:
    # 
    # Row constraints:
    #   Each row must satisfy the sudoku constraint.
    # Column constraints:
    #   Each column must satisfy the sudoku constraint.
    # Box constraints:
    #   Each box (3x3 sub-grid) must satisfy the sudoku constraint.

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

    # Create the box constraints
    box_constraints = {}
    0.upto(BOARD_SIZE - 1) do |row_idx|
      0.upto(BOARD_SIZE - 1) do |col_idx|
        crow = row_idx / 3
        ccol = col_idx / 3
        constraint = box_constraints[[crow,ccol]]
        if constraint.nil?
          constraint = Constraint.new([])
          box_constraints[[crow,ccol]] = constraint
        end
        constraint.addSquare(@board[row_idx][col_idx])
        @board[row_idx][col_idx].addConstraint(constraint)
      end
    end
    @constraints = @constraints + box_constraints.values
  end

  def solved?
    if not consistent?
      return false
    end
    @board.each do |row|
      row.each do |cell|
        unless POSSIBLE_VALUES.include? cell.value
          return false
        end
      end
    end
    return true
  end

  def consistent?
    @constraints.each do |constraint|
      return false unless constraint.consistent?
    end
    return true
  end

  def solve
    solveRecursive()
  end

  # Returns true if a solution was found.
  # Otherwise, returns false, and resets the board to how it was before it was
  # called.
  def solveRecursive
    if solved?
      return true
    end

    # Select the first unknown square.
    unknown = unsolvedSquares.first

    if unknown.possibleValues.empty?
      # Inconsistent, return false.
      return false
    end

    # Try every possible value
    unknown.possibleValues.dup.shuffle.each do |value|
      unknown.setValue(value)
      if solveRecursive() == true
        return true
      else
        unknown.setValue(0)
      end
    end
  end

  def unsolvedSquares
    unsolved = []
    @board.each do |row|
      row.each do |cell|
        unless cell.known?
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

puzzle = [
  [0, 0, 0, 1, 0, 0, 7, 0, 0],
  [0, 0, 2, 6, 0, 3, 0, 5, 0],
  [0, 5, 0, 4, 0, 0, 2, 0, 8],
  [4, 2, 5, 3, 0, 0, 0, 8, 0],
  [0, 0, 0, 0, 9, 0, 0, 0, 0],
  [0, 8, 0, 0, 0, 4, 5, 1, 3],
  [1, 0, 4, 0, 0, 6, 0, 7, 0],
  [0, 7, 0, 9, 0, 2, 6, 0, 0],
  [0, 0, 3, 0, 0, 1, 0, 0, 0]
]

puzzle = [
  [0, 4, 6, 0, 0, 1, 0, 0, 0],
  [0, 0, 0, 0, 2, 0, 0, 8, 9],
  [1, 9, 0, 8, 0, 0, 5, 0, 0],
  [0, 0, 0, 0, 0, 7, 0, 0, 0],
  [0, 5, 7, 0, 1, 0, 6, 2, 0],
  [0, 0, 0, 9, 0, 0, 0, 0, 0],
  [0, 0, 4, 0, 0, 2, 0, 3, 6],
  [6, 1, 0, 0, 5, 0, 0, 0, 0],
  [0, 0, 0, 3, 0, 0, 7, 5, 0]
]

# puzzle = [
#   [0, 0, 0, 0, 0, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 0, 0, 0, 0],
# ]
# 
game = Sudoku.new(puzzle)
game.solve
if game.solved?
  game.printGame
else
  puts "NOPE"
end
