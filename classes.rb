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

  def value_at(square_num)
    y = BoardMath.transform_y_index(square_num)
    x = BoardMath.transform_x_index(square_num)
    return squares[y][x].value
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
    for player_symbol in [:x, :o]
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

class ComputerPlayer < Player

  def initialize(options = {})
    options[:type] = :computer
    super
  end

  def turn(board)
    Display.turn(symbol, type, board)
    sleep 1
    if win_opportunity(symbol, board)
      square_num = win_opportunity(symbol, board)
      board.make_move(symbol, square_num)
    elsif win_opportunity(opponent_symbol, board)
      square_num = win_opportunity(opponent_symbol, board)
      board.make_move(symbol, square_num)
    elsif center_opportunity(board)
      square_num = center_opportunity(board)
      board.make_move(symbol, square_num)
    elsif opposite_opponent_corner_opportunity(opponent_symbol, board)
      square_num = opposite_opponent_corner_opportunity(opponent_symbol, board)
      board.make_move(symbol, square_num)
    elsif corner_opportunity(board)
      square_num = corner_opportunity(board)
      board.make_move(symbol, square_num)
    else
      square_num = middle_side_opportunity(board)
      board.make_move(symbol, square_num)
    end
  end

  def win_opportunity(player_symbol, board)
    return row_win_opportunity(player_symbol, board) if row_win_opportunity(player_symbol, board)
    return column_win_opportunity(player_symbol, board) if column_win_opportunity(player_symbol, board)
    return diagonal_win_opportunity(player_symbol, board) if diagonal_win_opportunity(player_symbol, board)
    false
  end

  def row_win_opportunity(player_symbol, board)
    board.squares.each_with_index do |row, y|
      if row.count {|square| square.value == player_symbol} == 2
        row.each_with_index do |square, x|
          return BoardMath.transform_to_square_num(y,x) if square.value == nil
        end
      end
    end
    false
  end

  def column_win_opportunity(player_symbol, board)
    board.squares.transpose.each_with_index do |column, x|
      if column.count {|square| square.value == player_symbol} == 2
        column.each_with_index do |square, y|
          return BoardMath.transform_to_square_num(y,x) if square.value == nil
        end
      end
    end
    false
  end

  def diagonal_win_opportunity(player_symbol, board)
    board.diagonals.each_with_index do |diagonal, w|
      if diagonal.count {|square| square.value == player_symbol} == 2
        diagonal.each_with_index do |square, z|
          return BoardMath.transform_diagonal_to_square_num(w,z) if square.value == nil
        end
      end
    end
    false
  end

  def center_opportunity(board)
    return 5 if board.squares[1][1].value == nil
    false
  end

  def opposite_opponent_corner_opportunity(opponent_symbol, board)
    opposing_corners = {1 => 9, 3 => 7}
    opposing_corners.each_pair do |square_num_1, square_num_2|
      return square_num_2 if board.value_at(square_num_2) == nil && board.value_at(square_num_1) == opponent_symbol
      return square_num_1 if board.value_at(square_num_1) == nil && board.value_at(square_num_2) == opponent_symbol
    end
    false
  end

  def corner_opportunity(board)
    corners = [1, 3, 7, 9]
    corners.each {|square_num| return square_num if board.value_at(square_num) == nil}
    false
  end

  def middle_side_opportunity(board)
    sides = [2, 4, 6, 8]
    sides.each {|square_num| return square_num if board.value_at(square_num) == nil}
    false
  end

end


class BoardMath

  def self.transform_to_square_num(y, x)
    3*y+x+1
  end

  def self.transform_diagonal_to_square_num(w, z)
    if z == 0
      return 1+2*w
    elsif z == 1
      return 5
    else
      return 9-2*w
    end
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
