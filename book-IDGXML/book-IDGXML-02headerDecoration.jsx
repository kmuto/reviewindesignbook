/* Re:VIEW+InDesign制作技法
   コラム飾りと大見出しを配置する
   Copyright 2016 Kenshi Muto

The MIT License
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
#include "../libs/libProcessXMLForPlaceGroup.jsx"

// 共通設定
var myDocument = app.activeDocument;
var obj = new Object;
obj.document = myDocument;
obj.overflowmaster = "A-マスター";
var partmaster = myDocument.masterSpreads.item("Z-パーツ");

// コラム飾り
obj.item = partmaster.pageItems.item("column-icon");
obj.tagname = "columnbox";
obj.replaces = null;
processXMLForPlaceGroup(obj);

// 大見出し。no、caption属性の値を使用する
obj.item = partmaster.pageItems.item("h2-header");
obj.tagname = "h2box";
obj.replaces = [["no", null], ["caption", null]];
processXMLForPlaceGroup(obj);
