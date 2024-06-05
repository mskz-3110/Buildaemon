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
  end

  def self.Execute(command)
    timestamp = DateTime.now.strftime("%y/%m/%d %H:%M:%S")
    puts Terminal.ToColorString(Terminal::Ground::Foreground + Terminal::Color::Green, "[#{timestamp}] $ #{command}")
    Open3.popen3(command){|i, o, e, w|
      i.close
      threads = [
        Thread.new{
          while (line = o.gets) do
            STDOUT.puts line.toutf8
          end
        },
        Thread.new{
          while (line = e.gets) do
            STDERR.puts line.toutf8
          end
        }
      ].each{|thread| thread.join}
      status = w.value
      exitCode = status.exitstatus.nil? ? status.termsig : status.exitstatus
      if block_given?
        yield(status)
      elsif exitCode != 0
        exit(exitCode)
      end
    }
  end
end
