// $(function() {
//   $('#recipe_genre_id').change(function() {
//     $.get({
//       url: "<%= search_category_recipe_path %>",
//       data: { genre_id: $('#recipe_genre_id').has('option:selected').val() }
//     });
//   });
// });

window.addEventListener('turbolinks:load', function () {
  new textFieldWidth();
  new textFieldHeight();
  new addFields();
  new removeFields();
  new alertImage();
  new imagePreview();
})

// テキストフィールドの幅の自動調整
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

// 材料、作り方、タグの項目追加
class addFields {
  constructor() {
    this.links = document.querySelectorAll('.add_fields')
    this.iterateLinks()
  }

  iterateLinks() {
    if (this.links.length === 0) return
    this.links.forEach(link => {
      link.addEventListener('click', e => {
        this.handleClick(link, e)
      })
    })
  }

  handleClick(link, e) {
    if (!link || !e) return
    e.preventDefault()
    let time = new Date().getTime()
    let linkId = link.dataset.id
    let regexp = linkId ? new RegExp(linkId, 'g') : null
    let newFields = regexp ? link.dataset.fields.replace(regexp, time) : null
    newFields ? link.insertAdjacentHTML('beforebegin', newFields) : null

    // 以下カスタマイズ草案
    var getId = "recipe_recipe_steps_attributes_" + time + "_image"
    // console.log(getId)
  }
}

// 材料、作り方、タグの項目削除
class removeFields {
  constructor() {
    this.iterateLinks()
  }

  iterateLinks() {
    document.addEventListener('click', e => {
      if (e.target && e.target.className == 'remove_fields') {
        this.handleClick(e.target, e)
      }
    })
  }

  handleClick(link, e) {
    if (!link || !e) return
    e.preventDefault()
    let fieldParent = link.closest('.nested-fields')
    let deleteField = fieldParent
      ? fieldParent.querySelector('input[type="hidden"]')
      : null
    if (deleteField) {
      deleteField.value = 1
      fieldParent.style.display = 'none'
    }
  }
}

// レシピ画像のプレビュー
class imagePreview {
  constructor() {
    this.previewElement = document.getElementById('preview');
    this.recipeImageElement = document.getElementById('recipe_image');
    this.bindEvent();
  }

  bindEvent() {
    if (this.recipeImageElement) {
      this.recipeImageElement.addEventListener('change', this.handleChange.bind(this));
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
    const imageContent = document.querySelector('img');
    if (imageContent) {
      imageContent.remove();
    }
  }

  createImageHTML(blob) {
    const blobImage = document.createElement('img');
    blobImage.setAttribute('class', 'new-img img-fluid');
    blobImage.setAttribute('src', blob);
    this.previewElement.appendChild(blobImage);
  }
}

// 作り方でwebpファイルが添付された際の警告、ファイルの削除
class alertImage {
  constructor() {
    this.iterateLinks()
  }

  iterateLinks() {
    document.addEventListener('change', e => {
      if (e.target && e.target.className == 'test') {
        this.handleClick(e)
      }
    })
  }

  handleClick(event) {
    const file = event.target.files[0];
    console.log(file)
    if (file.name.endsWith(".webp")) {
      alert("webp形式の画像は選択できません");
      event.target.value = "";
      return
    }
  }
}

let genreForm = document.getElementById('recipe_genre_id');
let categoryForm = document.getElementById('recipe_category_id');
let categoryValue = categoryForm.options[0];
genreForm.onchange = inputChange;
function inputChange(){
  if(genreForm.value == ''){
    categoryForm.disabled = true;
    categoryForm.insertBefore(categoryValue, categoryForm.options[0]);
  } else {
    categoryForm.disabled = false;
  }
}