# -*- coding: utf-8 -*-
require 'review'
module ReVIEW
  class Builder
    Compiler.defsingle(:linenum, 1..2)
    def linenum(num, bolds=nil)
      @linenum = num.to_i - 1
      if bolds
        @linebold = {}
        bolds.split(',').each do |ba|
          if ba =~ /(\d+)\-(\d+)/
            from = $1.to_i
            till = $2.to_i
            from.upto(till) {|n| @linebold[n] = "bold" }
          else
            @linebold[ba.to_i] = "bold"
          end
        end
      end
    end
  end

  class LATEXBuilder
    def table_header(id, caption)
      if caption.present?
        @table_caption = true
        puts '\begin{table}[H]'
        puts macro('reviewtablecaption', compile_inline(caption))
      end
      puts macro('label', table_label(id))
    end
  end

  class HTMLBuilder
    def listnum_body(lines, lang)
      @linenum = 0 if @linenum.nil?
      @linebold = {} if @linebold.nil?
      if highlight?
        body = lines.inject(''){|i, j| i + detab(j) + "\n"}
        lexer = lang
        lines = highlight(:body => body, :lexer => lexer, :format => 'html',
                          :options => {:linenos => 'inline', :linenostart => @linenum + 1, :nowrap => false})
        # 強調を復活させる
        lines.split("\n").each_with_index do |line, i|
          if @linebold[@linenum + i + 1]
            print line.sub('</span>', '</span><b class="modify">')
            puts '</b>'
          else
            puts line
          end
        end
      else
        print '<pre class="list">'
        lines.each_with_index do |line, i|
          line = "<b class='modify'>#{line}</b>" if @linebold[@linenum + i + 1]
          puts detab((@linenum + i+1).to_s.rjust(3) + ": " + line) # 3桁必要
        end
        puts '</pre>'
        @linenum = 0
        @linebold = {}
      end
    end

    def emlistnum(lines, caption = nil, lang = nil)
      @linenum = 0 if @linenum.nil?
      @linebold = {} if @linebold.nil?
      puts %Q[<div class="emlistnum-code">]
      if caption.present?
        puts %Q(<p class="caption">#{compile_inline(caption)}</p>)
      end

      if highlight?
        body = lines.inject(''){|i, j| i + detab(j) + "\n"} # FIXME @linenum
        lexer = lang
        lines = highlight(:body => body, :lexer => lexer, :format => 'html',
                          :options => {:linenos => 'inline', :linenostart => @linenum + 1, :nowrap => false})
        # 強調を復活させる
        lines.split("\n").each_with_index do |line, i|
          if @linebold[@linenum + i + 1]
            print line.sub('</span>', '</span><b class="modify">')
            puts '</b>'
          else
            puts line
          end
        end
      else
        print '<pre class="emlist">'
        lines.each_with_index do |line, i|
          line = "<b class='modify'>#{line}</b>" if @linebold[@linenum + i + 1]
          puts detab((@linenum + i+1).to_s.rjust(3) + ": " + line) # 3桁必要
        end
        puts '</pre>'
      end
      @linenum = 0
      @linebold = {}

      puts '</div>'
    end

    def cmd(lines, caption = nil)
      # highlightしない
      puts %Q[<div class="cmd-code">]
      if caption.present?
        puts %Q(<p class="caption">#{compile_inline(caption)}</p>)
      end
      print %Q[<pre class="cmd">]
      body = lines.inject(''){|i, j| i + detab(j) + "\n"}
      lexer = 'shell-session'
      puts body
      puts '</pre>'
      puts '</div>'
    end

    def emlist(lines, caption = nil, lang = nil)
      # langが文字列「nil」ならhighlightしない
      # ダミーの/***と***/は削除する
      puts %Q[<div class="emlist-code">]
      if caption.present?
        puts %Q(<p class="caption">#{compile_inline(caption)}</p>)
      end
      print %Q[<pre class="emlist">]
      body = lines.inject(''){|i, j| i + detab(j) + "\n"}
      lexer = lang
      if lexer == "nil"
        puts body
      else
        puts highlight(:body => body, :lexer => lexer, :format => 'html').gsub('/*** ', '').gsub(' ***/', '')
      end
      puts '</pre>'
      puts '</div>'
    end

    def inline_dtp(str)
      # InDesign固有の紙面改行命令は削除
      if %w(lb lbt).include?(str)
        return ''
      end
      "<?dtp #{str} ?>"
    end
  end

  class IDGXMLBuilder
    def emlist(lines, caption = nil, lang = nil)
      caption = nil if caption.blank?
      quotedlist lines, 'emlist', caption
    end

    def emlistnum(lines, caption = nil, lang = nil)
      caption = nil if caption.blank?
      @linenum = 0 if @linenum.nil?
      @linebold = {} if @linebold.nil?
      _lines = []
      lines.each_with_index do |line, i|
        line = "<b type='modify'>#{line}</b>" if @linebold[@linenum + i + 1]
        _lines << detab("<span type='lineno'>" + (@linenum + i + 1).to_s.rjust(3) + ": </span>" + line)
      end
      quotedlist _lines, 'emlistnum', caption
      @linenum = 0
      @linebold = {}
    end

    def listnum_body(lines, lang)
      caption = nil if caption.blank?
      @linenum = 0 if @linenum.nil?
      @linebold = {} if @linebold.nil?
      print %Q(<pre>)
      no = 1
      lines.each_with_index do |line, i|
        unless @book.config["listinfo"].nil?
          print "<listinfo line=\"#{no}\""
          print " begin=\"1\"" if no == 1
          print " end=\"#{no}\"" if no == lines.size
          print ">"
        end
        line = "<b type='modify'>#{line}</b>" if @linebold[@linenum + i + 1]
        print detab("<span type='lineno'>" + (@linenum + i + 1).to_s.rjust(3) + ": </span>" + line)
        print "\n"
        print "</listinfo>" unless @book.config["listinfo"].nil?
        no += 1
      end
      puts "</pre></codelist>"
      @linenum = 0
      @linebold = {}
    end
  end
end
