class Board < ActiveRecord::Base
  has_many :cards
end

class Card < ActiveRecord::Base
  belongs_to :board
  after_save { board.touch }
  after_destroy { board.touch }
end
