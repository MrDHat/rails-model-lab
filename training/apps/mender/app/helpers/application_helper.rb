module ApplicationHelper
  def money(cents) = number_to_currency(cents / 100.0, unit: "R$ ", separator: ",", delimiter: ".")

  def clinic_time(time) = time && l(time, format: "%H:%M")
end
