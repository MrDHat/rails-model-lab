module Archivable
  extend ActiveSupport::Concern

  included do
    scope :archived, -> { where.not(archived_at: nil) }
    scope :active, -> { where(archived_at: nil) }
  end

  class_methods do
    def archive_all!
      active.update_all(archived_at: Time.current)
    end
  end

  def archive!
    update!(archived_at: Time.current)
  end
end

class Note < ActiveRecord::Base
  include Archivable
end

class Doc < ActiveRecord::Base
  include Archivable
end
