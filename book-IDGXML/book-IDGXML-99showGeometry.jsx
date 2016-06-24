// 選択したテキストフレームまたは矩形の座標と縦横の幅を表示する
var myDocument = app.activeDocument;

if (myDocument.selection.length == 1 &&
    (myDocument.selection[0] instanceof TextFrame ||
     myDocument.selection[0] instanceof Rectangle)) {
  var message = getSizeMsg(myDocument.selection[0]);
  alert(message);
} else {
  alert("テキストフレームか画像を1つ選択してください");
}

function getSizeMsg(item) {
  var bounds = item.visibleBounds;
  var message = "(" + bounds[1] + ", " + bounds[0] + ") 〜 " +
                "(" + bounds[3] + ", " + bounds[2] + ") \n" +
                "横幅: " + (bounds[3] - bounds[1]) +
                ", 縦幅: " + (bounds[2] - bounds[0]);
  return message;
}
