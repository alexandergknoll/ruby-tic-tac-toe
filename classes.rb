class Square
  attr_reader :value

  def initialize
    @value = nil
  end

  def make_move(player)
    @value = player
  end

end

class Board
  attr_reader :squares, :winner

  def initialize
    @squares = Array.new(3) {Array.new(3) {Square.new}}
    @winner = nil
  end

  def make_move(player, square_num)
    y = index_transform_y(square_num)
    x = index_transform_x(square_num)
    squares[y][x].make_move(player)
  end

  def valid_move?(square_num)
    y = index_transform_y(square_num)
    x = index_transform_x(square_num)
    if square_num.between?(1, 9) && !squares[y][x].value
      true
    else
      false
    end
  end

  def game_over?
    if row_win? || column_win? || diagonal_win?
      return true
    else
      return false
    end
  end

  def square_num(y, x)
    3 * y + x + 1
  end

  private

  def row_win?
    for player in [:x, :o]
      squares.each do |row|
        if row.count {|square| square.value == player} == 3
          @winner = player
          return true
        end
      end
    end
    return false
  end

  def column_win?
    for player in [:x, :y]
      squares.transpose.each do |column|
        if column.count {|square| square.value == player} == 3
          @winner = player
          return true
        end
      end
    end
    return false
  end

  def diagonal_win?
    if diagonal_win_1? || diagonal_win_2?
      return true
    else
      return false
    end
  end

  def diagonal_win_1?
    for player in [:x, :o]
      diagonals = squares.map.with_index do |row, y|
        row[y]
      end
      if diagonals.count {|square| square.value == player} == 3
          @winner = player
          return true
      end
    end
    return false
  end

  def diagonal_win_2?
    for player in [:x, :o]
      diagonals = squares.map.with_index do |row, y|
        row[2-y]
      end
      if diagonals.count {|square| square.value == player} == 3
          @winner = player
          return true
      end
    end
    return false
  end

  def index_transform(square_num)
    square_num-1
  end

  def index_transform_y(square_num)
    index = index_transform(square_num)
    index/3
  end

  def index_transform_x(square_num)
    index = index_transform(square_num)
    index%3
  end

end

class ComputerPlayer

  def self.evaluate_move(board)
    sleep 2 # Pauses before evaluating!
    # Some solving methods in here...
    return board.square_num(y, x)
  end

end

class Display

  def self.start_game(board)
    board(board)
    puts "Welcome!"
  end

  def self.turn(player, board)
    board(board)
    puts "It's #{player}'s turn!"
    print "square> "
  end

  def self.end_game(board)
    board(board)
    puts "The winner is #{board.winner}!"
  end

  private

  def self.board(board)
    reset_screen!
    board.squares.each_with_index do |row, y|
      puts "---+---+---" if y != 0
      row.each_with_index do |square, x|
        print " "
        if square.value
          print square.value
        else
          print " "
        end
        print " "
        print "|" if x < 2
        puts if x%3 == 2
      end
    end
  end

  def self.reset_screen!
    clear_screen!
    move_to_home!
  end

  def self.clear_screen!
    print "\e[2J"
  end

  def self.move_to_home!
    print "\e[H"
  end

end