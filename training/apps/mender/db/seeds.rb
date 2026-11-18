# Sample data for development: two clinics, a few practitioners and patients.
paulista = Location.find_or_create_by!(name: "Paulista") { _1.address = "Av. Paulista 1000, São Paulo" }
pinheiros = Location.find_or_create_by!(name: "Pinheiros") { _1.address = "Rua dos Pinheiros 250, São Paulo" }
[[paulista, "Room 1"], [paulista, "Room 2"], [pinheiros, "Studio"]].each { |location, name| location.rooms.find_or_create_by!(name: name) }

physio = Treatment.find_or_create_by!(code: "PHYS") { _1.assign_attributes(name: "Physiotherapy session", duration_minutes: 45, price_cents: 18000) }
pilates = Treatment.find_or_create_by!(code: "PILA") { _1.assign_attributes(name: "Clinical pilates", duration_minutes: 60, price_cents: 15000) }

ana = Practitioner.find_or_create_by!(email: "ana@mender.example") { _1.assign_attributes(name: "Ana Souza", location: paulista, specialty: "Sports physiotherapy") }
bruno = Practitioner.find_or_create_by!(email: "bruno@mender.example") { _1.assign_attributes(name: "Bruno Lima", location: paulista, specialty: "Clinical pilates") }
ana.treatments = [physio]
bruno.treatments = [physio, pilates]
[ana, bruno].each do |practitioner|
  (1..5).each { |day| practitioner.availability_windows.find_or_create_by!(weekday: day, starts_at_minute: 480, ends_at_minute: 1080) }
end

Patient.find_or_create_by!(email: "julia@example.com") { _1.assign_attributes(name: "Julia Costa", phone: "+5511987650001") }
Patient.find_or_create_by!(email: "marcos@example.com") { _1.assign_attributes(name: "Marcos Oliveira", phone: "+5511987650002", locale: "pt-BR") }
Insurer.find_or_create_by!(code: "SAUDE") { _1.name = "Saúde Mais" }
StaffUser.find_or_create_by!(email: "rosa@mender.example") { _1.assign_attributes(name: "Rosa Pereira", access_code: "4417") }
StaffUser.find_or_create_by!(email: "helena@mender.example") { _1.assign_attributes(name: "Helena Duarte", role: "manager", access_code: "9032") }
ApiClient.find_or_create_by!(name: "Mender iOS") { _1.token = SecureRandom.hex(16) }
