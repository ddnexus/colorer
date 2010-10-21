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
    if basic = styles.delete(:basic)
      basic_styles = {}
      case basic
      when TrueClass
        basic_styles = BASIC_SGR
      when Array
        basic.each{|k| basic_styles[k] = BASIC_SGR[k]}
      when Symbol
        basic_styles[basic] = BASIC_SGR[basic]
      end
      styles = basic_styles.merge(styles)
    end
    styles.each_pair do |meth, style|
      style = [style] unless style.is_a?(Array)
      codes = style.map do |s|
                code = s.is_a?(Symbol) ? BASIC_SGR[s] : s
                raise UnknownSgrCode.new(s) unless code.is_a?(Integer) && (0..109).include?(code)
                code
              end.join(';')
      String.class_eval do
        raise AlreadyDefinedMethod.new(meth, self) if !force && method_defined?(meth)
        define_method(meth) do
          return self unless (Colorer.color && STDOUT.tty? && ENV['TERM'] && ENV['TERM'] != 'dumb')
          match(/^\e\[[\d;]+m.*\e\[0m$/) ?
            sub(/^(\e\[[\d;]+)/, '\1;' + codes) :
            sprintf("\e[0;%sm%s\e[0m", codes, self)
        end
      end
    end
  end

end
