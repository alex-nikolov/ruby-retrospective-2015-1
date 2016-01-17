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
      @cards = @ranks.product(@suits).map { |rank, suit| Card.new(rank, suit) }
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
    @cards.sort_by! { |c| [c.suit.to_s, - @card_ranks[c.rank]] }.reverse!
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
    WarHand.new(self, 26)
  end

  class WarHand < Deck::Hand
    def play_card
      @cards.delete_at(0)
    end

    def allow_face_up?
      size <= 3
    end
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

  class BeloteHand < Deck::Hand

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

class SixtySixHand < Deck::Hand
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