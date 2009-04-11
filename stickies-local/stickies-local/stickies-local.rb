require "osx/cocoa"
require "osx/foundation"
require "bundle/document"
require "fileutils"

class String
  def to_nsstr
    OSX::NSString.stringWithString(self)
  end
end

module Calacoles
  def self.db_path
    File.join(ENV["HOME"],"Library/StickiesDatabase")
  end

  def self.backupname
    @backupname
  end

  def self.backup(dst=nil)
    @backupname = dst ||  
                  File.join(ENV["HOME"], "Library/StickiesDatabase.backup")
    FileUtils.cp(Calacoles::db_path,@backupname)
  end

  def self.remove_backup(dst=nil)
    dst ||= @backupname 
    FileUtils.rm_f(dst) if dst
  end

  class StickiesArchive
    attr_reader :stickies
    def StickiesArchive.load(db=nil)
      db ||= Calacoles::db_path
      self.new(db)
    end
    def to_path(str)
      OSX::NSString.stringWithString(str).stringByExpandingTildeInPath
    end

    def save
      OSX::NSArchiver.archiveRootObject_toFile(@stickies,to_path(@db))
    end

    def initialize(db)
      @db = db 
      @archive = OSX::NSUnarchiver.unarchiveObjectWithFile(
        OSX::NSString.stringWithString(db).stringByExpandingTildeInPath)
      @stickies = OSX::NSMutableArray.alloc.initWithArray(@archive)
    end

    def free_memory
      @stickies.free
    end

    def to_a
      @stickies.collect{|x| StickiesLocal.new(x) }
    end

  end

  class StickiesLocal
    attr_reader :backupname, :doc, :rtf
    def initialize(doc=nil)
      @doc = doc
    end
    def title
      [@doc.object_id.to_s, @doc.stringValue.to_s.gsub(/\n.+/m,"")].join(": ")
    end
    def to_h(opt={:type=>:rtfd})
      ret = {}
      ret.merge(
        :title => @doc.stringValue.to_s.gsub(/\n.+/m,""),
        :raw => self.to_s(opt),
        :format => opt[:type].to_s,
        :desc => @doc.stringValue.to_s
      ) 
    end
    # :type => :string, :doc, :rtf, :rtfd
    def to_s(opt={:type=>:string})
      return @doc.stringValue.to_s if opt[:type] == :string
      attStr = 
        OSX::NSAttributedString.alloc.initWithRTFD_documentAttributes(
          @doc.RTFDData,
          nil
        )
      attStr.send(
        case opt[:type]
        when :doc
          "docFormatFromRange_documentAttributes"
        when :rtf
          "RTFFromRange_documentAttributes"
        when :rtfd
          "RTFDFromRange_documentAttributes"
        end,
        OSX::NSMakeRange(0,attStr.length),nil).rubyString
    end
    # :type=> :String , :doc, :html, :rtf
    def init_doc(str,opt={:type=>:String})
      atts = OSX::NSMutableDictionary.alloc.init
      atts.setValue_forKey(
        OSX::NSFont.fontWithName_size("Helvetica",0.0),
        OSX::NSFontAttributeName
      )
      data = nil
      case opt[:type]
      when :doc
        data = OSX::NSData.dataWithRubyString(str)
        attStr = 
          OSX::NSAttributedString.alloc.initWithDocFormat_documentAttributes(
            data,
            atts
          )
      else
        data = str.to_nsstr
        attStr = OSX::NSAttributedString.alloc.initWithString_attributes(
          data,
          atts
        )
      end
      if opt[:out]
        open(opt[:out],"w+"){|f|
          f.write attStr.RTFFFromRange_documentAttributes(
            OSX::NSMakeRange(0,
                             attStr.length
                            ),
            nil
          ).rubyString
        }
      end
      @doc = OSX::Document.alloc.initWithData(
        attStr.RTFDFromRange_documentAttributes(
          OSX::NSMakeRange(0,
                           attStr.length
                          ),nil)
      )
    end
  end

end

if $0 == __FILE__
#  Calacoles.remove_backup
end
