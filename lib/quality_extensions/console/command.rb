# = command.rb
#
# == Copyright (c) 2005 Thomas Sawyer
#
#   Ruby License
#
#   This module is free software. You may use, modify, and/or
#   redistribute this software under the same terms as Ruby.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE.
#
# == Author(s)
#
#   CREDIT Thomas Sawyer
#   CREDIT Tyler Rick
#
# == Developer Notes
#
#   TODO Add help/documentation features.
#
#   TODO Move to console/command.rb, but I'm not sure yet if
#        adding subdirectories to more/ is a good idea.
#

# Author::    Thomas Sawyer, Tyler Rick
# Copyright:: Copyright (c) 2005-2007
# License::   Ruby License

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require 'shellwords'
require 'rubygems'
require 'facets/string/style'  #modulize
require 'escape'  # http://www.a-k-r.org/escape/

# TODO Test
class String
  def option_demethodize
    self.sub('__','--').gsub('_','-')
  end
  def option_methodize
    self.gsub('-','_')
  end
end

# = Console
#
# Console namespace for use by tools specifically designed
# for command line interfaces.

module Console ; end

# = Console Command
#
# Console::Command provides a clean and easy way
# to create a command line interface for your program.
# The unique technique utlizes a Commandline to Object
# Mapping (COM) to make it quick and easy.
#
# == Synopsis
#
# Let's make an executable called 'mycmd'.
#
#   #!/usr/bin/env ruby
#
#   require 'facets'
#   require 'command'
#
#   MyCmd << Console::Command
#
#     def _v
#       $VERBOSE = true
#     end
#
#     def jump
#       if $VERBOSE
#         puts "JUMP! JUMP! JUMP!"
#       else
#         puts "Jump"
#       end
#     end
#
#   end
#
#   MyCmd.execute
#
# Then on the command line:
#
#   % mycmd jump
#   Jump
#
#   % mycmd -v jump
#   JUMP! JUMP! JUMP!
#
# == Subcommands
#
# Commands can take subcommand and suboptions. To do this
# simply add a module to your class with the same name
# as the subcommand, in which the suboption methods are defined.
#
#   MyCmd << Console::Command
#
#     def initialize
#       @height = 1
#     end
#
#     def _v
#       $VERBOSE = true
#     end
#
#     def jump
#       if $VERBOSE
#         puts "JUMP!" * @height
#       else
#         puts "Jump" * @height
#       end
#     end
#
#     module Jump
#       def __height(h)
#         @height = h.to_i
#       end
#     end
#
#   end
#
#   MyCmd.start
#
# Then on the command line:
#
#   % mycmd jump -h 2
#   Jump Jump
#
#   % mycmd -v jump -h 3
#   JUMP! JUMP! JUMP!
#
# Another thing to notice about this example is that #start is an alias
# for #execute.
#
# == Missing Subcommands
#
# You can use #method_missing to catch missing subcommand calls.
#
# == Aliasing Subcommands
#
# You can use alias_subcommand to create an alias for a subcommand. For
# example:
#
#   alias_subcommand :st, :status
#
# When the user attempts to call the 'st' subcommand, the Status subcommand
# module will be mixed in and the status subcommand method called.
#
# == Main and Default
#
# If your command does not take subcommands then simply define
# a #main method to dispatch action. All options will be treated globablly
# in this case and any remaining comman-line arguments will be passed
# to #main.
#
# If on the other hand your command does take subcommands but none is given,
# the #default method will be called, if defined. If not defined
# an error will be raised (but only reported if $DEBUG is true).
#
# == Global Options
#
# You can define <i>global options</i> which are options that will be
# processed no matter where they occur in the command line. In the above
# examples only the options occuring before the subcommand are processed
# globally. Anything occuring after the subcommand belonds strictly to
# the subcommand. For instance, if we had added the following to the above
# example:
#
#   global_option :_v
#
# Then -v could appear anywhere in the command line, even on the end,
# and still work as expected.
#
#   % mycmd jump -h 3 -v
#
# == Missing Options
#
# You can use #option_missing to catch any options that are not explicility
# defined.
#
# The method signature should look like:
#
#   option_missing(option_name, args)
#
# Example:
#   def option_missing(option_name, args)
#     p args if $debug
#     case option_name
#       when 'p'
#         @a = args[0].to_i
#         @b = args[1].to_i
#         2
#       else
#         raise Console::Command::UnknownOptionError.new(option_name, args)
#     end
#   end
#
# Its return value should be the effective "arity" of that options -- that is,
# how many arguments it consumed ("-p a b", for example, would consume 2 args:
# "a" and "b"). An arity of 1 is assumed if nil or false is returned.
#
# Be aware that when using subcommand modules, the same option_missing
# method will catch missing options for global options and subcommand
# options too unless an option_missing method is also defined in the
# subcommand module.
#
#--
#
# == Help Documentation
#
# You can also add help information quite easily. If the following code
# is saved as 'foo' for instance.
#
#   MyCmd << Console::Command
#
#     help "Dispays the word JUMP!"
#
#     def jump
#       if $VERBOSE
#         puts "JUMP! JUMP! JUMP!"
#       else
#         puts "Jump"
#       end
#     end
#
#   end
#
#   MyCmd.execute
#
# then by running 'foo help' on the command line, standard help information
# will be displayed.
#
#   foo
#
#     jump  Displays the word JUMP!
#
#++

