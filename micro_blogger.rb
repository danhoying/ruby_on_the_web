require 'jumpstart_auth'
require 'bitly'

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing..."
    @client = JumpstartAuth.twitter
  end

  def run
    puts "Welcome to the JSL Twitter Client!"
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
      when 'spam' then spam_my_followers(parts[1..-1].join(" "))
      when 'elt' then everyones_last_tweet
      when 's' then shorten(parts[1])
      when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
      else
        puts "Sorry, I don't know how to #{command}"
      end
    end
  end

  def tweet(message)
    if message.length <= 140
      @client.update(message)
    else
      puts "Your message is over the 140 character limit. Tweet not posted."
    end
  end

  def dm(target, message)
    puts "Trying to send #{target} this direct message:"
    puts message
    message = "d @#{target} #{message}"
    screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
    if screen_names.include?(target) 
      tweet(message)
    else
      "You can only Direct Message followers.  DM not sent."
    end
  end

  def followers_list
    screen_names = []
    @client.followers.each { |follower| screen_names << @client.user(follower).screen_name}
    return screen_names
  end

  def spam_my_followers(message)
    followers = followers_list
    followers.each { |follower| dm(follower, message)}
  end

  def everyones_last_tweet
    friends = friends.map { |friend| @client.user(friend) }
    sorted_friends = friends.sort_by { |friend| friend.screen_name.downcase }
    sorted_friends.each do |friend|
      timestamp = friend.status.created_at
      puts "#{friend.screen_name} said this on #{timestamp.strftime("%A, %b %d")}..."
      puts friend.status.text
      puts ""
    end
  end

  def shorten(original_url)
    Bitly.use_api_version_3
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    short_url = bitly.shorten(original_url).short_url
    puts "Shortening this URL: #{original_url} into #{short_url}"
    return short_url
  end
end

blogger = MicroBlogger.new
blogger.run