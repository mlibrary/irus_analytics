# frozen_string_literal: true

module Configurations
  class RobotsList
    class << self
      def call(file)
        new(file).call
      end
    end

    private
    attr_reader :file
    def initialize(file)
      @file=file
    end

    def read_robot_list
      File.readlines(file).map(&:chomp)
    end

    public
    attr_reader :robot_list
    def call
      @robot_list||=read_robot_list
    end
  end
end
