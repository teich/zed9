class WorkoutJob < Struct.new(:workout_id)
  def perform
    Workout.find(self.workout_id).perform
  end
end