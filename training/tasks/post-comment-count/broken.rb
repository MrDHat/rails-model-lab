class Article < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :article
  after_create { article.increment!(:comments_count) }
end
