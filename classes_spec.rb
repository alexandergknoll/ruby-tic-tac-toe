require_relative "classes"

describe Square do
  let(:square) {Square.new}

  describe "#value" do
    it "should be nil for a new instance" do
      expect(square.value).to be nil
    end
  end

  describe "#make_move" do
    it "should assign a value attribute" do
      square.make_move(:x)
      expect(square.value).to be :x
    end
  end
  
end

describe Board do
  let(:board) {Board.new}

  describe "#winner" do
    it "should be nil for a new instance" do
      expect(board.winner).to be nil
    end
  end

  describe "#make_move" do
    it "should change the value of the square it calls on to player value" do
      player = [:x,:o].sample
      square_num = rand(1..9)
      y = BoardMath.transform_y_index(square_num)
      x = BoardMath.transform_x_index(square_num)
      expect{board.make_move(player,square_num)}.to change{board.squares[y][x].value}.from(nil).to(player)
    end
  end

  describe "#valid_move?" do
    it "should return true for a new board for any value between 1 and 9" do
      square_num = rand(1..9)
      expect(board.valid_move?(square_num)).to be true
    end
    it "should return false for any value less than 1" do
      square_num = rand(-100..0)
      expect(board.valid_move?(square_num)).to be false
    end
    it "should return false for any value greater than 9" do
      square_num = rand(10..100)
      expect(board.valid_move?(square_num)).to be false
    end
    it "should return false if a move has already been made on that square" do
      player = [:x,:o].sample
      square_num = rand(1..9)
      board.make_move(player,square_num)
      expect(board.valid_move?(square_num)).to be false
    end
  end

  describe "#game_over?" do
    it "should return false for a new board" do
      expect(board.game_over?).to be false
    end
    it "should return true for the same 3 values in a row" do
      player = [:x,:o].sample
      row_values = [[1,2,3],[4,5,6],[7,8,9]].sample
      row_values.each {|square_num| board.make_move(player, square_num)}
      expect(board.game_over?).to be true
    end
    it "should return true for the same 3 values in a column" do
      player = [:x,:o].sample
      column_values = [[1,4,7],[2,5,8],[3,6,9]].sample
      column_values.each {|square_num| board.make_move(player, square_num)}
      expect(board.game_over?).to be true
    end
    it "should return true for the same 3 values diagonally" do
      player = [:x,:o].sample
      diagonal_values = [[1,5,9],[3,5,7]].sample
      diagonal_values.each {|square_num| board.make_move(player, square_num)}
      expect(board.game_over?).to be true
    end
  end

end

describe "BoardMath" do
  let(:y_index_transforms) {{1 => 0, 2 => 0, 3 => 0, 4 => 1, 5 => 1, 6 => 1, 7 => 2, 8 => 2, 9 => 2}}
  let(:x_index_transforms) {{1 => 0, 2 => 1, 3 => 2, 4 => 0, 5 => 1, 6 => 2, 7 => 0, 8 => 1, 9 => 2}}
  let(:square_num_transforms) {{"00" => 1, "01" => 2, "02" => 3, "10" => 4, "11" => 5, "12" => 6, "20" => 7, "21" => 8, "22" => 9}}

  describe "#transform_to_square_num" do
    it "should return the correct square number for an x and y value" do
      y = rand(3)
      x = rand(3)
      expect(BoardMath.transform_to_square_num(y, x)).to eq(square_num_transforms["#{y}#{x}"])
    end
  end

  describe "#transform_to_index" do
    it "should decrease the value of square_num by 1" do
      square_num = rand(1..9)
      expect(BoardMath.transform_to_index(square_num)).to eq(square_num - 1)
    end
  end

  describe "#transform_y_index" do
    it "should return the correct y index for a square_num" do
      square_num = rand(1..9)
      expect(BoardMath.transform_y_index(square_num)).to eq(y_index_transforms[square_num])
    end
  end

  describe "#transform_x_index" do
    it "should return the correct x index for a square_num" do
      square_num = rand(1..9)
      expect(BoardMath.transform_x_index(square_num)).to eq(x_index_transforms[square_num])
    end
  end

end