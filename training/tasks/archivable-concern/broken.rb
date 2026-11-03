module Archivable
  def archive!
    update!(archived_at: Time.current)
  end

  def self.archived = where.not(archived_at: nil)
  def self.active = where(archived_at: nil)
  def self.archive_all! = active.update_all(archived_at: Time.current)
end

class Note < ActiveRecord::Base
  include Archivable
end

class Doc < ActiveRecord::Base
  include Archivable
end
