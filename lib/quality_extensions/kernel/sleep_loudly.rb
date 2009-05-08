module Kernel
  
  # Sleeps for integer +n+ number of seconds, by default counting down from n (inclusive) to 0, printing the value of the counter at each step (3, 2, 1, 0 (output 4 times) if n is 3).
  #
  # If +direction+ is +:up+ instead, it counts from 0 up to n (inclusive).
  #
  # If a block is provided, the default output is overridden, and the block will be yielded with the value of the counter i once every second instead of the default behavior, allowing you to customize what gets output (or do something else once every second).
  #
  # Note that it produces output (or executes your block, if supplied) n+1 times, *not* n times. (This allows you to output (or not) both when the timer is first started *and* when it finishes.) But because it sleeps for 1 second after the first n iterations only and *not* after the last, the total delay is only n seconds.
  #
  # To change the step size, supply a value for +step+ other than 1. It will sleep for this many seconds before yielding
  #
  # Examples:
  #
  #   sleep_loudly(3, :up) 
  #     0<sleep 1>1, <sleep 1>2, <sleep 1>3
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
  def sleep_loudly(n, direction = :down, step = 1)
    old_sync, STDOUT.sync = STDOUT.sync, true
    if direction == :down
      n.step(0, step > 0 ? -step : step) do |i|
        if block_given?
          yield i
        else
          print "#{i}"
        end
        unless i==0
          print ", " unless block_given?
          sleep step.abs 
        end
      end
    elsif direction == :up
      0.step(n, step < 0 ? -step : step) do |i|
        if block_given?
          yield i
        else
          print "#{i}"
        end
        unless i==n
          print ", " unless block_given?
          sleep step.abs
        end
      end
    else
      raise ArgumentError, "direction must be :up or :down"
    end
    print "\n" unless block_given?
    STDOUT.sync = old_sync
  end
end

#sleep_loudly(3, :up)
#sleep_loudly(3, :up) {|i| print i+1 unless i==3}
#sleep_loudly(5, :up, 2) {|i| print i/2, ", "}
