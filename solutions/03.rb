class Integer
  def prime?
    (1..self / 2).one? { |remainder| self % remainder == 0 }
  end
end

module DrunkenMathematician
  module_function

  def meaningless(n)
    parts = RationalSequence.new(n).partition { |x| x.numerator.prime? or x.denominator.prime? }
    parts[0].reduce(1, :*) / parts[1].reduce(1, :*)
  end

  def aimless(n)
    prime_pairs = PrimeSequence.new(n).each_slice(2).to_a
    prime_pairs[n / 2].push(1) if n % 2 == 1
    prime_pairs.collect { |pair| Rational(pair[0], pair[1]) }.reduce(0, :+)
  end

  def worthless(n)
    fibonacci_n = FibonacciSequence.new(n).to_a.last
    sum = 0

    sequence = RationalSequence.new((1.5**n).floor)
    sequence.take_while do |x|
      sum += x
      sum <= fibonacci_n
    end
  end
end

class RationalSequence
  include Enumerable

  def initialize(length)
    @length = length
  end

  def each
    current_count = 0
    element_number = 0

    while element_number < @length
      numerator, denominator = get_next_pair(current_count)

      if numerator.gcd(denominator) == 1
        yield Rational(numerator, denominator)
        element_number += 1
      end

      current_count += 1
    end
  end

  private

  def get_next_pair(pair_number)
    n = pair_number
    k = 1

    while n >= k
      n -= k
      k += 1
    end

    k.even? ? [k - n, n + 1] : [n + 1, k - n]
  end
end

class PrimeSequence
  include Enumerable

  def initialize(length)
    @length = length
  end

  def each
    yield 2 if @length > 0

    current_number = 3
    element_number = 1

    while element_number < @length
      if current_number.prime?
        yield current_number
        element_number += 1
      end
      current_number += 2
    end
  end
end

class FibonacciSequence
  include Enumerable

  def initialize(length, first: 1, second: 1)
    @length = length
    @first = first
    @second = second
  end

  def each
    element_number = 0
    current_number = @first
    previous_number = @second - @first

    while element_number < @length
      yield current_number
      element_number += 1
      current_number, previous_number = current_number + previous_number, current_number
    end
  end
end