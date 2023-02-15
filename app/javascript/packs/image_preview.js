// export function test(){
//   console.log("test")
// }

// 画像のプレビュー
export class imagePreview {
    constructor(previewElement, imageElement, removeClassName, addClassName) {
      this.previewElement = document.getElementById(previewElement);
      this.imageElement = document.getElementById(imageElement);
      this.removeClass = removeClassName;
      this.addClass = addClassName;
      this.bindEvent();
    }
    
    bindEvent() {
      if (this.imageElement) {
        this.imageElement.addEventListener('change', this.handleChange.bind(this));
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
      const imageContent = document.querySelector(`.${this.removeClass}`);
      if (imageContent) {
        imageContent.remove();
      }
    }
  
    createImageHTML(blob) {
      const blobImage = document.createElement('img');
      blobImage.setAttribute('class', `${this.addClass}`);
      blobImage.setAttribute('src', blob);
      this.previewElement.appendChild(blobImage);
    }
  }