  /*global $*/
  
  $(function(){
    $('.jenre-item').click(function(){
      $(this).next('.category-list').slideToggle();
      $(this).toggleClass("open");
      $('.jenre-item').not($(this)).next('.category-list').slideUp();
      $('.jenre-item').not($(this)).removeClass("open");
    });
  });
  
  $(function() {
    new modalForm();
  })
  
  // // モーダルフォームの展開
  class modalForm {
    constructor() {
      this.modalButton = document.getElementById('modalOpen');
      this.modal = document.getElementById('modal');
      this.mask = document.getElementById('mask');
      this.modalChange()
    }
    modalChange() {
      if (!this.modalButton){ return false;}
      this.modalButton.addEventListener('click', () => {
        this.modal.classList.remove('hidden');
        this.mask.classList.remove('hidden');
      });
      this.mask.addEventListener('click', () => {
        this.modal.classList.add('hidden');
        this.mask.classList.add('hidden');
      });
    }
  }