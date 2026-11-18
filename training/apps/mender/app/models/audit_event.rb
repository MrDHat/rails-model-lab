# Who changed what. staff_user is nil for changes made through the API or by
# background jobs.
class AuditEvent < ApplicationRecord
  belongs_to :staff_user, optional: true

  validates :action, :subject_type, :subject_id, presence: true

  def self.record(action, subject, **details)
    create!(action: action, subject_type: subject.class.name, subject_id: subject.id, details: details)
  end

  def subject = subject_type.constantize.find_by(id: subject_id)
end
