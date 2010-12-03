class Item < ActiveRecord::Base
    has_many   :attrs
    belongs_to :domain
end