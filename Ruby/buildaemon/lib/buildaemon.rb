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

    def self.ToColorString(colorCode, message)
      "\e[#{colorCode}m#{message}\e[0m"
    end
  end

  def self.Execute(command)
    timestamp = DateTime.now.strftime("%y/%m/%d %H:%M:%S")
    puts Terminal.ToColorString(Terminal::Ground::Foreground + Terminal::Color::Green, "[#{timestamp}] $ #{command}")
    status = nil
    begin
      Open3.popen3(command){|i, o, e, w|
        i.close
        threads = [
          Thread.new{while (line = o.gets) do STDOUT.puts line.toutf8 end},
          Thread.new{while (line = e.gets) do STDERR.puts line.toutf8 end}
        ].each{|thread| thread.join}
        status = w.value
        if !block_given?
          return if status.exitstatus == 0
          exit(false)
        end
      }
    rescue
      exit(false) if !block_given?
    end
    yield(status)
  end
end
