  /*global $*/
  
  $(function() {
    $('#recipe_genre_id').change(function() {
      $.get({
        url: "/recipe/search_category",
        data: { genre_id: $('#recipe_genre_id').has('option:selected').val() }
      });
    });
  });
  
  import { imagePreview } from "../image_preview.js"
  $(function() {
    new addFields();
    new removeFields();
    new alertImage();
    new imagePreview('preview', 'recipe_image', 'new-recipe-image', 'new-recipe-image img-fluid');
  })
  
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
      
      let textareaEls = document.getElementsByClassName('step-content textArea');
      for (let i = 0;i < textareaEls.length;i++) {
        textareaEls[i].setAttribute("style", `height: ${textareaEls[i].scrollHeight}px;`);
        textareaEls[i].addEventListener("input",function() {
          textareaEls[i].style.height = "auto";
          textareaEls[i].style.height = `${textareaEls[i].scrollHeight}px`;
        });
      }
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
  
  // 作り方でwebpファイルが添付された際の警告、ファイルの削除
  class alertImage {
    constructor() {
      this.iterateLinks()
    }
  
    iterateLinks() {
      document.addEventListener('change', e => {
        if (e.target && e.target.className == 'stepImage') {
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
      categoryForm.disabled = false ;
    }
  }