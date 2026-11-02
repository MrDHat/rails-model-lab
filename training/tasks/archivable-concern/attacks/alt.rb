# Expected credit 0.0: archives to a fixed date and re-archives archived rows.
module Archivable
  extend ActiveSupport::Concern

  included do
    scope :archived, -> { where.not(archived_at: nil) }
    scope :active, -> { where(archived_at: nil) }
  end

  class_methods do
    def archive_all!
      all.update_all(archived_at: Time.utc(2000))
    end
  end

  def archive!
    update!(archived_at: Time.utc(2000))
  end
end

class Note < ActiveRecord::Base
  include Archivable
end

class Doc < ActiveRecord::Base
  include Archivable
end
