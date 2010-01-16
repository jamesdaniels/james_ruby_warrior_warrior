class Player
	
	Cardinals = [:forward, :backward]
	#Wounded, CriticallyWounded = 1, 1
	
	def initialize
		@resting = false
		@retreating = false
		@touched = {:forward => false, :backward => false}
		@just_started = true
		@walking_direction = :forward
	end
	
  def play_turn(warrior)
		@warrior = warrior
		sense
		save_captive || rest || retreat || shoot_back || shoot || attack || walk
		remember
  end 

private

	def remember
		@health = warrior.health
		@just_started = false
	end
	
	def sense
		@health ||= warrior.health
		@currently_under_attack = warrior.health < @health
	end

	def warrior
		@warrior
	end
	
	def save_captive
		captives = Cardinals.select{|direction| warrior.feel(direction).captive?}
		warrior.rescue!(captives.first) unless captives.empty?
	end
	
	def enemies(direction)
		warrior.look(direction).select{|a| a.enemy?}.size
	end
	
	def enemies?
		enemies(:forward) + enemies(:backward) > 0
	end
	
	def rest
		#if warrior.health < Wounded && (!enemies? || !@currently_under_attack) && !can_push_through
		#	@retreating = (warrior.health == 20)
		#	warrior.rest!
		#end
	end
	
	def attack
		if warrior.feel.enemy?
			warrior.attack!
		end
	end
	
	def no_innocents?
		first_target = warrior.look(:forward).select{|a| !a.empty?}.first
		!first_target.captive?
	end
	
	def dangerous?
		all_enemies = warrior.look(@walking_direction).map{|a| a.to_s}
		all_enemies.count('Wizard') > 0 ||
		all_enemies.count('Sludge') > 1 ||
		all_enemies.count('Thick Sludge') > 0 ||
		all_enemies.count('Archer') > 0
	end
	
	def shoot_back
		warrior.shoot!(:backward) if enemies(:backward) > 0 && !warrior.feel.enemy? && !warrior.feel(:backward).enemy?
	end
	
	def shoot
		warrior.shoot! if dangerous? && no_innocents? && !warrior.feel.enemy? && !warrior.feel(:backward).enemy?
	end
	
	def need_to_retreat?
		warrior.health < CriticallyWounded && enemies?
	end
	
	def see_wall?(direction)
		(warrior.look(direction).select{|a| a.wall? || a.stairs?}.size > 0) && (@touched[direction] = true)
	end
	
	def see_exit?(direction)
		warrior.look(direction).select{|a| a.stairs?}.size > 0
	end
	
	def can_push_through
		!enemies? || @touched[other_direction] && see_exit?(@walking_direction)
	end
	
	def retreat
		#warrior.walk!(:backward) if !can_push_through && need_to_retreat? && @currently_under_attack
	end

	def nothing_of_interest(direction)
		warrior.look(direction).select{|a| !a.empty? && !a.wall?}.size == 0
	end
	
	def change_direction?
		see_wall?(@walking_direction) && !@touched[other_direction] && (see_exit?(@walking_direction) || nothing_of_interest(@walking_direction)) ||
		see_wall?(other_direction) && !nothing_of_interest(other_direction)
	end
	
	def other_direction
		(Cardinals - [@walking_direction]).first
	end
	
	def change_direction
		@walking_direction = other_direction if change_direction?
	end
	
	def walk
		change_direction
		warrior.walk!(@walking_direction)
	end
	
end