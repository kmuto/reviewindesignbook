/* Re:VIEW+InDesign制作技法
   2行になった中見出しおよび小見出しのスタイルと飾りを調整する
   Copyright 2016 Kenshi Muto

The MIT License
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
var myDocument = app.activeDocument;
var partmaster = myDocument.masterSpreads.item("Z-パーツ");
app.findTextPreferences = NothingEnum.NOTHING;

// 小見出しの2行確認
var pstyle2 = myDocument.paragraphStyles.item("H4-小見出し/2行");
app.findTextPreferences.appliedParagraphStyle =
  myDocument.paragraphStyles.item("H4-小見出し");
var hits = myDocument.findText(true);
for (var i = 0; i < hits.length; i++) {
  if (hits[i].lines.length > 1) hits[i].appliedParagraphStyle = pstyle2;
}

pstyle2 = myDocument.paragraphStyles.item("H4-小見出し/2行/上0");
app.findTextPreferences.appliedParagraphStyle =
  myDocument.paragraphStyles.item("H4-小見出し/上0");
var hits = myDocument.findText(true);
for (var i = 0; i < hits.length; i++) {
  if (hits[i].lines.length > 1) hits[i].appliedParagraphStyle = pstyle2;
}

// 中見出しの飾り
var item1 = partmaster.pageItems.item("h3-icon");
var item2 = partmaster.pageItems.item("h3-icon/2行");

for (var type = 0; type < 2; type++) {
  if (type == 0) {
    app.findTextPreferences.appliedParagraphStyle =
      myDocument.paragraphStyles.item("H3-項見出し");
    pstyle2 = myDocument.paragraphStyles.item("H3-項見出し/2行");
  } else {
    app.findTextPreferences.appliedParagraphStyle =
      myDocument.paragraphStyles.item("H3-項見出し/上0");
    pstyle2 = myDocument.paragraphStyles.item("H3-項見出し/2行/上0");
  }

  hits = myDocument.findText(true);

  for (var i = 0; i < hits.length; i++) {
    if (hits[i].lines.length > 1) { // 2行
      hits[i].appliedParagraphStyle = pstyle2;
      var copieditem = item2.duplicate();
      copieditem.select();
    } else { // 1行
      var copieditem = item1.duplicate();
      copieditem.select();
    }
    app.cut();
    hits[i].insertionPoints[0].select(); // 段落の先頭にカーソルを置く
    app.paste();
  }
}

app.findTextPreferences = NothingEnum.NOTHING;
