/*global $*/
$(function() {
  const elements = document.getElementsByClassName('ingredient-quantity');
  const recalculationFormChange = new recalculationForm(elements);
})

// レシピ分量の再計算のフォームの入力制限
class recalculationForm {
  constructor(elements) {
    this.elements = elements;
    this.inputValues = [];

    for(let i = 0; i < this.elements.length; i++) {
      this.elements[i].addEventListener('change', this.inputValueChange.bind(this));
    }
  }

  inputValueChange() {
    this.inputValues = Array.from(this.elements).map(e => e.value);

    Array.from(this.elements).forEach((element) => {
      if (!element.value) {
        element.disabled = true;
      }
    });

    if(this.inputValues.filter(e => e).length == 0) {
      Array.from(this.elements).forEach((element) => {
        element.disabled = false;
      });
    }
  }
}
