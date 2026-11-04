power = Category.find_or_create_by!(name: "Power tools")
garden = Category.find_or_create_by!(name: "Garden")
ana = Member.find_or_create_by!(email: "ana@example.com") { _1.name = "Ana" }
Member.find_or_create_by!(email: "bo@example.com") { _1.name = "Bo" }
drill = Tool.find_or_create_by!(serial: "DR-001") { |t| t.name = "Cordless drill"; t.category = power; t.daily_fee_cents = 300 }
Tool.find_or_create_by!(serial: "HT-001") { |t| t.name = "Hedge trimmer"; t.category = garden; t.daily_fee_cents = 250 }
Loan.find_or_create_by!(member: ana, tool: drill) { _1.due_on = Date.current + 3 }
