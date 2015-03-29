require_relative "classes"

class HumanPlayer
  attr_reader :symbol, :type

  def initialize(symbol)
    @symbol = symbol
    @type = :human
  end

  def turn(board)
    input = nil
    until board.valid_move?(input.to_i) || input == "surrender"
      Display.turn(symbol, type, board)
      input = $stdin.gets.chomp
    end
    if input == "surrender"
      board.winner = :x if symbol == :o
      board.winner = :o if symbol == :x
    else
      board.make_move(symbol, input.to_i)
    end
  end

end

class ComputerPlayer
  attr_reader :symbol, :type

  def initialize(symbol)
    @symbol = symbol
    @type = :computer
  end

  def turn(board)
    sleep 2
    if win_opportunity(board)
      square_num = win_opportunity(board)
      board.make_move(symbol, square_num)
    elsif opponent_win_opportunity(board)
      square_num = opponent_win_opportunity(board)
      board.make_move(symbol, square_num)
    elsif fork_opportunity(board)
      square_num = fork_opportunity(board)
      board.make_move(symbol, square_num)
    elsif opponent_fork_opportunity(board)
      square_num = opponent_fork_opportunity(board)
      board.make_move(symbol, square_num)
    elsif center_opportunity(board)
      square_num = center_opportunity(board)
      board.make_move(symbol, square_num)
    elsif opposite_opponent_corner_opportunity(board)
      square_num = opposite_opponent_corner_opportunity(board)
    elsif corner_opportunity(board)
      square_num = corner_opportunity(board)
      board.make_move(symbol, square_num)
    else
      square_num = middle_side_opportunity(board)
      board.make_move(symbol, type, square_num)
    end
  end

  def win_opportunity(board)

    return false
  end

  def opponent_win_opportunity(board)

    return false
  end

  def fork_opportunity(board)

    return false
  end

  def opponent_fork_opportunity(board)

    return false
  end

  def center_opportunity(board)

    return false
  end

  def opposite_opponent_corner_opportunity(board)

    return false
  end

  def corner_opportunity(board)

    return false
  end

  def middle_side_opportunity(board)

    return false
  end

end

class Game
  attr_reader :board, :num_human_players, :player_1, :player_2

  def initialize(num_human_players = 1)
    valid_num_players?(num_human_players)
    @board = Board.new
    players = generate_players(num_human_players)
    @player_1 = players.shuffle!.pop
    @player_2 = players.pop
    run!(player_1, player_2)
  end

  private

  def run!(player_1, player_2)
    until board.game_over?
      player_1.turn(board)
      player_2.turn(board) unless board.game_over?
    end
    Display.end_game(board)
  end

  def generate_players(num_human_players)
    return [HumanPlayer.new(:x), HumanPlayer.new(:o)] if num_human_players == 2
    return [HumanPlayer.new(:x), ComputerPlayer.new(:o)] if num_human_players == 1
  end

  def valid_num_players?(num_human_players)
    raise ArgumentError.new("Must choose either 1 or 2 human players") unless num_human_players == 1 || num_human_players == 2
  end

end

if ARGV.any?
  num_human_players = ARGV[0].to_i
  Game.new(num_human_players)
else
  Game.new
end