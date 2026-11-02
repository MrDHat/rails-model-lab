class Lead < ActiveRecord::Base
end

module LeadImport
  def self.call(rows)
    conn = Lead.connection
    values = rows.map { "(#{conn.quote(_1[:email])}, #{conn.quote(_1[:source])})" }.join(', ')
    conn.execute("INSERT INTO leads (email, source) VALUES #{values} ON CONFLICT (email) DO NOTHING")
  end
end
