class Project < ActiveRecord::Base
  validates :slug, presence: true
  validate :slug_not_taken

  private

  def slug_not_taken
    taken = Project.where(account_id: account_id).where('LOWER(slug) = ?', slug.to_s.downcase).where.not(id: id)
    errors.add(:slug, :taken) if taken.exists?
  end
end
