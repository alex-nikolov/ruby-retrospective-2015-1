class Card
  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  attr_reader :rank, :suit

  def to_s
    @rank.to_s.capitalize + " of " + @suit.to_s.capitalize
  end

  def ==(right_side)
    @rank == right_side.rank and @suit == right_side.suit
  end
end

class Deck
  include Enumerable

  attr_accessor :cards

  SUITS = [:clubs, :diamonds, :hearts, :spades]

  def initialize(ranks, cards = nil)
    @ranks = ranks

    if cards
      @cards = cards
    else
      @cards = @ranks.product(SUITS).map { |rank, suit| Card.new(rank, suit) }
    end
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
    @cards.sort_by! { |card| [card.suit.to_s, @ranks.find_index(card.rank)] }
    @cards.reverse!
  end

  def to_s
    @cards.map { |card| card.to_s }.join("\n")
  end

  def deal
    Hand.new(self, 0)
  end

  class Hand
    attr_reader :cards

    def initialize(deck, size)
      @cards = deck.cards.shift(size)
    end

    def size
      @cards.size
    end
  end
end



class WarDeck < Deck
  RANKS = [2, 3, 4, 5, 6, 7, 8, 9, 10, :jack, :queen, :king, :ace]

  def initialize(cards = nil)
    super(RANKS, cards)
  end

  def deal
    Hand.new(self, 26)
  end

  class Hand < Deck::Hand
    def play_card
      @cards.delete_at(0)
    end

    def allow_face_up?
      size <= 3
    end
  end
end

class BeloteDeck < Deck
  RANKS = [7, 8, 9, :jack, :queen, :king, 10, :ace]

  def initialize(cards = nil)
    super(RANKS, cards)
  end

  def deal
    Hand.new(self, 8)
  end

  class Hand < Deck::Hand
    def highest_of_suit(suit)
      same_suit_cards = @cards.find_all { |card| card.suit == suit }
      same_suit_cards.max_by { |card| RANKS.find_index(card.rank) }
    end

    def belote?
      Deck::SUITS.any? do |suit|
        has_king = @cards.include?(Card.new(:king, suit))
        has_queen = @cards.include?(Card.new(:queen, suit))

        has_king and has_queen
      end
    end

    def tierce?
      consecutive_cards_from_same_suit?(3)
    end

    def quarte?
      consecutive_cards_from_same_suit?(4)
    end

    def quint?
      consecutive_cards_from_same_suit?(5)
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

    def consecutive_cards_from_same_suit?(number_of_cards)
      suit_and_rank = -> (card) { [card.suit, RANKS.find_index(card.rank)] }
      sorted_cards = cards.sort_by &suit_and_rank

      sorted_cards.each_cons(number_of_cards).any? do |card_group|
        same_suit = card_group.all? { |card| card.suit == card_group[0].suit }
        same_suit and consecutive_cards?(card_group)
      end
    end

    def consecutive_cards?(card_group)
      card_group.each_cons(2).all? do |first, second|
        RANKS.find_index(second.rank) == RANKS.find_index(first.rank) + 1
      end
    end

    def four_of_a_kind?(rank)
      cards.count { |card| card.rank == rank } == 4
    end
  end
end

class SixtySixDeck < Deck
  RANKS = [9, :jack, :queen, :king, 10, :ace]

  def initialize(cards = nil)
    super(RANKS, cards)
  end

  def deal
    Hand.new(self, 6)
  end

  class Hand < Deck::Hand
    def forty?(trump_suit)
      king_and_queen_from_same_suit?(trump_suit)
    end

    def twenty?(trump_suit)
      king_and_queen_from_same_suit?(Deck::SUITS - [trump_suit])
    end

    private

    def king_and_queen_from_same_suit?(allowed_suit)
      allowed_suit.any? do |suit|
        has_king = @cards.include?(Card.new(:king, suit))
        has_queen = @cards.include?(Card.new(:queen, suit))

        has_king and has_queen
      end
    end
  end
end