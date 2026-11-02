class EncryptedString < ActiveModel::Type::String
  ENCRYPTOR = ActiveSupport::MessageEncryptor.new('e' * 32)

  def serialize(value)
    value.nil? ? nil : ENCRYPTOR.encrypt_and_sign(value)
  end

  def deserialize(value)
    value.nil? ? nil : ENCRYPTOR.decrypt_and_verify(value)
  end
end

class Patient < ActiveRecord::Base
  attribute :tax_id, EncryptedString.new
end