class Console::Command
  
  class << self
    # Starts the command execution.
    def execute( *args )
      cmd = new()
      cmd.instance_variable_set("@global_options", global_options)
      cmd.instance_variable_set("@subcommand_aliases", @subcommand_aliases || {})
      cmd.execute( *args )
    end

    # Alias for #execute.
    alias_method :start, :execute

    # Change the option mode.
    def global_option( *names )
      names.each{ |name| global_options << name.to_sym }
    end

    def global_options
      @global_options ||= []
    end

    # This is to be called from your subcommand module to specify which options should simply be "passed on" to some wrapped command that you will later call.
    # Options that are collected by the option methods that this generates will be stored in @passthrough_options (so remember to append that array to your wrapped command!).
    #
    #  module Status
    #    Console::Command.pass_through({
    #      [:_q, :__quiet] => 0,
    #      [:_N, :__non_recursive] => 0,
    #      [:__no_ignore] => 0,
    #    }, self)
    #  end
    #
    # Development notes:
    # * Currently requires you to pass the subcommand module's "self" to this method. I didn't know of a better way to cause it to create the instance methods in *that* module rather than here in Console::Command.
    # * Possible alternatives:
    #   * Binding.of_caller() (http://facets.rubyforge.org/src/doc/rdoc/classes/Binding.html) -- wary of using it if it depends on Continuations, which I understand are deprecated
    #   * copy the pass_through class method to each subcommand module so that calls will be in the module's context...
    def pass_through(options, mod)
      options.each do |method_names, arity|
        method_names.each do |method_name|
          if method_name == :_u
            #puts "Defining method #{method_name}(with arity #{arity}) in #{mod.name}"
            #puts "#{mod.name} has #{(mod.methods - Object.methods).inspect}"
          end
          option_name = method_name.to_s.option_demethodize
          mod.send(:define_method, method_name.to_sym) do |*args|
            @passthrough_options << option_name
            args_for_current_option = Escape.shell_command(args.slice(0, arity))
            @passthrough_options << args_for_current_option unless args_for_current_option == ''
            #p args_for_current_option
            #puts "in #{method_name}: Passing through #{arity} options: #{@passthrough_options.inspect}"  #(why does @passthrough_options show up as nil? even when later on it's *not* nil...)
            arity
          end

  #        mod.instance_eval %Q{
  #          def #{method_name}(*args)
  #            @passthrough_options << '#{option_name}'
  #            args_for_current_option = Escape.shell_command(args.slice(0, #{arity}))
  #            @passthrough_options << args_for_current_option unless args_for_current_option == ''
  #            #p args_for_current_option
  #            #puts "in #{method_name}: Passing through #{arity} options: #{@passthrough_options.inspect}"  #(why does @passthrough_options show up as nil? even when later on it's *not* nil...)
  #            #{arity}
  #          end
  #        }
          
        end
      end
    end

    def alias_subcommand(hash)
      (@subcommand_aliases ||= {}).merge! hash
    end

  end # End of class methods


  #-----------------------------------------------------------------------------------------------------------------------------

  # Do not let this pass through to
  # any included module.
  #   What do you mean? --Tyler

  def initialize(global_options=[])
    @global_options = global_options
  end

  # Execute the command.

  def execute( line=nil )
  begin
    case line
    when String
      arguments = Shellwords.shellwords(line)
    when Array
      arguments = line
    else
      arguments = ARGV
    end

    # Duplicate arguments to work on them in-place.
    argv = arguments.dup

    # Split single letter option groupings into separate options.
    # ie. -xyz => -x -y -z
    argv = argv.collect { |arg|
      if md = /^-(\w{2,})/.match( arg )
        md[1].split(//).collect { |c| "-#{c}" }
      else
        arg
      end
    }.flatten

    # Process global options
    global_options.each do |name|
      o = name.to_s.option_demethodize
      m = method(name)
      c = m.arity
      while i = argv.index(o)
        args = argv.slice!(i,c+1)
        args.shift
        m.call(*args)
      end
    end

    # Does this command take subcommands?
    takes_subcommands = !respond_to?(:main)

    # Process primary options
    argv = execute_options( argv, takes_subcommands )

    # If this command doesn't take subcommands, then the remaining arguments are arguments for main().
    return send(:main, *argv) unless takes_subcommands

    # What to do if there is nothing else?
    if argv.empty?
      if respond_to?(:default)
        return __send__(:default)
      else
        $stderr << "Nothing to do."
        puts '' # :fix: This seems to be necessary or else I don't see the $stderr output at all! --Tyler
        return
      end
    end

    # Remaining arguments are subcommand and suboptions.

    @subcommand = argv.shift.gsub('-','_')
    @subcommand = (subcommand_aliases[@subcommand.to_sym] || @subcommand).to_s
    puts "@subcommand = #{@subcommand}" if $debug

    # Extend subcommand option module
    #subconst = subcommand.gsub(/\W/,'_').capitalize
    subconst = @subcommand.style(:modulize)
    #p self.class.constants if $debug
    if self.class.const_defined?(subconst)
      puts "Extending self (#{self.class}) with subcommand module #{subconst}" if $debug
      submod = self.class.const_get(subconst)
      #puts "... which has these **module** methods (should be instance methods): #{(submod.methods - submod.instance_methods - Object.methods).sort.inspect}"
      self.extend submod
      #puts "... and now self has: #{(self.methods - Object.methods).sort.inspect}"
    end

    # Is the subcommand defined?
    # This is a little tricky. The method has to be defined by a *subclass*.
    @subcommand_is_defined = self.respond_to?( @subcommand ) and
                             !Console::Command.public_instance_methods.include?( @subcommand.to_s )

    # The rest of the args will be interpreted as options for this particular subcommand options.
    argv = execute_options( argv, false )

    # Actually call the subcommand (or method_missing if the subcommand method isn't defined)
    if @subcommand_is_defined
      puts "Calling #{@subcommand}(#{argv.inspect})" if $debug
      __send__(@subcommand, *argv)
    else
      #begin
        puts "Calling method_missing with #{@subcommand}, #{argv.inspect}" if $debug
        method_missing(@subcommand, *argv)
      #rescue NoMethodError => e
        #if self.private_methods.include?( "no_command_error" )
        #  no_command_error( *args )
        #else
      #    $stderr << "Non-applicable command -- #{argv.join(' ')}\n"
      #    exit -1
        #end
      #end
    end

  rescue UnknownOptionError => exception
    $stderr << exception.message << "\n"
    exit -1
  end

#   rescue => err
#     if $DEBUG
#       raise err
#     else
#       msg = err.message.chomp('.') + '.'
#       msg[0,1] = msg[0,1].capitalize
#       msg << " (#{err.class})" if $VERBOSE
#       $stderr << msg
#     end
  end  # def execute

  private

  #

  attr_accessor :global_options
  attr_accessor :subcommand_aliases

  def subcommand_aliases_list(main_subcommand_name)
    # If subcommand_aliases returns {:edit_ext=>:edit_externals, :ee=>:edit_externals}, then 
    # subcommand_aliases_list(:edit_externals) ought to return [:edit_ext, :ee]
    subcommand_aliases.select {|k, v| v == main_subcommand_name}.
                          map {|k, v| k if v == main_subcommand_name}
  end

  #

  def execute_options( argv, break_when_hit_subcommand = false )
    argv = argv.dup
    args_to_return = []
    until argv.empty?
      arg = argv.first
      if arg[0,1] == '-'
        puts "'#{arg}' -- is an option" if $debug
        method_name = arg.option_methodize
        #puts "Methods: #{(methods - Object.methods).inspect}" if $debug
        if respond_to?(method_name)
          m = method(method_name)
          puts "Method named #{method_name} exists and has an arity of #{m.arity}" if $debug
          if m.arity == -1
            # Implemented the same as for option_missing, except that we don't pass the *name* of the option
            arity = m.call(*argv[1..-1]) || 1
            puts "#{method_name} returned an arity of #{arity}" if $debug
            if !arity.is_a?(Fixnum)
              raise "Expected #{method_name} to return a valid arity, but it didn't"
            end
            #puts "argv before: #{argv.inspect}"
            argv.shift              # Get rid of the *name* of the option
            argv.slice!(0, arity)   # Then discard as many arguments as that option claimed it used up
            #puts "argv after: #{argv.inspect}"
          else
            args_for_current_option = argv.slice!(0, m.arity+1)   # The +1 is so that we also remove the option name from argv
            args_for_current_option.shift                         # Remove the option name from args_for_current_option as well
            m.call(*args_for_current_option)
          end
        elsif respond_to?(:option_missing)
          puts "No method named #{method_name} exists -- calling option_missing(#{arg}, #{argv[1..-1].inspect})" if $debug
          # Old: arity = option_missing(arg.gsub(/^[-]+/,''), argv[1..-1]) || 1
          arity = option_missing(arg, argv[1..-1]) || 1
          argv.shift              # Get rid of the *name* of the option
          argv.slice!(0, arity)   # Then discard as many arguments as that option claimed it used up
        else
          raise UnknownOptionError.new(arg)
        end
      else
        puts "'#{arg}' -- not an option. Adding to args_to_return..." if $debug
        if break_when_hit_subcommand
          # If we are parsing options for the *main* command and we are allowing subcommands, then we want to stop as soon as we
          # get to the first non-option, because that non-option will be the name of our subcommand and all options that follow
          # should be parsed later when we handle the subcommand (after we've extended the subcommand module, for instance).
          args_to_return = argv
          break
        else
          args_to_return << argv.shift
        end
      end
    end
    puts "Returning #{args_to_return.inspect}" if $debug
    return args_to_return
  end

  public

=begin
  # We include a module here so you can define your own help
  # command and call #super to utilize this one.

  module Help

    def help
      opts = help_options
      s = ""
      s << "#{File.basename($0)}\n\n"
      unless opts.empty?
        s << "OPTIONS\n"
        s << help_options
        s << "\n"
      end
      s << "COMMANDS\n"
      s << help_commands
      puts s
    end

    private

    def help_commands
      help = self.class.help
      bufs = help.keys.collect{ |a| a.to_s.size }.max + 3
      lines = []
      help.each { |cmd, str|
        cmd = cmd.to_s
        if cmd !~ /^_/
          lines << "  " + cmd + (" " * (bufs - cmd.size)) + str
        end
      }
      lines.join("\n")
    end

    def help_options
      help = self.class.help
      bufs = help.keys.collect{ |a| a.to_s.size }.max + 3
      lines = []
      help.each { |cmd, str|
        cmd = cmd.to_s
        if cmd =~ /^_/
          lines << "  " + cmd.gsub(/_/,'-') + (" " * (bufs - cmd.size)) + str
        end
      }
      lines.join("\n")
    end

    module ClassMethods

      def help( str=nil )
        return (@help ||= {}) unless str
        @current_help = str
      end

      def method_added( meth )
        if @current_help
          @help ||= {}
          @help[meth] = @current_help
          @current_help = nil
        end
      end

    end

  end

  include Help
  extend Help::ClassMethods
=end

  class UnknownOptionError < StandardError
    def initialize(option_name)
      @option_name = option_name
    end
    def message
      "Unknown option '#{@option_name}'."
    end
  end
end



#  _____         _
# |_   _|__  ___| |_
#   | |/ _ \/ __| __|
#   | |  __/\__ \ |_
#   |_|\___||___/\__|
#

=begin test

  require 'test/unit'
  require 'stringio'
  require 'quality_extensions/kernel/capture_output'

  class TestCommand < Test::Unit::TestCase
    def setup
      $output = nil
    end

    #-----------------------------------------------------------------------------------------------------------------------------

    class SimpleCommand < Console::Command
      def __here ; @here = true ; end

      def main(*args)
        $output = [@here] | args
      end
    end

    def test_SimpleCommand
      SimpleCommand.execute( '--here file1 file2' )
      assert_equal( [true, 'file1', 'file2'], $output )
    end

    #-----------------------------------------------------------------------------------------------------------------------------

    class MethodMissingSubcommand < Console::Command
      def __here ; @here = true ; end

      def method_missing(subcommand, *args)
        $output = [@here, subcommand] | args
      end
    end

    def test_MethodMissingSubcommand
      MethodMissingSubcommand.execute( '--here go file1' )
      assert_equal( [true, 'go', 'file1'], $output )
    end

    #-----------------------------------------------------------------------------------------------------------------------------

    class SimpleSubcommand < Console::Command
      def __here ; @here = true ; end

      # subcommand

      module Go
        def _p(n)
          @p = n.to_i
        end
      end

      def go ; $output = [@here, @p] ; end
    end

    def test_SimpleSubcommand
      SimpleSubcommand.execute( '--here go -p 1' )
      assert_equal( [true, 1], $output )
    end

    #-----------------------------------------------------------------------------------------------------------------------------

    # Global options can be anywhere, right? Even after subcommands? Let's find out.
    class GlobalOptionsAfterSubcommand < Console::Command
      def _x ; @x = true ; end
      global_option :_x

      def go ; $output = [@x, @p] ; end

      module Go
        def _p(n)
          @p = n.to_i
        end
      end
    end

    def test_GlobalOptionsAfterSubcommand
      GlobalOptionsAfterSubcommand.execute( 'go -x -p 1' )
      assert_equal( [true, 1], $output )

      GlobalOptionsAfterSubcommand.execute( 'go -p 1 -x' )
      assert_equal( [true, 1], $output )
    end

    #-----------------------------------------------------------------------------------------------------------------------------

    class GivingUnrecognizedOptions < Console::Command
      def _x ; @x = true ; end
      def go ; $output = [@x, @p] ; end
    end

    def test_GivingUnrecognizedOptions
      stderr = capture_output $stderr do
      assert_raise(SystemExit) do
          GivingUnrecognizedOptions.execute( '--an-option-that-wont-be-recognized -x go' )
      end
      end
      assert_equal "Unknown option '--an-option-that-wont-be-recognized'.\n", stderr
      assert_equal( nil, $output )
    end

    #-----------------------------------------------------------------------------------------------------------------------------

    class PassingMultipleSingleCharOptionsAsOneOption < Console::Command
      def _x ; @x = true ; end
      def _y ; @y = true ; end
      def _z(n) ; @z = n ; end

      global_option :_x

      def go ; $output = [@x, @y, @z, @p] ; end

      module Go
        def _p(n)
          @p = n.to_i
        end
      end
    end

    def test_PassingMultipleSingleCharOptionsAsOneOption
      PassingMultipleSingleCharOptionsAsOneOption.execute( '-xy -z HERE go -p 1' )
      assert_equal( [true, true, 'HERE', 1], $output )
    end

    #-----------------------------------------------------------------------------------------------------------------------------

    class OptionUsingEquals < Console::Command
      module Go
        def __mode(mode) ; @mode = mode ; end
      end
      def go ; $output = [@mode] ; end
    end

    def test_OptionUsingEquals
      OptionUsingEquals.execute( 'go --mode smart' )
      assert_equal( ['smart'], $output )

      # I would expect this to work too, but currently it doesn't.
      #assert_nothing_raised { OptionUsingEquals.execute( 'go --mode=smart' ) }
      #assert_equal( ['smart'], $output )
    end

    #-----------------------------------------------------------------------------------------------------------------------------

    class SubcommandThatTakesArgs < Console::Command
      def go(arg1, *args) ; $output = [arg1] | args ; end
    end

    def test_SubcommandThatTakesArgs
      SubcommandThatTakesArgs.execute( 'go file1 file2 file3' )
      assert_equal( ['file1', 'file2', 'file3'], $output )
    end

    #-----------------------------------------------------------------------------------------------------------------------------

    class With2OptionalArgs < Console::Command
      module Go
        def _p(n)
          @p = n.to_i
        end
      end

      def go(optional1 = nil, optional2 = nil) ; $output = [@p, optional1, optional2 ] ; end
    end

    def test_With2OptionalArgs
      With2OptionalArgs.execute( 'go -p 1 to' )
      assert_equal( [1, 'to', nil], $output )
    end

    #-----------------------------------------------------------------------------------------------------------------------------

    class VariableArgs < Console::Command
      module Go
        def _p(n)
          @p = n.to_i
        end
      end

      def go(*args) ; $output = [@p] | args ; end
    end

    def test_VariableArgs
      VariableArgs.execute( 'go -p 1 to bed' )
      assert_equal( [1, 'to', 'bed'], $output )
    end

    #-----------------------------------------------------------------------------------------------------------------------------

    class OptionMissing < Console::Command
      module Go
        def option_missing(option_name, args)
          p args if $debug
          case option_name
            when '-p'
              @p = args[0].to_i
              1
            else
              raise Console::Command::UnknownOptionError.new(option_name)
          end
        end
      end

      def go(*args) ; $output = [@p] | args ; end
    end

    def test_OptionMissing
      OptionMissing.execute( 'go -p 1 to bed right now' )
      assert_equal( [1, 'to', 'bed', 'right', 'now'], $output )
    end

    #-----------------------------------------------------------------------------------------------------------------------------

    class OptionWith0Arity < Console::Command
      module Go
        def _p()
          @p = 13
        end
      end

      def go(arg1) ; $output = [@p, arg1] ; end
    end

    def test_OptionWith0Arity
      OptionWith0Arity.execute( 'go -p away' )
      assert_equal( [13, 'away'], $output )
    end

    #-----------------------------------------------------------------------------------------------------------------------------

    class OptionWithVariableArity < Console::Command
      module Go
        def _p(*args)
          #puts "_p received #{args.size} args: #{args.inspect}"
          @p = args.reject {|arg| arg.to_i.to_s != arg }    # TODO: this should be extracted to reusable String#is_numeric? if one doesn't exist
          #puts "_p accepting #{@p.size} args: #{@p.inspect}"
          @p.size
        end
      end

      def go(arg1) ; $output = @p | [arg1] ; end
    end

    def test_OptionWithVariableArity
      OptionWithVariableArity.execute( 'go -p 1 2 3 4 away' )
      assert_equal( ['1', '2', '3', '4', 'away'], $output )
    end

    #-----------------------------------------------------------------------------------------------------------------------------

    class OptionMissingArityOf2 < Console::Command
      module Go
        def option_missing(option_name, args)
          case option_name
            when '-p'
              @p1 = args[0].to_i
              @p2 = args[1].to_i
              2
            when '-q'
              @q = args[0].to_i
              nil # Test default arity
            else
              raise Console::Command::UnknownOptionError.new.new(option_name, args)
          end
        end
      end

      def go(*args) ; $output = [@p1, @p2, @q] | args ; end
    end

    def test_OptionMissingArityOf2
      OptionMissingArityOf2.execute( 'go -p 1 2 -q 3 to bed right now' )
      assert_equal( [1, 2, 3, 'to', 'bed', 'right', 'now'], $output )
    end

    #-----------------------------------------------------------------------------------------------------------------------------

    class OptionMissingReceivesShortAndLongOptionsDifferently < Console::Command
      module Go
        def option_missing(option_name, args)
          case option_name
            when '-s'
              @s = "-s #{args[0]}"
              1
            when '--long'
              @long = "--long #{args[0]}"
              1
            else
              raise Console::Command::UnknownOptionError.new(option_name, args)
          end
        end
      end

      def go(*args) ; $output = [@s, @long] ; end
    end

    def test_OptionMissingReceivesShortAndLongOptionsDifferently
      OptionMissingReceivesShortAndLongOptionsDifferently.execute( 'go -s 1 --long long' )
      assert_equal( ['-s 1', '--long long'], $output )
    end

    #-----------------------------------------------------------------------------------------------------------------------------

    class AliasSubcommand < Console::Command
      alias_subcommand :g => :go
      module Go
        def option_missing(option_name, args)
          case option_name
            when '-s'
              @s = "-s #{args[0]}"
              1
            when '--long'
              @long = "--long #{args[0]}"
              1
            else
              raise Console::Command::UnknownOptionError.new(option_name, args)
          end
        end
      end

      def go(*args) ; $output = [@s, @long] ; end
    end

    def test_AliasSubcommand
      AliasSubcommand.execute( 'g -s 1 --long long' )
      assert_equal( ['-s 1', '--long long'], $output )
    end
  end

=end
