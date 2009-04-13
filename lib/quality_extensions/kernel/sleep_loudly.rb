module Kernel
  
  # Sleeps for integer +n+ number of seconds, by default counting down from n (inclusive) to 0, printing the value of the counter at each step (3, 2, 1, 0 (output 4 times) if n is 3).
  #
  # If +direction+ is +:up+ instead, it counts from 0 up to n (inclusive).
  #
  # If a block is provided, the default output is overridden, and the block will be yielded with the value of the counter i once every second instead of the default behavior, allowing you to customize what gets output (or do something else once every second).
  #
  # Note that it produces output (or executes your block, if supplied) n+1 times, *not* n times. (This allows you to output (or not) both when the timer is first started *and* when it finishes.) But because it sleeps for 1 second after the first n iterations only and *not* after the last, the total delay is only n seconds.
  #
  # Examples:
  #
  #   sleep_loudly(3, :up) 
  #     0<sleep 1>1, <sleep 1>2, <sleep 1>3
  #   sleep_loudly(3, :up) {|i| print i}
  #     0<sleep 1>1<sleep 1>2<sleep 1>3
  #   sleep_loudly(3, :up) {|i| print i+1 unless i==3}
  #     1<sleep 1>2<sleep 1>3<sleep 1>
  #
  #
  def sleep_loudly(n, direction = :down)
    old_sync, STDOUT.sync = STDOUT.sync, true
    if direction == :down
      n.downto(0) do |i|
        if block_given?
          yield i
        else
          print "#{i}"
        end
        unless i==0
          print ", " unless block_given?
          sleep 1 
        end
      end
    elsif direction == :up
      0.upto(n) do |i|
        if block_given?
          yield i
        else
          print "#{i}"
        end
        unless i==n
          print ", " unless block_given?
          sleep 1 
        end
      end
    else
      raise ArgumentError, "direction must be :up or :down"
    end
    print "\n" unless block_given?
    STDOUT.sync = old_sync
  end
end

#sleep_loudly(3, :up) {|i| print i+1 unless i==3}
