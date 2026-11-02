class Exporter
  class << self
    attr_accessor :columns
  end
  self.columns = %w[id]

  def columns = self.class.columns
end
