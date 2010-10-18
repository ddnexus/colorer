module Colorer

  VERSION = File.read(File.expand_path('../../VERSION', __FILE__)).strip

  class AlreadyDefinedMethod < Exception
    def initialize(meth, klass)
      super("already defined method '#{meth}' for #{klass}:#{klass.class}")
    end
  end

  class UnknownSgrCode < Exception
    def initialize(sgr)
      super("#{sgr.inspect} is unknown")
    end
  end

  # Select Graphic Rendition
  BASIC_SGR = {
    :clear     => 0,
    :bold      => 1,
    :underline => 4,
    :blinking  => 5,
    :reversed  => 7,

    :black     => 30,
    :red       => 31,
    :green     => 32,
    :yellow    => 33,
    :blue      => 34,
    :magenta   => 35,
    :cyan      => 36,
    :white     => 37,

    :onblack   => 40,
    :onred     => 41,
    :ongreen   => 42,
    :onyellow  => 43,
    :onblue    => 44,
    :onmagenta => 45,
    :oncyan    => 46,
    :onwhite   => 47
  }

  extend self

  @color = true
  attr_accessor :color

  def add_sgr(string, sgr)
    return string unless (Colorer.color && STDOUT.tty? && ENV['TERM'] && ENV['TERM'] != 'dumb')
    code = sgr.is_a?(Symbol) ? Colorer::BASIC_SGR[sgr] : sgr
    raise UnknownSgrCode.new(sgr) unless code.is_a? Integer
    string = sprintf("\e[0m%s\e[0m", string) unless string =~ /^\e\[[\d;]+m.*\e\[0m$/
    string.sub /^(\e\[[\d;]+)/, '\1;' + code.to_s
  end

  def define_styles(styles, force=false)
    styles.each_pair do |meth, style|
      String.class_eval do
        if meth == :basic && style
          Colorer::BASIC_SGR.each_pair do |m, sgr|
            raise AlreadyDefinedMethod.new(m, self) if !force && method_defined?(m)
            define_method(m) do
              Colorer.add_sgr(self, sgr)
            end
          end
        else
          raise AlreadyDefinedMethod.new(meth, self) if !force && method_defined?(meth)
          define_method(meth) do
            style.inject(self) { |str, sgr| Colorer.add_sgr(str, sgr) }
          end
        end
      end
    end
  end

end
