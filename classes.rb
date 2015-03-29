require_relative "term_color"

class Square
  attr_reader :value

  def initialize
    @value = nil
  end

  def make_move(player_symbol)
    @value = player_symbol
  end

end

class Board
  attr_accessor :squares, :winner

  def initialize
    @squares = Array.new(3) {Array.new(3) {Square.new}}
    @winner = nil
  end

  def make_move(player_symbol, square_num)
    y = BoardMath.transform_y_index(square_num)
    x = BoardMath.transform_x_index(square_num)
    squares[y][x].make_move(player_symbol)
  end

  def valid_move?(square_num)
    y = BoardMath.transform_y_index(square_num)
    x = BoardMath.transform_x_index(square_num)
    if square_num.between?(1, 9) && squares[y][x].value == nil
      true
    else
      false
    end
  end

  def game_over?
    if game_won? || !moves_remaining?
      true
    else
      false
    end
  end

  def game_won?
    row_win?
    column_win?
    diagonal_win?
    if winner
      true
    else
      false
    end
  end

  def moves_remaining?
    squares.each do |row|
      row.each do |square|
        return true unless square.value
      end
    end
    false
  end

  private

  def row_win?
    for player_symbol in [:x, :o]
      squares.each do |row|
        if row.count {|square| square.value == player_symbol} == 3
          @winner = player_symbol
          return true
        end
      end
    end
    false
  end

  def column_win?
    for player_symbol in [:x, :y]
      squares.transpose.each do |column|
        if column.count {|square| square.value == player_symbol} == 3
          @winner = player_symbol
          return true
        end
      end
    end
    false
  end

  def diagonal_win?
    for player_symbol in [:x, :o]
      diagonals.each do |diagonal|
        if diagonal.count {|square| square.value == player_symbol} == 3
          @winner = player_symbol
          return true
        end
      end
    end
    false
  end

  def diagonals
    diagonal_1 = squares.map.with_index {|row, y| row[y]}
    diagonal_2 = squares.map.with_index {|row, y| row[2-y]}
    [diagonal_1, diagonal_2]
  end

end

class Player
  attr_reader :type, :symbol, :opponent_symbol

  def initialize(options = {})
    @type = options[:type]
    @symbol = options[:symbol]
    @opponent_symbol = :x if symbol == :o
    @opponent_symbol = :o if symbol == :x
  end

end

class HumanPlayer < Player

  def initialize(options = {})
    options[:type] = :human
    super
  end

  def turn(board)
    input = nil
    until board.valid_move?(input.to_i)
      Display.turn(symbol, type, board)
      input = $stdin.gets.chomp
      if input == "surrender"
        board.winner = opponent_symbol
        return
      end
    end
    board.make_move(symbol, input.to_i)
  end

end

# class ComputerPlayer < Player

#   def initialize(options = {})
#     options[:type] = :computer
#     super
#   end

#   def turn(board)
#     sleep 2
#     if win_opportunity(symbol, board)
#       square_num = win_opportunity(board)
#       board.make_move(symbol, square_num)
#     elsif win_opportunity(board)
#       square_num = opponent_win_opportunity(board)
#       board.make_move(symbol, square_num)
#     elsif fork_opportunity(board)
#       square_num = fork_opportunity(board)
#       board.make_move(symbol, square_num)
#     elsif opponent_fork_opportunity(board)
#       square_num = opponent_fork_opportunity(board)
#       board.make_move(symbol, square_num)
#     elsif center_opportunity(board)
#       square_num = center_opportunity(board)
#       board.make_move(symbol, square_num)
#     elsif opposite_opponent_corner_opportunity(board)
#       square_num = opposite_opponent_corner_opportunity(board)
#     elsif corner_opportunity(board)
#       square_num = corner_opportunity(board)
#       board.make_move(symbol, square_num)
#     else
#       square_num = middle_side_opportunity(board)
#       board.make_move(symbol, type, square_num)
#     end
#   end

#   def win_opportunity(board)
#     return row_win_opportunity(board) if row_win_opportunity(board)
#     return column_win_opportunity(board) if column_win_opportunity(board)
#     return diagonal_win_opportunity(board) if diagonal_win_opportunity(board)
#     false
#   end

#   def opponent_win_opportunity(board)

#     return false
#   end

#   def fork_opportunity(board)

#     return false
#   end

#   def opponent_fork_opportunity(board)

#     return false
#   end

#   def center_opportunity(board)

#     return false
#   end

#   def opposite_opponent_corner_opportunity(board)

#     return false
#   end

#   def corner_opportunity(board)

#     return false
#   end

#   def middle_side_opportunity(board)

#     return false
#   end

# end


class BoardMath

  def self.transform_to_square_num(y, x)
    3*y+x+1
  end

  def self.transform_y_index(square_num)
    index = transform_to_index(square_num)
    index/3
  end

  def self.transform_x_index(square_num)
    index = transform_to_index(square_num)
    index%3
  end

  def self.transform_to_index(square_num)
    square_num-1
  end

end

class Display

  def self.turn(player_symbol, player_type, board)
    board(board)
    puts "It's #{player_symbol}'s turn!"
    prompt(player_type)
  end

  def self.prompt(player_type)
    print "Square #> " if player_type == :human
    print "Evaluating..." if player_type == :computer
  end

  def self.end_game(board)
    board(board)
    if board.winner
      puts "The winner is #{board.winner}!"
    else
      puts "It's a draw!"
    end
  end

  private

  def self.board(board)
    reset_screen!
    puts
    board.squares.each_with_index do |row, y|
      if y > 0
        indent
        print_divider
      end      
      indent
      row.each_with_index do |square, x|
        indent
        print_square(y, x, square)
        indent
        print_separator if x < 2
        puts if x%3 == 2
      end
    end
    puts
  end

  def self.print_divider
    puts "-–-|-–-|-–-".bold
  end

  def self.print_separator
    print "|".bold 
  end

  def self.indent
    print " "
  end

  def self.print_square(y, x, square)
    if square.value
      print "#{square.value}".cyan.bold if square.value == :x
      print "#{square.value}".red.bold if square.value == :o
    else
      print "#{BoardMath.transform_to_square_num(y,x)}".grey.thin
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