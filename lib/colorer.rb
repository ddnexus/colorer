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

  def define_styles(styles, force=false)
    styles = BASIC_SGR.merge(styles) if styles.delete(:basic)
    styles.each_pair do |meth, style|
      style = [style] unless style.is_a?(Array)
      codes = style.map do |s|
        code = s.is_a?(Symbol) ? BASIC_SGR[s] : s
        raise UnknownSgrCode.new(s) unless code.is_a?(Integer) && (0..109).include?(code)
        code
      end
      String.class_eval do
        raise AlreadyDefinedMethod.new(meth, self) if !force && method_defined?(meth)
        define_method(meth) do
          return self unless (Colorer.color && STDOUT.tty? && ENV['TERM'] && ENV['TERM'] != 'dumb')
          string = self =~ /^\e\[[\d;]+m.*\e\[0m$/ ? self : sprintf("\e[0m%s\e[0m", self)
          string.sub /^(\e\[[\d;]+)/, '\1;' + codes.join(';')
        end
      end
    end
  end

end
