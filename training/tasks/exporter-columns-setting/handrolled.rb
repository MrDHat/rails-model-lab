class Exporter
  def self.columns
    return @columns if defined?(@columns)
    superclass.respond_to?(:columns) ? superclass.columns : %w[id]
  end

  def self.columns=(value)
    @columns = value
  end

  def columns = self.class.columns
end
