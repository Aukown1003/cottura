  /*global $*/
  $(function() {
    const textHeightChange = new textFieldHeight();
    const textWidthChange = new textFieldWidth();
    if (textHeightChange.textareaEls) {
      textHeightChange.textHeight();
    }
    if (textWidthChange.textareaEls) {
      textWidthChange.textWidth();
    }
  })
  
  // テキストフィールドの幅の自動調整
  class textFieldHeight {
    constructor() {
      this.textareaEls = document.querySelectorAll("textarea");
      this.textHeight();
    }
    textHeight() {
      this.textareaEls.forEach(function(textareaEl) {
        textareaEl.setAttribute("style", `height: ${textareaEl.scrollHeight}px;`);
        textareaEl.addEventListener("input",function() {
          this.style.height = "auto";
          this.style.height = `${this.scrollHeight}px`;
        });
      });
    }
  }
  
  // テキストエリアの高さの自動調整
  class textFieldWidth {
  constructor() {
    this.textFields = document.querySelectorAll("input[type='text']");
    this.textWidth()
  }
  
  textWidth() {
    this.textFields.forEach(function(textField) {
      textField.addEventListener("input", function() {
        this.style.width = 17 + this.value.length + "ch";
      });
    });
  }
}