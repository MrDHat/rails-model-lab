class PractitionerTreatment < ApplicationRecord
  belongs_to :practitioner
  belongs_to :treatment

  validates :treatment_id, uniqueness: { scope: :practitioner_id }
end
