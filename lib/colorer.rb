module Colorer

  class Exception < ::Exception; end

  CODES = {
    :clear     => 0,
    :bold      => 1,
    :underline => 4,
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

  @color = true
  class << self
    attr_accessor :color

    def insert_code(string, code)
      if @color && STDOUT.tty? && ENV['TERM'] && ENV['TERM'] != 'dumb'
        string = to_ansi(string) unless string =~ /^\e\[[\d;]+m.*\e\[0m$/
        string.sub /^(\e\[[\d;]+)/, '\1;' + code.to_s
      else
        string
      end
    end

    def define_styles(styles, force=false)
      String.class_eval do
        styles.each_pair do |meth, style|
          raise Exception, "already defined method '#{meth}' for #{self}:#{self.class}" \
            if !force && String.instance_methods.include?(meth.to_s)
          define_method(meth) do
            style.inject(self) { |str, m| str.send m }
          end
        end
      end
    end

    private

    def to_ansi(string)
      sprintf "\e[0m%s\e[0m", string
    end
  end

  String.class_eval do
    Colorer::CODES.each_pair do |meth, code|
      define_method(meth) do
        Colorer.insert_code(self, code)
      end
    end
  end

end
