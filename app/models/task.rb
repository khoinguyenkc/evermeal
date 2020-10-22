class Task < ActiveRecord::Base
    belongs_to :user

    def due_in_x_days
        if self.due
        how_many_seconds_has_passed = Time.now - self.updated_at #self = item
        days_has_passed = ( how_many_seconds_has_passed.to_f / 86400.to_f ).ceil
        due_in_x_days = self.due - days_has_passed 
        else
            nil
        end
    end

end
