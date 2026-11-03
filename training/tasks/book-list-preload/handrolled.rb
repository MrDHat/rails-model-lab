class Writer < ActiveRecord::Base
end

class Book < ActiveRecord::Base
  belongs_to :writer
end

module BookList
  def self.lines
    books = Book.order(:title).to_a
    writers = Writer.where(id: books.map(&:writer_id)).index_by(&:id)
    books.map { "#{_1.title} by #{writers[_1.writer_id].name}" }
  end
end
