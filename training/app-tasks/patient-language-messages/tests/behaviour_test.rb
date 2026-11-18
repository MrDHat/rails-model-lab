require "test_helper"

class PatientLanguageMessagesTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup { travel_to Time.utc(2026, 6, 14, 12) }
  teardown { travel_back }

  test "Portuguese reminders" do
    AppointmentReminderJob.perform_now(appointments(:marcos_monday))
    assert_equal "Olá Marcos, lembrete da sua consulta com Ana Souza em seg 15 jun, 11:00 na Mender Paulista. Responda C para cancelar.",
                 SmsGateway.sent.sole[:body]
  end

  test "English ones are unchanged, even right after a Portuguese one" do
    AppointmentReminderJob.perform_now(appointments(:marcos_monday))
    AppointmentReminderJob.perform_now(appointments(:julia_monday))
    assert_equal "Hi Julia, a reminder of your appointment with Ana Souza on Mon 15 Jun, 09:00 at Mender Paulista. Reply C to cancel.",
                 SmsGateway.sent.last[:body]
    assert_equal :en, I18n.locale
  end

  test "Portuguese waitlist offers" do
    entry = WaitlistEntry.create!(patient: patients(:lucia), practitioner: practitioners(:ana), treatment: treatments(:physio),
                                  earliest_on: Date.new(2026, 6, 15), latest_on: Date.new(2026, 6, 19))
    WaitlistOfferJob.perform_now(entry, Time.utc(2026, 6, 17, 12))
    assert_equal "Olá Lúcia, abriu um horário com Ana Souza em qua 17 jun, 09:00. Reserve pelo app da Mender antes que outra pessoa o faça.",
                 SmsGateway.sent.sole[:body]
    assert_equal :en, I18n.locale
  end

  test "Portuguese confirmation and cancellation emails" do
    mail = AppointmentMailer.confirmation(appointments(:marcos_monday))
    assert_equal "Sua consulta na Mender em seg 15 jun, 11:00", mail.subject
    assert_includes mail.body.to_s, "Olá Marcos,"
    assert_includes mail.body.to_s, "Sua sessão de Sports massage com Ana Souza está marcada para segunda-feira, 15 de junho de 2026 às 11:00"
    assert_includes mail.body.to_s, "Para ver ou cancelar sua reserva, abra:"
    cancelled = AppointmentMailer.cancellation(appointments(:marcos_cancelled))
    assert_equal "Cancelada: sua consulta na Mender em qua 10 jun, 09:00", cancelled.subject
    assert_equal :en, I18n.locale
  end

  test "English emails are unchanged" do
    AppointmentMailer.confirmation(appointments(:marcos_monday)).deliver_now
    mail = AppointmentMailer.confirmation(appointments(:julia_monday))
    assert_equal "Your Mender appointment on Mon 15 Jun, 09:00", mail.subject
    assert_includes mail.body.to_s, "Hello Julia,"
  end

  test "a Portuguese booking made in the app gets a Portuguese email, and the API stays English" do
    integration = ActionDispatch::Integration::Session.new(Rails.application)
    headers = { "Authorization" => "Bearer #{api_clients(:ios).token}" }
    perform_enqueued_jobs do
      integration.post "/api/appointments", headers: headers, as: :json,
                                            params: { patient_id: patients(:marcos).id, practitioner_id: practitioners(:carla).id,
                                                      treatment: "MASS", starts_at: "2026-06-15T10:00:00-03:00" }
    end
    assert_equal "Sua consulta na Mender em seg 15 jun, 10:00", ActionMailer::Base.deliveries.last.subject
    integration.post "/api/appointments", headers: headers, as: :json,
                                          params: { patient_id: patients(:marcos).id, practitioner_id: practitioners(:carla).id,
                                                    treatment: "PILA", starts_at: "2026-06-15T12:00:00-03:00" }
    assert_equal ["Treatment is not offered by Carla Mendes"], integration.response.parsed_body["errors"]
  end
end
