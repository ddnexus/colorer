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

  @color = RbConfig::CONFIG['host_os'] !~ /mswin|mingw/
  attr_accessor :color

  @strict_ansi = !!ENV['COLORER_STRICT_ANSI']
  attr_accessor :strict_ansi

  def def_basic_styles(basic=true, force=false)
    define_styles basic_styles(basic), force
  end

  def def_custom_styles(styles, force=false)
    define_styles styles, force
  end

  def define_styles(styles, force=false)
    unless caller[0].match(/def_basic_styles|def_custom_styles/)
      puts 'DEPRECATION WARNING: :define_styles has been deprecated. Use def_basic_styles and def_custom_styles instead'
      if styles.keys.include?(:basic)
        puts 'DEPRECATION WARNING: :basic is not a reserved name anymore: please use def_basic_styles to define the basic methods'
        styles = basic_styles(styles.delete(:basic)).merge(styles)
      end
      puts "    #{caller[0]}"
    end
    styles.each_pair do |meth, style|
      # allows dummy methods (useful for style overriding)
      if style.nil?
        String.class_eval { define_method(meth) { self } }
        next
      end
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
          if Colorer.strict_ansi
            match(/^\e\[[\d;]+m.*\e\[0m$/) ?
              sub(/^(\e\[[\d;]+)/, '\1;' + codes.join(';')) :
              sprintf("\e[0;%sm%s\e[0m", codes.join(';'), self)
          else
            match(/^(?:\e\[\d+m)+.*\e\[0m$/) ?
              sub(/^((?:\e\[\d+m)+)/, '\1' + codes.map{|c| "\e[#{c}m" }.join) :
              sprintf("\e[0m%s%s\e[0m", codes.map{|c| "\e[#{c}m" }.join, self)
          end
        end
      end
    end
  end

  private

  def basic_styles(basic)
    styles = {}
    case basic
    when TrueClass
      styles = BASIC_SGR
    when Array
      basic.each{|k| styles[k] = BASIC_SGR[k]}
    when Symbol
      styles[basic] = BASIC_SGR[basic]
    end
    styles
  end

end
