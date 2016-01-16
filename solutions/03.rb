class Numeric
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
    if n % 2 == 1
      prime_pairs[n / 2].push(1)
    end
    prime_pairs.collect { |pair| Rational(pair[0], pair[1]) }.reduce(0, :+)
  end

  def worthless(n)
    fibonacci_n, sum = FibonacciSequence.new(n).to_a.last, 0
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

  def last
    to_a.last
  end

  def each
    current_count = 0
    current_size = 0

    while current_size < @length
      numerator, denominator = get_next_pair(current_count)

      if numerator.gcd(denominator) == 1
        yield Rational(numerator, denominator)
        current_size += 1
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

    if k.even? then [k - n, n + 1] else [n + 1, k - n] end
  end
end

class PrimeSequence
  include Enumerable

  def initialize(length)
    @length = length
  end

  def each
    if @length > 0
      yield 2
    end
    current, element_number = 3, 1
    while element_number < @length
      if current.prime?
        yield current
        element_number += 1
      end
      current += 2
    end
  end
end

class FibonacciSequence
  include Enumerable

  def initialize(length, first: 1, second: 1)
    @length, @first, @second = length, first, second
  end

  def each
    element_number, current, previous = 0, @first, @second - @first
    while element_number < @length
      yield current
      element_number, current, previous = element_number + 1, current + previous, current
    end
  end
end