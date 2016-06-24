/* Re:VIEW+InDesign制作技法
   メインメニュー
   Copyright 2016 Kenshi Muto

The MIT License
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
#include "../libs/libCommon.jsx"

app.scriptPreferences.userInteractionLevel =
  UserInteractionLevels.INTERACT_WITH_ALL;

var labels = ["実行のキャンセル",
   "ステージ1: ドキュメントの初期化〜ファイルの読み込み",
   "ステージ2: 開始ページ指定〜章扉",
   "ステージ3: 2行見出し〜背景",
   "ステージ4: PDF生成",
   "ステージ2': オーバーフロー処理のみ",
];
var cc = new Array(labels.length);
var wObj = app.dialogs.add({ name: "Re:VIEW+InDesignメニュー" });
with (wObj.dialogColumns.add()) {
  with (radiobuttonGroups.add()) {
    for (var i = 0; i < labels.length; i++) {
      cc[i] = radiobuttonControls.add({staticLabel: labels[i]});
    }
  }
}
cc[0].checkedState = true;

if (wObj.show() == false) exit(0);

switch (wObj.dialogColumns[0].radiobuttonGroups[0].selectedButton) {
  case 0: exit(0);
  case 1: // ドキュメントの初期化〜ファイルの読み込み
    callScripts(["silent/silentClearDocument", "dialogs/dialogPasteXML"]);
    break;
  case 2: // 開始ページ指定〜章扉
    callScripts(["dialogs/dialogStartPage",
                 "silent/silentSpecialCharactersRemove",
                 "book-IDGXML/book-IDGXML-02overflow",
                 "book-IDGXML/book-IDGXML-02headerDecoration",
                 "book-IDGXML/book-IDGXML-02applyImageObjectStyle",
                 "book-IDGXML/book-IDGXML-02modifyTable",
                 "silent/silentMakeFootnote",
                 "silent/silentRemoveFootnote",
                 "silent/silentGroupRuby",
                 "book-IDGXML/book-IDGXML-02frontPage",
                 "book-IDGXML/book-IDGXML-02overflow",
                ]);
    break;
  case 3: // 2行見出し〜背景
    callScripts(["book-IDGXML/book-IDGXML-03twoLine",
                 "book-IDGXML/book-IDGXML-02overflow",
                 "book-IDGXML/book-IDGXML-03background"]);
    break;
  case 4: // PDF保存
    callScripts(["dialogs/dialogKeepTagAndTwoSavePDF"]);
    break;
  case 5: // オーバーフロー
    callScripts(["book-IDGXML/book-IDGXML-02overflow"]);
}
