class Writer < ActiveRecord::Base
end

class Book < ActiveRecord::Base
  belongs_to :writer
end

module BookList
  def self.lines
    Book.includes(:writer).order(:title).map { "#{_1.title} by #{_1.writer.name}" }
  end
end
