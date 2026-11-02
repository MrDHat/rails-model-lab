# Expected credit 1.0: joins and plucks both columns in one query.
class Writer < ActiveRecord::Base
end

class Book < ActiveRecord::Base
  belongs_to :writer
end

module BookList
  def self.lines
    Book.joins(:writer).order(:title).pluck(:title, "writers.name").map { |title, name| "#{title} by #{name}" }
  end
end
