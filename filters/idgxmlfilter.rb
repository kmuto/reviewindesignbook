#!/usr/bin/env ruby
# Copyright 2016 Kenshi Muto
#
# The MIT License
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require_relative 'libinstructions/libinstructions'

class IDGXMLFilter
  def initialize(outio)
    # 初期化
    @outio = outio
  end

  def convert_line(l)
    # 入力を単なる文字列として操作する処理
    l.gsub('<?dtp lb ?>', "\n")
  end

  def export_xml(doc)
    # 加工済みのXMLコンテンツを出力
    @outio.puts XMLDecl.new('1.0', 'UTF-8')
    @outio.puts doc
  end

  def convert(io)
    # XMLコンテンツの取り込みと変換呼び出し
    s = ''
    io.each do |l|
      s << convert_line(l)
    end
    parse(Document.new(s).root)
  end

  def parse(doc)
    # XMLコンテンツの変換呼び出しの中心
    doc.context[:attribute_quote] = :quote
    doc = modify_xml(doc)
    doc = insert_spaces(doc)
    doc = insert_docpstyle(doc)
    doc
  end

  def modify_xml(doc)
    # 紙面固有のXMLドキュメントの変換
    # エレメント内末尾に改行を入れる
    %w(p li caption).each do |tag|
      doc.each_element("//#{tag}") do |e|
        insert_last(e, '', nil, "\n")
      end
    end
    doc.each_element('//title') do |e|
      if e.next_sibling.kind_of?(Instruction)
        # 弟がインストラクションならその後ろに追加
        insert_after(e.next_sibling, '', nil, "\n")
      else
        insert_last(e, '', nil, "\n")
      end
    end

    doc.each_element('/doc') do |e|
      # 本書の基本スタイル
      pS(e, 'b-本文')
    end

    doc.each_element('//title') do |e|
      # 見出し
      pstyle = nil
      case e.attributes['aid:pstyle']
      when 'h1'
        pstyle = 'z-章タイトル/隠し'
        no, caption = e.text.split('　', 2) # 全角スペース
        e[0].remove
        insert_first(e, '', nil, caption)
        no = no.sub('第', '').sub('章', '').sub('付録', '')
        insert_first(e, 'line', {'pstyle' => 'z-章番号/隠し'}, "#{no}\n")
      when 'h2'
        no, caption = e.text.split('　', 2) # 全角スペース
        if caption
          pstyle = 'H2-節見出し/位置'
          e[0].remove
          insert_first(e, 'h2box', {'no' => no, 'caption' => caption}, nil)
          # あとで置き換えられる
        else
          pstyle = 'M-この章のまとめ/見出し'
          e2name, e2 = next_element2(e)
          e2.attributes['summary'] = 'yes' if e2name == 'ul'
        end
      when 'h3'
        pstyle = 'H3-項見出し'
        pstyle = 'H3-項見出し/上0' if previous_element(e) == 'title'
        insert_first(e, '', nil, "\t")
        # 2行の場合は ……/2行 になる
      when 'h4'
        pstyle = 'H4-小見出し'
        pstyle = 'H4-小見出し/上0' if previous_element(e) == 'title'
        # 2行の場合は ……/2行 になる
      when 'column-title'
        pstyle = 'c-コラム/タイトル'
        insert_first(e, '', nil, "\t")
        insert_first(e, 'columnbox', nil, nil) # あとで置き換えられる
      end
      pS(e, pstyle) if pstyle
    end

    doc.each_element('//p') do |e|
      pstyle = 'b-本文'
      pstyle = 'c-コラム/本文' if in_block?(e, ['column'])
      pstyle = 'b-扉リード' if in_block?(e, ['lead'])

      if pstyle != 'b-扉リード' && e.attributes['noindent'].nil? && e.attributes['align'].nil?
        insert_first(e, '', nil, '　') # 字下げ
      end
      pS(e, pstyle)
    end

    doc.each_element('//li') do |e|
      pstyle = nil
      case e.parent.name
      when 'ul'
        pstyle = 'i-箇条書き'
        pstyle = 'c-コラム/i-箇条書き' if in_block?(e, ['column'])
        pstyle = 'M-この章のまとめ/項目' if e.parent.attributes['summary']
      when 'ol'
        pstyle = 'n-箇条書き'
        pstyle = 'c-コラム/n-箇条書き' if in_block?(e, ['column'])
        insert_first(e, '', nil, "\t")
        insert_first(e, 'span', {'cstyle' => 'n-箇条書き/手順数字'},
                     "#{e.attributes['num']}.")
        insert_first(e, '', nil, "\t") if e.attributes['num'].to_i < 10
      end
      pS(e, pstyle) if pstyle
    end

    doc.each_element('//caption') do |e|
      pstyle = nil
      case e.parent.name
      when 'img'
        pstyle = 'f-図/キャプション'
      when 'table'
        pstyle = 't-表/キャプション'
      when 'codelist', 'list'
        pstyle = 'L-リスト/キャプション'
      end

      if pstyle
        pstyle = "c-コラム/#{pstyle}" if in_block?(e, ['column'])
        pS(e, pstyle)
      end
    end

    doc.each_element('//codelist|//list') do |e|
      # 薄いアミのコードリスト
      pstyle = 'L-コードリスト'
      pstyle = 'c-コラム/L-コードリスト' if in_block?(e, ['column'])

      if e.attributes['type'] == 'cmd'
        # 黒アミの実行例
        pstyle = 'L-実行結果'
        pstyle = 'c-コラム/L-実行結果' if in_block?(e, ['column'])
      end

      pS(e, pstyle)
    end

    doc.each_element('//img/Image') do |e|
      # 図版
      insert_after(e, 'line', {'pstyle' => 'f-図/位置'}, "\n")
      oS(e, '図')
    end

    doc.each_element('//tbody') do |e|
      # 表全体
      pstyle = 'b-本文'
      pstyle = 'c-コラム/本文' if in_block?(e, ['column'])
      tS(e, '通常の表')
      insert_after(e, 'line', {'pstyle' => pstyle}, "\n")
    end

    doc.each_element('//td') do |e|
      # 表のセル
      set_cell_attributes(e)

      pstyle = 't-表項目'
      estyle = 't-通常表'

      if (e.attributes['aid:theader'] && e.attributes['celltype'].nil?) ||
          e.attributes['celltype'] == 'th'
        pstyle = 't-表見出し'
        estyle = 't-通常表/ヘッダー'
      elsif e.attributes['celltype'] == 'tg'
        estyle = 't-通常表/左のアミ'
      end

      case e.attributes['align']
      when 'left'
        pstyle = "#{pstyle}/左"
      when 'center'
        pstyle = "#{pstyle}/中"
      when 'right'
        pstyle = "#{pstyle}/右"
      end

      pS(e, pstyle)
      eS(e, estyle)
    end

    doc.each_element('/doc/lead') do |e|
      # リード末尾に強制改ページ文字挿入
      insert_last(e, '?', {'dtp' => 'pagebreak'}, nil)
    end

    doc.each_element('//b|//keyword') do |e|
      # 太字
      cstyle = 'b-本文/太字'
      cstyle = 'i-箇条書き/太字' if in_block?(e, ['li'])
      cstyle = 'c-コラム/太字' if in_block?(e, ['column'])
      cstyle = 'L-等幅/太字' if in_block?(e, ['pre'])
      cS(e, cstyle)
    end

    doc.each_element('//tt') do |e|
      # 等幅
      cstyle = 'b-本文/等幅'
      cstyle = 'b-本文/等幅/太字' if e.attributes['style'] == 'bold'
      cS(e, cstyle)
      # 「結合なし」文字を挿入
      insert_after(e, '?', {'dtp' => 'zerowidthnonjoiner'}, nil)
    end

    doc.each_element('//span[@type]') do |e|
      # 参照太字
      cstyle = 'b-本文/太字'
      cstyle = 'i-箇条書き/太字' if in_block?(e, ['li'])
      cstyle = 'c-コラム/太字' if in_block?(e, ['column'])
      cS(e, cstyle)
    end

    doc
  end

  def insert_spaces(doc)
    # 紙面固有の要素間空行の挿入
    nohead = %w(title line) # このエレメントの前には空行を入れない
    notail = %w(title line) # このエレメントのあとには空行を入れない

    doc.each_element('//column') do |e|
      # 囲み罫線内の上下余白
      insert_first(e, 'line', {'pstyle' => 'c-コラム/上'}, "\n")
      insert_last(e, 'line', {'pstyle' => 'c-コラム/下'}, "\n")

      insert_before(e, 'line', {'pstyle' => 'b-本文'}, "\n") if
        !previous_element(e).nil? && !notail.include?(previous_element(e))
      insert_after(e, 'line', {'pstyle' => 'b-本文'}, "\n") if
        !next_element(e).nil? && !nohead.include?(next_element(e))
    end

    doc.each_element('//img|//ul|//ol|//list|//codelist|//table') do |e|
      pstyle = 'b-本文'
      pstyle = 'c-コラム/本文' if in_block?(e, ['column'])

      # 前の空行
      insert_before(e, 'line', {'pstyle' => pstyle}, "\n") if
        !previous_element(e).nil? && !notail.include?(previous_element(e))

      # 後ろの空行
      insert_after(e, 'line', {'pstyle' => pstyle}, "\n") if
        !next_element(e).nil? && !nohead.include?(next_element(e))
    end

    doc.each_element('//title[@aid:pstyle="M-この章のまとめ/見出し"]') do |e|
      insert_before(e, 'line', {'pstyle' => 'b-本文'}, "\n") if
        !previous_element(e).nil?
    end

    doc
  end

  def insert_docpstyle(doc)
    # 紙面固有のコンテンツ末尾段落の設定
    insert_last(doc, 'line', {'pstyle' => 'b-本文'}, nil)
    doc
  end
end

conv = IDGXMLFilter.new(STDOUT)
conv.export_xml(conv.convert(STDIN))
