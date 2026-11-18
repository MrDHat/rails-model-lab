module Staff
  class WaitlistEntriesController < BaseController
    def index
      @entries = WaitlistEntry.waiting.includes(:patient, :practitioner, :treatment).order(:created_at)
    end

    def create
      WaitlistEntry.create!(params.expect(waitlist_entry: %i[patient_id practitioner_id treatment_id earliest_on latest_on]))
      redirect_to staff_waitlist_entries_path, notice: "Added to the waitlist."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to staff_waitlist_entries_path, alert: e.record.errors.full_messages.to_sentence
    end

    def destroy
      WaitlistEntry.find(params[:id]).destroy!
      redirect_to staff_waitlist_entries_path, notice: "Removed."
    end
  end
end
