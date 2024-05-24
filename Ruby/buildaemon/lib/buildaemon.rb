# frozen_string_literal: true

require_relative "buildaemon/version"
require "open3"
require "kconv"
require "date"

module Buildaemon
  class Error < StandardError; end

  class Terminal
    module Ground
      Foreground = 30
      Background = 40
    end

    module Color
      Black   = 0
      Red     = 1
      Green   = 2
      Yellow  = 3
      Blue    = 4
      Magenta = 5
      Cyan    = 6
      White   = 7
    end

    def self.ToColorString(colorCode, string)
      "\e[#{colorCode}m#{string}\e[0m"
    end

    def self.Print(ground, color, string)
      print Terminal.ToColorString(ground + color, string)
    end

    def self.Puts(ground, color, string)
      puts Terminal.ToColorString(ground + color, string)
    end
  end

  def self.Execute(command)
    timestamp = DateTime.now.strftime("%y/%m/%d %H:%M:%S")
    Terminal.Puts(Terminal::Ground::Foreground, Terminal::Color::Green, "[#{timestamp}] $ #{command}")
    Open3.popen3(command){|i, o, e, w|
      i.close
      o.each{|line| STDOUT.puts line.toutf8}
      e.each{|line| STDERR.puts line.toutf8}
      exitStatus = w.value.exitstatus
      if block_given?
        yield(exitStatus)
      elsif exitStatus != 0
        exit(exitStatus)
      end
    }
  end
end
