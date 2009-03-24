require "osx/cocoa"
require "osx/foundation"
require "bundle/document"
require "fileutils"

module Calacoles
  def self.db_path
    File.join(ENV["HOME"],"Library/StickiesDatabase")
  end
  class StickiesLocal
    def initialize(doc=nil)
      @doc = doc
    end
    def backup(dst=nil)
      dst ||= File.join(ENV["HOME"], "Library/StickiesDatabase.backup")
    end
  end
end

