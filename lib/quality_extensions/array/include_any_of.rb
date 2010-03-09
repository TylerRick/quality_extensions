Welcome!
irb -> [1,2,5].include_any_of? [3,5]
NoMethodError: undefined method `include_any_of?' for [1, 2, 5]:Array
  from (irb):1
  from /usr/local/bin/irb:12:in `<main>'
irb -> [1,2,5] & [3,5]
    => [5]

irb -> !!([1,2,5] & [3,5])
    => true

irb -> [1,2,5] & [3,4]
    => []

irb -> !!([1,2,5] & [3,4])
    => true

irb -> ([1,2,5] & [3,4]).any?
    => false

irb -> ([1,2,5] & [3,5]).any?
    => true

