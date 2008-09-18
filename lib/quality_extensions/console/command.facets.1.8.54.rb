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

require 'shellwords'

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
#         raise InvalidOptionError(option_name, args)
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
     cmd.instance_variable_set("@global_options",global_options)
     cmd.execute( *args )
   end
   alias_method :start, :execute

   # Change the option mode.

   def global_option( *names )
     names.each{ |name| global_options << name.to_sym }
   end

   def global_options
     @global_options ||= []
   end
 end

 # Do not let this pass through to
 # any included module.

 def initialize(global_options=[])
   @global_options = global_options
 end

 # Execute the command.

 def execute( line=nil )
   case line
   when String
     arguments = Shellwords.shellwords(line)
   when Array
     arguments = line
   else
     arguments = ARGV
   end

   # duplicate arguments to work on them in-place.

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

   # process global options
   global_options.each do |name|
     o = name.to_s.sub('__','--').sub('_','-')
     m = method(name)
     c = m.arity
     while i = argv.index(o)
       args = argv.slice!(i,c+1)
       args.shift
       m.call(*args)
     end
   end

   # Does this command take subcommands?
   subcommand = !respond_to?(:main)

   # process primary options
   argv = execute_options( argv, subcommand )

   # If this command doesn't take subcommands, then the remaining arguments are arguments for main().
   return send(:main, *argv) unless subcommand

   # What to do if there is nothing else?
   if argv.empty?
     if respond_to?(:default)
       return __send__(:default)
     else
       $stderr << "Nothing to do."
       return
     end
   end

   # Remaining arguments are subcommand and suboptions.

   subcmd = argv.shift.gsub('-','_')
   #puts "subcmd = #{subcmd}"

   # Extend subcommand option module
   subconst = subcmd.gsub(/\W/,'_').capitalize
   #puts self.class.name
   if self.class.const_defined?(subconst)
     puts "Extending self (#{self.class}) with subcommand module #{subconst}" if $debug
     submod = self.class.const_get(subconst)
     self.extend submod
   end

   # process subcommand options
   #puts "Treating the rest of the args as subcommand options:"
   #p argv
   argv = execute_options( argv )

   # This is a little tricky. The method has to be defined by a subclass.
   if self.respond_to?( subcmd ) and not Console::Command.public_instance_methods.include?( subcmd.to_s )
     puts "Calling #{subcmd}(#{argv.inspect})" if $debug
     __send__(subcmd, *argv)
   else
     #begin
       puts "Calling method_missing with #{subcmd}, #{argv.inspect}" if $debug
       method_missing(subcmd, *argv)
     #rescue NoMethodError => e
       #if self.private_methods.include?( "no_command_error" )
       #  no_command_error( *args )
       #else
     #    $stderr << "Non-applicable command -- #{argv.join(' ')}\n"
     #    exit -1
       #end
     #end
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
 end

 private

 #

 def global_options
   @global_options
 end

 #

 def execute_options( argv, subcmd=false )
   puts "in execute_options:" if $debug
   argv = argv.dup
   args_to_return = []
   until argv.empty?
     arg = argv.first
     if arg[0,1] == '-'
       puts "'#{arg}' -- is an option" if $debug

       name = arg.gsub('-','_')
       puts "  responds_to(#{name})?" if $debug
       if respond_to?(name)
         m = method(name)
         arity = m.arity
         #puts "{argv before slice: #{argv.inspect}" if $debug
         args_for_current_option = argv.slice!(0, arity+1)
         #puts "}argv after slice: #{argv.inspect}" if $debug
         #puts "{args_for_current_option before shift: #{args_for_current_option.inspect}" if $debug
         args_for_current_option.shift
         #puts "}args_for_current_option after shift: #{args_for_current_option.inspect}" if $debug
         #puts "  arity=#{m.arity}" if $debug
         #puts "  calling #{name} with #{args_for_current_option.inspect}" if $debug
         m.call(*args_for_current_option)
       elsif respond_to?(:option_missing)
         puts "  option_missing(#{argv.inspect})" if $debug
         arity = option_missing(arg.gsub(/^[-]+/,''), argv[1..-1]) || 1
         puts "  arity == #{arity}" if $debug
         argv.slice!(0, arity)
         argv.shift  # Get rid of the *name* of the option
       else
         $stderr << "Unknown option '#{arg}'.\n"
         exit -1
       end
     else
       puts "'#{arg}' -- not an option. Adding to args_to_return..." if $debug
       if subcmd
         args_to_return = argv
         #puts "subcommand. args_to_return=#{args_to_return.inspect}" if $debug
         break
       else
         args_to_return << argv.shift
         puts "args_to_return=#{args_to_return.inspect}" if $debug
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

 class TestCommand < Test::Unit::TestCase
   def setup
     $output = nil
     $stderr = StringIO.new
   end

   #

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

   #

   class CommandWithMethodMissingSubcommand < Console::Command
     def __here ; @here = true ; end

     def method_missing(subcommand, *args)
       $output = [@here, subcommand] | args
     end
   end

   def test_CommandWithMethodMissingSubcommand
     CommandWithMethodMissingSubcommand.execute( '--here go file1' )
     assert_equal( [true, 'go', 'file1'], $output )
   end

   #

   class CommandWithSimpleSubcommand < Console::Command
     def __here ; @here = true ; end

     # subcommand

     module Go
       def _p(n)
         @p = n.to_i
       end
     end

     def go ; $output = [@here, @p] ; end
   end

   def test_CommandWithSimpleSubcommand
     CommandWithSimpleSubcommand.execute( '--here go -p 1' )
     assert_equal( [true, 1], $output )
   end

   #

   # Global options can be anywhere, right? Even after subcommands? Let's find out.
   class CommandWithGlobalOptionsAfterSubcommand < Console::Command
     def _x ; @x = true ; end
     global_option :_x

     def go ; $output = [@x, @p] ; end

     module Go
       def _p(n)
         @p = n.to_i
       end
     end
   end

   def test_CommandWithGlobalOptionsAfterSubcommand
     CommandWithGlobalOptionsAfterSubcommand.execute( 'go -x -p 1' )
     assert_equal( [true, 1], $output )

     CommandWithGlobalOptionsAfterSubcommand.execute( 'go -p 1 -x' )
     assert_equal( [true, 1], $output )
   end

   #

   class GivingUnrecognizedOptions < Console::Command
     def _x ; @x = true ; end
     def go ; $output = [@x, @p] ; end
   end

   def test_GivingUnrecognizedOptions
     assert_raise(SystemExit) do
       GivingUnrecognizedOptions.execute( '--an-option-that-wont-be-recognized -x go' )
     end
     assert_equal "Unknown option '--an-option-that-wont-be-recognized'.\n", $stderr.string
     assert_equal( nil, $output )
   end
   #

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

   #

   class CommandWithOptionUsingEquals < Console::Command
     module Go
       def __mode(mode) ; @mode = mode ; end
     end
     def go ; $output = [@mode] ; end
   end

   def test_CommandWithOptionUsingEquals
     CommandWithOptionUsingEquals.execute( 'go --mode smart' )
     assert_equal( ['smart'], $output )

     # I would expect this to work too, but currently it doesn't.
     #assert_nothing_raised { CommandWithOptionUsingEquals.execute( 'go --mode=smart' ) }
     #assert_equal( ['smart'], $output )
   end

   #

   class CommandWithSubcommandThatTakesArgs < Console::Command
     def go(arg1, *args) ; $output = [arg1] | args ; end
   end

   def test_CommandWithSubcommandThatTakesArgs
     CommandWithSubcommandThatTakesArgs.execute( 'go file1 file2 file3' )
     assert_equal( ['file1', 'file2', 'file3'], $output )
   end

   #

   class CommandWith2OptionalArgs < Console::Command
     def __here ; @here = true ; end

     module Go
       def _p(n)
         @p = n.to_i
       end
     end

     def go(required1 = nil, optional2 = nil) ; $output = [@here, @p, required1, optional2 ] ; end
   end

   def test_CommandWith2OptionalArgs
     CommandWith2OptionalArgs.execute( '--here go -p 1 to' )
     assert_equal( [true, 1, 'to', nil], $output )
   end

   #

   class CommandWithVariableArgs < Console::Command
     def __here ; @here = true ; end

     module Go
       def _p(n)
         @p = n.to_i
       end
     end

     def go(*args) ; $output = [@here, @p] | args ; end
   end

   def test_CommandWithVariableArgs
     CommandWithVariableArgs.execute( '--here go -p 1 to bed' )
     assert_equal( [true, 1, 'to', 'bed'], $output )
   end

   #

   class CommandWithOptionMissing < Console::Command
     def __here ; @here = true ; end

     module Go
       def option_missing(option_name, args)
         p args if $debug
         case option_name
           when 'p'
             @p = args[0].to_i
             1
           else
             raise InvalidOptionError(option_name, args)
         end
       end
     end

     def go(*args) ; $output = [@here, @p] | args ; end
   end

   def test_CommandWithOptionMissing
     CommandWithOptionMissing.execute( '--here go -p 1 to bed right now' )
     assert_equal( [true, 1, 'to', 'bed', 'right', 'now'], $output )
   end

   #

   class CommandWithOptionMissingArityOf2 < Console::Command
     def __here ; @here = true ; end

     module Go
       def option_missing(option_name, args)
         p args if $debug
         case option_name
           when 'p'
             @p1 = args[0].to_i
             @p2 = args[1].to_i
             2
           when 'q'
             @q = args[0].to_i
             nil # Test default arity
           else
             raise InvalidOptionError(option_name, args)
         end
       end
     end

     def go(*args) ; $output = [@here, @p1, @p2, @q] | args ; end
   end

   def test_CommandWithOptionMissingArityOf2
     CommandWithOptionMissingArityOf2.execute( '--here go -p 1 2 -q 3 to bed right now' )
     assert_equal( [true, 1, 2, 3, 'to', 'bed', 'right', 'now'], $output )
   end
 end

=end
