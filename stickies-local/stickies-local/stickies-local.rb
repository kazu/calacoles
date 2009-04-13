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

    def replace(lists)
      @stickies.removeAllObjects
      #sth = lists[0]
      #sl = StickiesLocal.new(sth)
      #@stickies.addObject(sl.doc) if sl.doc
      #return true
      lists.each{|sth|
        sl =  StickiesLocal.new(sth)
        @stickies.addObject(sl.doc) if sl.doc
      }
    end

  end

  class StickiesLocal
    attr_reader :backupname, :doc, :rtf
    attr_accessor :status
    H2sl = {:color => :WindowColor,
            :flags => :WindowFlags }
    def initialize(src=nil)
      if src.class == Hash
         puts "write1"
         puts src[:title]
         init_doc(src[:raw].dup,:type=>src[:format].to_sym)
         #return self
         src[:pos].flatten! if src[:pos]
         if src[:pos] &&  src[:pos].size == 4
           rect = OSX::NSRect.new(*src[:pos])
           @doc.setWindowFrame(rect)
         end
         H2sl.each{|k,v|
           if src[k]
             @doc.send("set" + v.to_s, src[k]) if src[k]
           end
         }
         #puts title
      else
        @doc = src
      end
    end

    def title
      @doc.stringValue.to_s.gsub(/\n.+/m,"")#].join(": ")
    end

    def to_h(opt={:type=>:doc})
      ret = {}
      @status = if @doc.stringValue.to_s=~/status\:delete/
                  :hide
                end
      ret.merge(
        :title => @doc.stringValue.to_s.gsub(/\n.+/m,""),
        :raw => self.to_s(opt),
        :format => opt[:type].to_s,
        :desc => @doc.stringValue.to_s,
        :pos => @doc.windowFrame.to_a,
        :color => @doc.windowColor,
        :flags => @doc.windowFlags,
        :time => Time.now,
        :status => @status || :show
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
      when :rtfd
        data = OSX::NSData.dataWithRubyString(str)
        attStr = 
          OSX::NSAttributedString.alloc.initWithRTFD_documentAttributes(
            data,
            atts
          )
      else
        p opt[:type]
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
