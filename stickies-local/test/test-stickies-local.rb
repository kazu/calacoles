require 'test/unit'
require "stickies-local"

class StickiesLocalTest < Test::Unit::TestCase
  def test_db_path
    assert_equal("#{ENV["HOME"]}/Library/StickiesDatabase",Calacoles.db_path)
  end
  def test_backup
    stk = Calacoles
    stk.backup
    assert_equal(stk.backupname,"#{ENV["HOME"]}/Library/StickiesDatabase.backup")
    
    assert_equal(true, File.exists?("#{ENV["HOME"]}/Library/StickiesDatabase.backup") )
    stk.remove_backup
    assert_equal(false, File.exists?("#{ENV["HOME"]}/Library/StickiesDatabase.backup") )
  end

end
