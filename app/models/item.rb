class Item < ActiveRecord::Base
    belongs_to :list
    belongs_to :user 

    def fresh_for_x_more_days
        if self.expire
        how_many_seconds_has_passed = Time.now - self.updated_at #self = item
        days_has_passed = ( how_many_seconds_has_passed.to_f / 86400.to_f ).ceil
        remaining_fresh_days = self.expire - days_has_passed 
        else
            nil
        end
    end
    
end
