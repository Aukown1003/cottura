  /*global location history*/
  window.onload = function() {
    addToSignUpUrl();
    addToNewUrl();
    addToEditUrl();
  }
  
  
  function addToSignUpUrl() {
    let path = location.pathname;
    let pattern = /^.*\/edit.*$/
    if(path.match(pattern)) return;
    history.replaceState('', '', `/users/sign_up`)
  }
  
  function addToNewUrl() {
    let path = location.pathname;
    let pattern = /^.*\/edit.*$/
    if(path.match(pattern)) return;
    pattern = /^.*\/sign_up.*$/
    if(path.match(pattern)) return;

    history.replaceState('', '', `/recipes/new`)
  }
  
  function addToEditUrl() {
    let path = location.pathname;
    let pattern = /^.*\/new.*$/
    if(path.match(pattern)) return;
    pattern = /^.*\/sign_up.*$/
    if(path.match(pattern)) return;
    
    
    pattern = /^.*\/recipes.*$/
    if(path.match(pattern)) {
      history.replaceState('', '', `/recipes/edit`)
      return;
    }
    history.replaceState('', '', `/users/edit`)
    
  }
