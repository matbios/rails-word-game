require 'open-uri'

class WordGameController < ApplicationController

  def game
     grid = generate_grid(9)
     @grid = grid.join(" ")
  end

  def score
    end_time_date = Time.now
    @end_time = end_time_date.to_i.to_f * 1000
    @attempt = params[:attempt]
    @start_time = params[:start_time].to_i
    @grid = params[:grid]
    # @duree = @end_time.to_i - @start_time.to_i
    run_game(@attempt, @grid, @start_time, @end_time)
  end

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a[rand(26)] }
  end

  def is_included?(guess, grid)
    guess.split("").all?{ |letter| grid.include? letter }
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60000.0) ? 0 : attempt.size * (1.0 - time_taken / 60000.0)
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time, score: 0 }
    @duree = result[:time]

    result[:translation] = get_translation(attempt)
    @translation = result[:translation]

    unless result[:translation]
      result[:message] = "not an english word"
      @message = result[:message]
    else
      if is_included?(attempt.upcase, grid)
        result[:score] = compute_score(attempt, result[:time])
        @score = result[:score]
        result[:message] = "well done"
        @message = result[:message]
      else
        result[:message] = "not in the grid"
        @message = result[:message]
      end
    end

    result
  end

  def get_translation(word)
    response = open("http://api.wordreference.com/0.8/80143/json/enfr/#{word.downcase}")
    json = JSON.parse(response.read.to_s)
    json['term0']['PrincipalTranslations']['0']['FirstTranslation']['term'] unless json["Error"]
  end


end