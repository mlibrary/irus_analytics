# frozen_string_literal: true

module Configurations
  class SearchDirectoriesForFile
    class << self
      private
      def combined_list(directories, file_name)
        directories.lazy.map { |directory| File.expand_path(File.join(directory, file_name)) }
      end

      public
      def call(directories=['.'], file_name='irus_analytics_counter_robot_list.txt')
        combined_list(directories, file_name).find{ |path| File.file?(path) }
      end
    end
  end
end
