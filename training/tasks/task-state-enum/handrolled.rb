class Todo < ActiveRecord::Base
  class StateType < ActiveModel::Type::Value
    CODES = { 'todo' => 0, 'doing' => 1, 'done' => 2 }.freeze

    def cast(value) = value.nil? ? nil : (CODES.key(value) || value.to_s)
    def serialize(value) = CODES[cast(value)]
    def deserialize(value) = CODES.key(value)
  end

  attribute :state, StateType.new
end
