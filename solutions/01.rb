def fibonacci(index)
  base = {1 => 1, 2 => 1}
  index <= 2 ? base[index] : fibonacci(index-1) + fibonacci(index-2)
end

def lucas(index)
  base = {1 => 2, 2 => 1}
  index <= 2 ? base[index] : lucas(index-1) + lucas(index-2)
end

def summed(index)
  lucas(index) + fibonacci(index)
end

def series(type, index)
  if type == 'summed'
    summed(index)
  elsif type == 'fibonacci' || type == 'lucas'
    type == 'fibonacci' ? fibonacci(index) : lucas(index)
  end
end
