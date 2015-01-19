require 'rubygems'
require 'sinatra'
require "sinatra/reloader" if development?

# set :sessions, true

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => '14159265358979' 


BLACKJACK_AMOUNT = 21
DEALER_MIN_HIT = 17

helpers do
  def calculate_total(cards)
    arr = cards.map{|element| element[1]}

    total = 0
    arr.each do |card_value|
      if card_value == "A"
        total += 11
      else
        total += card_value.to_i == 0 ? 10 : card_value.to_i
      end
    end

    # correct for Aces
    arr.select{|element| element == "A"}.count.times do
      break if total <= BLACKJACK_AMOUNT
      total -= 10
    end

    total
  end

  def card_image(card)
    suit = case card[0]
      when 'H' then 'hearts'
      when 'D' then 'diamonds'
      when 'C' then 'clubs'
      when 'S' then 'spades'
    end

    value = card[1]
    if ['J', 'Q', 'K', 'A'].include?(value)
      value = case card[1]
        when 'J' then 'jack'
        when 'Q' then 'queen'
        when 'K' then 'king'
        when 'A' then 'ace'
      end
    end

    "<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"
  end

  def winner!(msg)
    @play_again = true
    @show_hit_or_stay_buttons = false
    @success = "#{msg} <strong>You win!</strong>"
  end

  def loser!(msg)
    @play_again = true
    @show_hit_or_stay_buttons = false
    @error = "#{msg} <strong>You lose!</strong>"
  end

  def tie!(msg)
    @play_again = true
    @show_hit_or_stay_buttons = false
    @success = "#{msg} <strong>It's a tie!</strong>"
  end

end

before do #this gets executed before every single action that follows; eliminates redundancy
  @show_hit_or_stay_buttons = true
end

get '/' do
  if session[:player_name]
    redirect '/game'
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  erb :new_player
end

post '/new_player' do
  if params[:player_name].empty?
    @error = "Name is required."
    halt erb(:new_player)
  end

  session[:player_name] = params[:player_name] #NB: player_name is the name attribute from the new_player.erb line 3
  redirect '/game'
end

get '/game' do
  session[:turn] = session[:player_name]

  suits = ['H', 'D', 'C', 'S']
  values = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']
  session[:deck] = suits.product(values).shuffle!

  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop

  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop

  player_total = calculate_total(session[:player_cards])
  if player_total == BLACKJACK_AMOUNT
    winner!("You hit blackjack.")
  elsif player_total > BLACKJACK_AMOUNT
    loser!("You busted at #{player_total}.")
  end

  erb :game # if we redirect to /game, the game would reset
end

post '/game/player/stay' do
  @success = "You have chosen to stay."
  @show_hit_or_stay_buttons = false
  redirect '/game/dealer'
end

get '/game/dealer' do
  session[:turn] = "dealer"
  @show_hit_or_stay_buttons = false

  dealer_total = calculate_total(session[:dealer_cards])

  if dealer_total == BLACKJACK_AMOUNT
    loser!("Dealer hit blackjack.")
  elsif dealer_total > BLACKJACK_AMOUNT
    winner!("Dealer busted at #{dealer_total}.")
  elsif dealer_total >= DEALER_MIN_HIT
    redirect '/game/compare'
  else
    @show_dealer_hit_button = true
  end

  erb :game
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'
end

get '/game/compare' do
  @show_hit_or_stay_buttons = false

  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])

  if player_total < dealer_total
    loser!("You stayed at #{player_total} and the dealer stayed at #{dealer_total}.")
  elsif player_total > dealer_total
    winner!("You stayed at #{player_total} and the dealer stayed at #{dealer_total}.")
  else
    tie!("Both you and the dealer stayed at #{player_total}.")
  end

  erb :game
end

get '/game_over' do
  erb :game_over
end