/* Re:VIEW+InDesign制作技法
   ページがオーバーフローしていたら新たなページを作成する
   Copyright 2016 Kenshi Muto

The MIT License
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
#include "../libs/libProcessXMLforBackgroundImage3.jsx"

// 共通設定
var myDocument = app.activeDocument;
var obj = new Object;

obj.progress = true;
obj.layername = "tmp-背景";
obj.white = true;
obj.singlexpath = true;
obj.searchendtype = 4;

// 上側と下側の白のオフセット。[Y1, X1, Y2, X2]
obj.woffsetunits = [[-3, -2, 0, 2], [0, -2, 3, 2]];
obj.wstyle = myDocument.objectStyles.item("白");

// 既存のレイヤーの削除
if (myDocument.layers.item(obj.layername) != null) {
  myDocument.layers.item(obj.layername).remove();
}

// columnケイ
obj.tagname = "doc/column";
// 始まりと次ページ以降それぞれのオフセット。[Y1, X1, Y2, X2]
obj.offsetunits = [[-1, 0, -1, 0], [-2, 0, -1, 0]];
// ページをまたいだときは下に伸ばす
obj.okuribottom = 3;
obj.ostyle = myDocument.objectStyles.item("コラム枠");
obj.width = 138;
obj.lfit = true;
obj.fit = true;
obj.files = [null];
processXMLforBackgroundImage3(obj, myDocument);
