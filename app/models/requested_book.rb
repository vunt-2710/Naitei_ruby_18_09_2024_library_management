class RequestedBook < ApplicationRecord
  belongs_to :request
  belongs_to :book
end
