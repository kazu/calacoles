require "osx/cocoa"
require "osx/foundation"
require "bundle/document"
require "fileutils"

module Calacoles
  def self.db_path
    File.join(ENV["HOME"],"Library/StickiesDatabase")
  end
  class StickiesLocal
    attr_reader :backupname
    def initialize(doc=nil)
      @doc = doc
    end
    def backup(dst=nil)
      @backupname = dst ||  
                    File.join(ENV["HOME"], "Library/StickiesDatabase.backup")
      FileUtils.cp(Calacoles::db_path,@backupname)
    end

    def remove_backup
      FileUtils.rm_f(@backupname) if @backupname
    end

  end

end

