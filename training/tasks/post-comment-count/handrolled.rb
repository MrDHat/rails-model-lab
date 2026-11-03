class Article < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :article
  after_create :recount
  after_destroy :recount

  private

  def recount
    article.update_column(:comments_count, article.comments.count)
  end
end
