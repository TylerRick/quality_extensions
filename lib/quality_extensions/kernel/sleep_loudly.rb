module Kernel
  
  # Sleeps for integer +n+ number of seconds, by default counting down from +n+ (inclusive) to 0, with a +step+ size of -1, printing the value of the counter at each step (3, 2, 1, 0 (output 4 times) if +n+ is 3), each time separated by a ', '.
  #
  # In effect, it is a simple on-screen countdown (or count-up) timer.
  #
  # To change the step size, supply a value for +step+ other than -1 (the default). It will sleep for +step.abs+ seconds between each iteration, and at each iteration will either yield to the supplied block or (the default) output the current value of the counter).
  #
  # The value of +step+ also determines in which *direction* to count:
  # If +step+ is negative (the default), it counts *down* from +n+ down to 0 (inclusive).
  # If +step+ is positive, it counts *up* from 0 up to +n+ (inclusive).
  #
  # +step+ does not need to be an integer value.
  #
  # If +n+ is not evenly divisible by +step+ (that is, if step * floor(  /  ? ) > n), the final step size will be shorter to ensure that the total amount slept is +n+ seconds. More precisely, the amount of time it sleeps before the final iteration (during which it won't sleepat all) will 
  #
  # If a block is provided, all of the default output is overridden, and the block will be yielded with the value of the counter i once every second instead of the default behavior, allowing you to customize what gets output, if anything, or what else happens, every +n.abs+ seconds.
  #
  # Note that it produces output (or executes your block, if supplied) n+1 times, *not* n times. This allows you to output (or not) both when the timer is first started *and* when it finishes. But because it sleeps for 1 second after the first n iterations only and *not* after the last, the total delay is still only n seconds.
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
  def sleep_loudly(n, step = -1, options = {}, &block)
    debug = options[:debug] == true ? 1 : 0
    #debug = 1

    old_sync, STDOUT.sync = STDOUT.sync, true
    if step < 0
      starti, endi = n, 0
    elsif step > 0
      starti, endi = 0, n
    else
      raise ArgumentError, "step must be positive or negative, not 0"
    end

    puts "Counting from #{starti} to #{endi} in increments of #{step} (total time should be n=#{n})" if debug

    i = starti
    final = false
    loop do
      print 'final' if final
      if block_given?
        yield *[i, final][0..block.arity-1]
      else
        print "#{i}"
      end

      break if final

      remaining = (i - endi).abs

      # if n was a multiple of step, remaining will eventually be 0, telling us that there is one final iteration to go
      # if n was not a multiple of step, use a different, smaller step as the final step; and we know that there is one final iteration to go
      if remaining < step.abs
        s = (step < 0 ? i-endi : endi-i)
        print " (using smaller final step #{s}) " if debug
        final = true # the next iteration is the final one
      else
        s = step
      end
      i += s
      print " (+#{s}=#{i}) " if debug

      print ", " unless block_given?
      print " (sleeping for #{s.abs}) " if debug
      sleep s.abs 
    end

    print "\n" unless block_given?
    STDOUT.sync = old_sync
  end
end

=begin tests
# To do: convert to use test framework
debug = 1
require 'benchmark'
def benchmark(&block)
  puts(Benchmark.measure { yield })
end
benchmark { sleep_loudly(2, 1, :debug => true) }
#benchmark { sleep_loudly(3, -1) }
#benchmark { sleep_loudly(3.2) }
#benchmark { sleep_loudly(3) {|i| print i}; puts }
#benchmark { sleep_loudly(3) {|i| print i+1 unless i==3} }
#benchmark { sleep_loudly(3) {|i| puts(i == 0 ? 'Done' : i)} }
benchmark { sleep_loudly(n=4, 1.5) {|i| print i; print ", "}; puts }
benchmark { sleep_loudly(n=5, 2) {|i, final| break if final; print i/2; print ", "}; puts }
#benchmark { sleep_loudly(n=5, 2) }
=end
