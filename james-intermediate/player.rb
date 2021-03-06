require 'yaml'

class Player
	
	Cardinals = [:left, :right, :forward, :backward]
	
	def initialize
		@bound_enemies = false
	end
	
  def play_turn(warrior)
    # add your code here
		@warrior = warrior
		sense
		rescue_ticking || 
		move_towards_ticking || 
		bind_enemies ||
		engage_enemies || 
		rest_till_healed || 
		rescue_captives || 
		move_towards_destination ||
		walk_toward_stairs
  end

private

	def sense
		@ticking = warrior.listen.select{|space| space.ticking? && space.captive?}
		@enemies = Cardinals.select{|direction| warrior.feel(direction).enemy?}
		@empty = Cardinals.select{|direction| warrior.feel(direction).empty? && !warrior.feel(direction).stairs?}
		@destination = @ticking.first || warrior.listen.first
	end
	
	def rescue_ticking
		ticking = Cardinals.select{|direction| warrior.feel(direction).ticking? && warrior.feel(direction).captive?}
		warrior.rescue!(ticking.first) unless ticking.empty?
	end
	
	def move_towards_ticking
		move_towards_destination unless @ticking.empty? 
	end
	
	def move_towards_destination
		if @destination
			direction = warrior.direction_of(@destination)
			direction = @empty.first unless (warrior.feel(direction).empty? && !warrior.feel(direction).stairs?)
			warrior.walk!(direction) unless @empty.size == 1 && direction == :backward
		end
	end
	
	def bind_enemies
		if enemies.size >= 2
			@bound_enemies = true
			warrior.bind!(enemies.first)
		end
	end

	def engage_enemies
		warrior.attack!(enemies.first) unless enemies.empty?
	end
	
	def rescue_captives
		captives = Cardinals.select{|direction| warrior.feel(direction).captive?}
		unless captives.empty?
				warrior.rescue!(captives.first)	
		end
	end
	
	def rest_till_healed
		warrior.rest! if warrior.health < 17 && (@destination || warrior.listen.select{|space| space.enemy?}.size > 0)
	end
	
	def walk_toward_stairs
		warrior.walk! warrior.direction_of_stairs
	end
	
	def warrior
		@warrior
	end
	
	def enemies
		@enemies
	end
end                                                                                             