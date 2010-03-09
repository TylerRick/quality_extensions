# Source: http://svn.idaemons.org/repos/inplace/trunk/inplace.rb

$uninterruptible = false

[:SIGINT, :SIGQUIT, :SIGTERM].each { |sig|
  trap(sig) {
    unless $uninterruptible
      STDERR.puts "Interrupted."
      exit 130
    end
  }
}

def uninterruptible
  orig = $uninterruptible
  $uninterruptible = true

  yield
ensure
  $uninterruptible = orig
end

