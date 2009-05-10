module Kernel
  
  # Sleeps for integer +n+ number of seconds, by default counting down from n (inclusive) to 0, printing the value of the counter at each step (3, 2, 1, 0 (output 4 times) if n is 3).
  #
  # If +direction+ is +:up+ instead, it counts from 0 up to n (inclusive).
  #
  # If a block is provided, the default output is overridden, and the block will be yielded with the value of the counter i once every second instead of the default behavior, allowing you to customize what gets output (or do something else once every second).
  #
  # Note that it produces output (or executes your block, if supplied) n+1 times, *not* n times. This allows you to output (or not) both when the timer is first started *and* when it finishes. But because it sleeps for 1 second after the first n iterations only and *not* after the last, the total delay is still only n seconds.
  #
  # To change the step size, supply a value for +step+ other than 1. It will sleep for this many seconds before yielding
  #
  # Examples:
  #
  #   sleep_loudly(3) 
  #     3<sleep 1>2, <sleep 1>1, <sleep 1>0
  #
  #   sleep_loudly(3) {|i| puts(i == 0 ? 'Done' : i)}
  #   3<sleep 1>
  #   2<sleep 1>
  #   1<sleep 1>
  #   Done
  #
  #   sleep_loudly(10*60, :up, 60) {|i| print i*60, ", "} # sleep for 10 minutes, outputting after every 60 seconds
  #     0<sleep 60>2, <sleep 60>2, <sleep 60>3, 
  #
  #   sleep_loudly(3, :up) {|i| print i}
  #     0<sleep 1>1<sleep 1>2<sleep 1>3
  #
  #   sleep_loudly(3, :up) {|i| print i+1 unless i==3}
  #     1<sleep 1>2<sleep 1>3<sleep 1>
  #
  def sleep_loudly(n, direction = :down, step = 1, options = {})
    debug = true
    old_sync, STDOUT.sync = STDOUT.sync, true
    if direction == :down
      # step should be negative
      starti, endi, step = n, 0, (step > 0 ? -step : step)
    elsif direction == :up
      # step should be positive
      starti, endi, step = 0, n, (step < 0 ? -step : step)
    else
      raise ArgumentError, "direction must be :up or :down"
    end

    puts "Counting #{direction} from #{starti} to #{endi} by #{step}" if debug

    i = starti
    last = false
    loop do
      if block_given?
        yield i, last
      else
        print "#{i}"
      end

      # if n was not a multiple of step, use a different, smaller step as the final step
      if (i - endi).abs > 0 && (i - endi).abs < step
        s = (direction == :down ? i-endi : endi-i)
        print 'last'
        last = true
      else
        s = step
      end
      i += s
      print "(+#{s}=#{i})" if debug

      if (direction == :down && i < endi) ||
         (direction == :up   && i > endi)
        break
      else
        print ", " unless block_given?
        print "(sleeping for #{s.abs})" if debug
        sleep s.abs 
      end
    end

    print "\n" unless block_given?
    STDOUT.sync = old_sync
  end
end

#=begin tests
require 'benchmark'
def benchmark(&block)
  puts(Benchmark.measure { yield })
end
#benchmark { sleep_loudly(3) }
#benchmark { sleep_loudly(3, :down, -1) }
#benchmark { sleep_loudly(3.2, :up) }
#benchmark { sleep_loudly(3, :up) {|i| print i}; puts }
#benchmark { sleep_loudly(3, :up) {|i| print i+1 unless i==3} }
#benchmark { sleep_loudly(3) {|i| puts(i == 0 ? 'Done' : i)} }
benchmark { sleep_loudly(n=4, :up, 1.5) {|i, last| print i; print ", "}; puts }
benchmark { sleep_loudly(n=5, :up, 2) {|i, last| break if last; print i/2.0; print ", "}; puts }
#benchmark { sleep_loudly(n=5, :down, 2) }
#=end
