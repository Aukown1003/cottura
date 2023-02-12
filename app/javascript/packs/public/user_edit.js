  /*global location history $*/
  window.onload = addToNewUrl();
  function addToNewUrl() {
    let path = location.pathname;
    let pattern = /^.*\/edit.*$/
  
    if(path.match(pattern)) return;
    history.replaceState('', '', `${ path }/edit`)
  }

  $(function() {
    new textFieldHeight();
    new imagePreview('preview_user','user_image');
  })
  
  // テキストエリアの高さの自動調整
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

  // ユーザーの画像のプレビュー
  class imagePreview {
    constructor(preview,image) {
      this.previewElement = document.getElementById(preview);
      this.userImageElement = document.getElementById(image);
      this.bindEvent();
    }
    
    bindEvent() {
      if (this.userImageElement) {
        this.userImageElement.addEventListener('change', this.handleChange.bind(this));
      }
    }
    
    handleChange(e) {
      const file = e.target.files[0];
      if (file.name.endsWith(".webp")) {
        alert("webp形式の画像は選択できません");
        e.target.value = "";
        return;
      }
      this.removeImageContent();
      this.createImageHTML(window.URL.createObjectURL(file));
    }
    
    removeImageContent() {
      const imageContent = document.querySelector(".user_profile_image");
      if (imageContent) {
        imageContent.remove();
      }
    }
    
    createImageHTML(blob) {
      const blobImage = document.createElement('img');
      blobImage.setAttribute('class', 'new-user-img img-fluid user_profile_image');
      blobImage.setAttribute('src', blob);
      this.previewElement.appendChild(blobImage);
    }
  }