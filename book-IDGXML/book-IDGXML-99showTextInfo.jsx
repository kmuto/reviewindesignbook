// テキストフレームから情報を取得する
var myDocument = app.activeDocument;

var tf = myDocument.pages[0].textFrames.item("main-content");
var story = tf.parentStory;

alert(myDocument.name + " の解析結果\n" +
      "ページ数: " + myDocument.pages.length +
      "\n段落数: " + story.paragraphs.length +
      "\n行数: " + story.lines.length +
      "\n1行目の段落スタイル: " + story.paragraphs[0].appliedParagraphStyle.name +
      "\nルートエレメントの名前: " + tf.associatedXMLElement.markupTag.name);
