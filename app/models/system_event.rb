class SystemEvent < ApplicationRecord
  enum event_type: [ :deploy ]
end
