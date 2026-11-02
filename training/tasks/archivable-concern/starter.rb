module Archivable
end

class Note < ActiveRecord::Base
  include Archivable
end

class Doc < ActiveRecord::Base
  include Archivable
end
