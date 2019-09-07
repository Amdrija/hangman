require "yaml"

class Hangman
  TRIES = 10
  SAVE_KEYWORD = "<save>"
  def initialize
    reset
  end

  def reset
    @secret_word = random_word.downcase
    @display_word = "_ " * @secret_word.length
    @tries_left = TRIES
    @failed_letters = ""
    play
  end

  def play
    won = false
    display_information
    loop do
      won = play_turn
      break if @tries_left == 0 || won
    end

    if won == "save"
      puts "Successfully saved the game."
      return
    elsif won
      winning_message
    else
      losing_message
    end
  end


  private

  def save_progress
    save_file = File.open("save/save.yaml","w")
    save_file.write(YAML.dump(self))
    save_file.close
  end

  def play_turn
    guess = get_guess
    if save_keyword?(guess)
      save_progress
      return "save"
    end

    if guess.length > 1
      won = guess_word(guess)
    else
      won = guess_letter(guess)
    end
    display_information
    won
  end

  def display_information
    puts @display_word
    puts @failed_letters
    puts "You have #{@tries_left} tries left."
    puts "********************"
  end

  #if the guess was a word
  def guess_word(word)
    won = won?(word)
    @tries_left -= 1 unless won
    won
  end

  #if the guess was a letter
  def guess_letter(letter)
    won = false
    failed_guess = feedback(letter)
    if failed_guess
       @tries_left -= 1
    else
      won = won?(@display_word.split(" ").join(""))
    end
    won
  end

  def get_guess
    guess = ""
    loop do
      puts "Enter a letter or try to guess the whole word between 5 and 12 characters."
      guess = gets.chomp.downcase
      break if guess_valid?(guess)
    end
    guess
  end

  def won?(guess)
    @secret_word == guess
  end
  def winning_message
    puts "Congratulations, you win."
  end

  def losing_message
    puts "Unfortunately, you lost."
  end

  #checks if the letter is in the word
  #if it is, then replaces "_" in display_Word
  # with that letter
  def check_word(letter)
    i = 0
    @secret_word.each_char do |char|
      if char == letter
        @display_word[i] = letter
      end
      i += 2 ##because in display word after each letter or underscore there is a space
    end
    return @display_word
  end

  #if the letter is in the word returns false
  #if its not in the word, it is a fail letter
  def fail_letter?(letter)
    return @secret_word.include?(letter) ? false : letter
  end

  def feedback(letter)
    check_word(letter)
    fail_letter = fail_letter?(letter)
    @failed_letters += " #{fail_letter}" if fail_letter
    fail_letter
  end


  def random_word
    word_file = File.open("res/words.txt","r")
    rand(61405).times do
      word_file.readline.chomp
    end
    word = word_file.readline.chomp
    while !word_valid?(word)
      word = word_file.readline.chomp
    end
    word
  end

  def word_valid?(word)
    word.length >= 5 && word.length <= 12 && !word.match?(/[^a-z]/)
  end

  def guess_valid?(guess)
    if guess.length == 1
      return !@display_word.include?(guess) && !@failed_letters.include?(guess) && guess.match?(/[a-z]/)
    end
    return word_valid?(guess) || save_keyword?(guess)
  end

  def save_keyword?(guess)
    guess == SAVE_KEYWORD
  end
end

class Game
  def initialize
    reset
  end

  private
  def reset
    greeting
    if File.exists?("save/save.yaml") && load_game? 
      File.open("save/save.yaml","r") do |f|
        @hangman = YAML.load(f.read)
        @hangman.play
      end
    else
      @hangman = Hangman.new
    end
    if play_again?
      reset
    end
  end
  def greeting
    puts "################## HANGMAN #######################"
    puts "######### Game Rules & Instructions ##############"
    puts "##################################################"
    puts "###### Your objective is to guess the secret #####"
    puts "######## word that will be represented with ######"
    puts "######## \"-\" for every letter of the word #######"
    puts "######## for example: for the word \"hello\" ######"
    puts "############ you will see \"- - - - -\" ###########"
    puts "##### the letters in the hidden word will be  #####"
    puts "##### revealed according to your correct guess ####"
    puts "###### example: if you guessed the letter \"e\" ###"
    puts "############## for the word \"hello\" #############"
    puts "###### the hidden word will show:\"- e - - -\" ####"
    puts "############ in case your guess was wrong #########"
    puts "######### your fail count will go up  #############"
    puts "# in any moment, you can try to guess the whole ###"
    puts "### word ,for correct guess you win the round #####"
    puts "############ else you lose a fail #################"
    puts "### overall, you have 8 fails until you lose.######"
    puts "###################################################"
    puts "####### either way for every try you will #########"
    puts "##### see the used letters, so you don't need #####"
    puts "#### to remember the letters you allready used ####"
    puts "############### INPUT Options :####################"
    puts "### Type in --save to save the current progress ###"
    puts "#################### GOOD LUCK ####################"
    puts "###################################################"
    puts "\n"
  end

  def load_game?
    puts "Do you want to load the previous game?"
    answer = gets.chomp.upcase
    answer == "Y"
  end

  def play_again?
    puts "Play again? Y/n"
    again = gets.chomp.upcase
    return again == "Y"
  end
end

Game.new