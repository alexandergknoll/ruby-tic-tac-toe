require_relative "classes"

class Game
  attr_reader :board, :num_human_players

  def initialize(num_human_players = 1)
    raise ArgumentError.new("Must choose either 1 or 2 human players") unless num_human_players == 1 || num_human_players == 2
    @board = Board.new
    @num_human_players = num_human_players
    Display.start_game(board)
    first_player = choose_first_player
    second_player = choose_second_player(first_player)
    run!(first_player, second_player)
  end

  private

  def run!(first_player, second_player)
    until board.game_over?
      turn(first_player)
      turn(second_player) unless board.game_over?
    end
    Display.end_game(board)
  end

  def turn(player)
    square_num = 0
    if computers_turn?(player)
      Display.turn(player, board)
      square_num = ComputerPlayer.evaluate_move(board)
    else
      until board.valid_move?(square_num)
        Display.turn(player, board)
        square_num = $stdin.gets.chomp.to_i
      end
    end
    board.make_move(player, square_num)
  end

  def choose_first_player
    [:x, :o].sample
  end

  def choose_second_player(first_player)
    case first_player
    when :x
      :o
    when :o
      :x
    end
  end

  def computers_turn?(player)
    if player == :o && num_human_players == 1
      return true
    else
      return false
    end
  end

end

if ARGV.any?
  num_human_players = ARGV[0].to_i
  Game.new(num_human_players)
else
  Game.new
end