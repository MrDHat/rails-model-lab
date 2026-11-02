module Archivable
  def self.included(base)
    base.scope :archived, -> { where.not(archived_at: nil) }
    base.scope :active, -> { where(archived_at: nil) }
    base.extend(ClassMethods)
  end

  module ClassMethods
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
