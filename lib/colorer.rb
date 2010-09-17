module Colorer

  VERSION = File.read(File.expand_path('../../VERSION', __FILE__)).strip

  class Exception < ::Exception; end

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

  @color = true
  class << self
    attr_accessor :color

    def add_sgr(string, sgr)
      return string unless (Colorer.color && STDOUT.tty? && ENV['TERM'] && ENV['TERM'] != 'dumb')
      string = sprintf("\e[0m%s\e[0m", string) unless string =~ /^\e\[[\d;]+m.*\e\[0m$/
      sgr = Colorer::BASIC_SGR[sgr] if sgr.is_a?(Symbol)
      raise Exception, "undefined SGR code '#{sgr}'" if sgr.nil?
      string.sub /^(\e\[[\d;]+)/, '\1;' + sgr.to_s
    end

    def define_styles(styles, force=false)
      String.class_eval do
        if styles.delete(:basic)
          Colorer::BASIC_SGR.each_pair do |meth, sgr|
            raise Exception, "already defined method '#{meth}' for #{self}:#{self.class}" \
              if !force && instance_methods.include?(meth.to_s)
            define_method(meth) do
              Colorer.add_sgr(self, sgr)
            end
          end
        else
          styles.each_pair do |meth, style|
            raise Exception, "already defined method '#{meth}' for #{self}:#{self.class}" \
              if !force && instance_methods.include?(meth.to_s)
            define_method(meth) do
              style.inject(self) { |str, sgr|  Colorer.add_sgr(str, sgr) }
            end
          end
        end
      end
    end
  end

end
