module RanksAndSuits
  def standard_ranks
    {
      ace: 1, king: 2, queen: 3, jack: 4,
      10 => 5, 9 => 6, 8 => 7, 7 => 8, 6 => 9,
      5 => 10, 4 => 11, 3 => 12, 2 => 13,
    }
  end

  def belote_ranks
    {ace: 1, 10 => 2, king: 3, queen: 4, jack: 5, 9 => 6, 8 => 7, 7 => 8}
  end

  def sixty_six_ranks
    {ace: 1, 10 => 2, king: 3, queen: 4, jack: 5, 9 => 6}
  end

  def card_suits
    [:spades, :hearts, :diamonds, :clubs]
  end
end

module KingsAndQueensMethods
  def belote?(cards)
    kings_queens = cards.find_all { |x| x.rank == :king or x.rank == :queen }
    kings_queens.sort_by! { |x| [x.suit, belote_ranks[x.rank]] }
    same_suit = -> (card_group) { card_group[0].suit == card_group[1].suit }
    kings_queens.each_cons(2).any?(&same_suit)
  end
end

class Card
  def initialize(rank, suit)
    @rank, @suit = rank, suit
  end

  attr_reader :rank
  attr_reader :suit

  def to_s
    rank_to_s, suit_to_s = @rank.to_s, @suit.to_s
    rank_to_s.capitalize + " of " + suit_to_s.capitalize
  end

  def ==(rs)
    @rank == rs.rank and @suit == rs.suit
  end
end

class Deck
  include Enumerable, RanksAndSuits

  def initialize(cards = nil)
    @deal_cards_number = 26
    @card_ranks = standard_ranks
    initialize_cards(cards)
  end

  def each
    @cards.each { |card| yield card }
  end

  def size
    @cards.size
  end

  def draw_top_card
    @cards.delete_at(0)
  end

  def draw_bottom_card
    @cards.delete_at(-1)
  end

  def top_card
    @cards.first
  end

  def bottom_card
    @cards.last
  end

  def shuffle
    @cards.shuffle!
  end

  def sort
    @cards.sort_by! { |x| [x.suit.to_s, - @card_ranks[x.rank]] }.reverse!
  end

  def to_s
    @cards.each { |card| card.to_s }
  end

  def deal
    Hand.new(cards_to_be_dealt)
  end

  private

  def initialize_cards(cards)
    if cards.nil?
      @cards = Array.new
      rank_and_suit_combinations = @card_ranks.keys.product(card_suits)
      rank_and_suit_combinations.each { |x| @cards << Card.new(x[0], x[1]) }
    else
      @cards = cards
    end
  end

  def cards_to_be_dealt
    @cards.shift(@deal_cards_number)
  end
end

class Hand
  def initialize(card_array)
    @cards = card_array
  end

  attr_reader :cards

  def size
    @cards.size
  end
end

class WarDeck < Deck
  def deal
    WarHand.new(cards_to_be_dealt)
  end
end

class WarHand < Hand
  def play_card
    @cards.delete_at(0)
  end

  def allow_face_up?
    size <= 3
  end
end

class BeloteDeck < Deck
  def initialize(cards = nil)
    @deal_cards_number = 8
    @card_ranks = belote_ranks
    initialize_cards(cards)
  end

  def deal
    BeloteHand.new(cards_to_be_dealt)
  end
end

class BeloteHand < Hand
  include RanksAndSuits

  def highest_of_suit(suit)
    same_suit_cards = cards.find_all { |x| x.suit == suit }
    same_suit_card.min_by { |x| belote_ranks[x.rank] }
  end

  def belote?
    KingsAndQueensMethods.belote?(cards)
  end

  def tierce?
    consecutive_from_same_suit?(3)
  end

  def quarte?
    consecutive_from_same_suit?(4)
  end

  def quint?
    consecutive_from_same_suit?(5)
  end

  def carre_of_jacks?
    four_of_a_kind?(:jack)
  end

  def carre_of_nines?
    four_of_a_kind?(9)
  end

  def carre_of_aces?
    four_of_a_kind?(:ace)
  end

  private

  def consecutive_from_same_suit?(number_of_cards)
    sorted_cards = cards.sort_by { |x| [x.suit, - belote_ranks[x.rank]] }

    sorted_cards.each_cons(number_of_cards).any? do |card_group|
      same_suit = card_group.all? { |card| card.suit == card_group[0].suit }
      same_suit and consecutive_cards?(card_group)
    end
  end

  def consecutive_cards?(sorted_card_group)
    rank_plus_index = Array.new

    sorted_card_group.each_with_index do |card, i|
      rank_plus_index[i] = belote_ranks[card.rank] + i
    end
    rank_plus_index.uniq.length == 1
  end

  def four_of_a_kind?(rank)
    cards.count { |card| card.rank == rank }
  end
end

class SixtySixDeck < Deck
  def initialize(cards = nil)
    @card_ranks = sixty_six_ranks
    @deal_cards_number = 6
    initialize_cards(cards)
  end

  def deal
    SixtySixHand.new(cards_to_be_dealt)
  end
end

class SixtySixHand < Hand
  def forty?(trump_suit)
    trump_kings_and_queens = cards.find_all do |card|
      card.suit == trump_suit and
        (card.rank == :queen or card.rank == :king)
    end
    trump_kings_and_queens.size == 2
  end

  def twenty?(trump_suit)
    KingsAndQueensMethods.belote?(cards) and (not forty?(trump_suit))
  end
end