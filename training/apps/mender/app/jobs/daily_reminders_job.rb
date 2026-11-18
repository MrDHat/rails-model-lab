# Runs every evening: queues a reminder for each of tomorrow's appointments.
class DailyRemindersJob < ApplicationJob
  queue_as :default

  def perform
    tomorrow = Date.current + 1
    Appointment.booked.between(tomorrow.in_time_zone, (tomorrow + 1).in_time_zone).find_each do |appointment|
      AppointmentReminderJob.perform_later(appointment)
    end
  end
end
