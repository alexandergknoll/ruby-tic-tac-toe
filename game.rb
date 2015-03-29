require_relative "classes"

class Game
  attr_reader :board, :num_human_players

  def initialize(num_human_players = 1)
    @board = Board.new
    @num_human_players = num_human_players
    valid_num_players?
    run!(generate_players)
  end

  private

  def run!(players)
    until board.game_over?
      players.each {|player| player.turn(board) unless board.game_over?}
    end
    Display.end_game(board)
  end

  def generate_players
    if num_human_players == 2
      return [HumanPlayer.new(symbol: :x), HumanPlayer.new(symbol: :o)].shuffle
    else
      return [HumanPlayer.new(symbol: :x), ComputerPlayer.new(symbol: :o)].shuffle
    end
  end

  def valid_num_players?
    raise ArgumentError.new("Must choose either 1 or 2 human players") unless num_human_players == 1 || num_human_players == 2
  end

end

if ARGV.any?
  num_human_players = ARGV[0].to_i
  Game.new(num_human_players)
else
  Game.new
end