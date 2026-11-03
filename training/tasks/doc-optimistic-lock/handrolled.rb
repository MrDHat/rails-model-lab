class Page < ActiveRecord::Base
  before_update :claim_revision

  private

  def claim_revision
    claimed = Page.where(id: id, revision: revision_was).update_all(revision: revision_was + 1)
    raise ActiveRecord::StaleObjectError.new(self, 'update') if claimed.zero?
    self.revision = revision_was + 1
  end
end
