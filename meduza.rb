require 'datamapper'
class Meduza
  include DataMapper::Resource
  property :id,         Serial, :key => true
  property :name,       String
  property :hungry,     Float, :default => 0
  property :thirsty,    Float, :default => 0
  property :sick,       Float, :default => 0
  property :bored,      Float, :default => 0
  property :energy,     Float, :default => 100
  property :energy_max, Float, :default => 100
  property :sleep,      Boolean, :defaut => false
  property :in_torpor,  Boolean, :default => false
  property :created_at, DateTime
  
  def happy
    (300 - @hungry - @thirsty - @sick) / 3
  end
  
  def day?
    t = Time.now.hour
    t > 9 and t < 24
  end
  
  def night?
    not day?
  end
  
  def sick?
    @sick > 0
  end
  
  def daj_jesc
    @hungry -= 40
    @hungry = 0 if @hungry < 0
    save
  end
  
  def daj_pic
    @thirsty -= 20
    @thirsty = 0 if @thirsty < 0
    save
  end
  
  def pobaw_sie
    @bored -= 30
    @bored = 0 if @bored < 0
    save
  end
  
  def mod_awake
    @mod_awake ||= @sleep ? 0.02 : 0.2
  end
  
  def mod_sick
    @mod_sick ||= sick? ? 70 : 90
  end
  
  def hungry_up
    @hungry += mod_day
    @hungry = 100 if @hungry > 100
  end
  
  def thirsty_up
    @thirsty += 2 * mod_day
    @thirsty = 100 if @thirsty > 100
  end
  
  def boredom_up
    @bored += mod_day
    @bored = 100 if @bored > 100
  end
  
  def sick_up
    @sick += mod_day if @hungry > mod_sick
    @sick += mod_day if @thirsty > mod_sick
  end
  
  def sick_down
    if (sick? and hungry < 50 and thirsty < 50)
      @sick -= mod_day 
    end
  end
  
  def energy_up
    if @sleep
      @energy += @energy_max / 600 # 10 * 60
      if @energy >= @energy_max
        @energy = @energy_max
        wake_up
      end
    end
  end
  
  def energy_down
    if not @sleep
      @energy -= (0.8 * @energy_max) / (840) # 14 * 60
      if @energy <= (0.25 * @energy_max)
        go_sleep
      end
    end
  end
  
  def wake_up
    @sleep = false
  end
  
  def go_sleep
    @sleep = true
  end
  
  def torporize
    @in_torpor = true if @hungry >= 99 or @thirsty >= 99 or @sick >= 99
  end
  
  def live
    return if @in_torpor
    
    energy_up # wake_up
    energy_down # go_sleep
    hungry_up
    thirsty_up
    boredom_up
    sick_up
    sick_down
    torporize
    
  end
end