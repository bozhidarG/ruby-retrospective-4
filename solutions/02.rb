class NumberSet
  include Enumerable

  attr_accessor :container

  def initialize(initial_container = [])
    @container = initial_container
  end

  def <<(number)
    unless @container.include? number
      @container << number
    end
  end

  def size
    @container.size
  end

  def empty?
    @container.empty?
  end

  def each(&proc)
    @container.each { |e| yield(e) }
  end

  def [](filter)
    NumberSet.new(@container.select(&filter.filter_proc))
  end

end

class Filter

  attr_accessor :filter_proc

  def initialize(&proc)
    @filter_proc = proc
  end

  def &(other)
    Filter.new do |number|
      @filter_proc.call(number) && other.filter_proc.call(number)
    end
  end

  def |(other)
    Filter.new do |number|
      @filter_proc.call(number) || other.filter_proc.call(number)
    end
  end

end

class SignFilter < Filter

  def initialize(sign)
    @filter_proc = case sign
    when :positive then Proc.new { |number| number  > 0 }
    when :non_positev then Proc.new { |number| number <= 0 }
    when :negative then Proc.new { |number| number < 0 }
    when :non_negative then Proc.new { |number| number >= 0 }
    end
  end

end

class TypeFilter < Filter

  def initialize(type)
    @filter_proc = case type
    when :real
      Proc.new { |number| number.is_a? Float or number.is_a? Rational }
    when :complex
      Proc.new { |number| number.is_a? Complex }
    when :integer
      Proc.new { |number| number.is_a? Integer }
    end
  end

end
