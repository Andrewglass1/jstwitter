#requirements
require 'jumpstart_auth'
require 'bitly'
require 'Launchy'
require 'klout'
#require 'rocky-klout'

#classes
class JSTwitter
  attr_reader :client


  def initialize
    puts "Initializing"
    @client = JumpstartAuth.twitter
    @k = Klout::API.new('w7cd26nt27pzgy4gj7waruw2') #, {:format => 'xml', :secure => true})
  end

  def run 
    puts "welcome to the jsl twitter client!"
    command = ""
    while command != "q"
    printf "enter command: "
    input = gets.chomp
    parts = input.split(" ")
    command = parts[0]
    case command
    when 'q' then puts "Goodbye!"
    when 't' then tweet(parts[1..-1].join(" "))
    when 'dm' then dm(parts[1], parts[2..-1].join(" "))
    when 's' then shorten(parts[1..-1].join(" "))
    when 'klout' then print_klouts
    when 'find_pop' then find_poppies
    when 'followers_list' then followers_list
    when "spam_pop" then spam_populars
    when 'spam' then spam_my_followers(parts[1..-1].join(" "))
    when 'elt' then everyones_last_tweet
    when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
    when 'all_followers' then puts followers_list
    when 'trend' then trends
    else
      puts "Sorry, I don't know how to #{command}"
    end
    end
  end

  def tweet(message)
    if message.length <= 140
      @client.update(message)
    else
      puts "your message is too long"
    end
  end

  def followers_list
    screen_names = []
    @client.followers.each do |follower, i|
      break if i ==2
      screen_names << follower["screen_name"]
    end
    puts screen_names
    screen_names
  end

  def everyones_last_tweet
    friends = []
    @client.friends.each do |friend|
      friends << friend["screen_name"]
    end
    friends.each do |friend|
      timestamp = friend.status.created_at.to_s
      tweet_date = Date.parse(timestamp)
      puts "#{friend.screen_name} said this on #{tweet_date.strftime("%A, %b %d")}..."
      puts friend.status.text
      puts ''
    end
  end

  def klout_around
    @klouthash = Hash.new
    friends = followers_list
    #friends= ["andrewglass1","mikec","melanieeeg"]
    friends.each do |friend|
      @klouthash[friend] = @k.klout(friend)["users"][0]["kscore"]
    end
  end

  def print_klouts
    klout_around
    @klouthash = @klouthash.sort_by {|key, value| value}.reverse
      @klouthash.each{|key, value| puts "#{key} has a clout score #{value}"}
  end

  def find_poppies
    klout_around
    puts "enter a min klout score to judge popularity"
    minscore = gets.to_i
    @popularkids = Hash.new
    @klouthash.each do |key, value|
      if value > minscore
        @popularkids[key] = value
      end
    end
    @popularkids.each{|key, value| puts "#{key} is popular with a #{value}"}
  end

  def spam_populars
    find_poppies
    puts "you follow #{@popularkids.length} popular kids.  type 'yes' to spam them?"
    answer = gets.chomp
    if answer == "yes"
      puts "what do you want to spam them with?"
      message = gets.chomp
      @popularkids.each do |follower|
        follower = follower[0]
        dm(follower, message)
      end
    else
      "you are kind"
    end
  end

  def spam_my_followers(message)
    followers_list.each do |follower, i|
      break if i ==2
      dm(follower, message)
    end
  end
  
  def dm(target, message)
    screen_names = @client.followers.collect{|follower| follower.screen_name}
    puts "Trying to send #{target} this direct message:"
    puts message
    dmessage = "d "+target+" "+message
    if screen_names.include? target
      tweet(dmessage)
    else
      puts 'you cant dm if not following'
    end
  end

  def shorten(original_url)
    Bitly.use_api_version_3
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    return bitly.shorten(original_url).short_url
    puts bitly.shorten(original_url).short_url
  end

  def trends
    Twitter.local_trends(2487956)
  end

end

#script
jst = JSTwitter.new

jst.run
#jst.find_poppies