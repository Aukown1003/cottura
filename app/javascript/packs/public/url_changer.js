  /*global location history*/
  window.onload = function() {
    addToSignUpUrl();
    addToNewUrl();
    addToEditUrl();
  }
  
  
  function addToSignUpUrl() {
    let path = location.pathname;
    let pattern = /^.*\/sign_up.*$/
  
    if(path.match(pattern)) return;
    history.replaceState('', '', `${ path }/sign_up`)
  }
  
  function addToNewUrl() {
    let path = location.pathname;
    let pattern = /^.*\/new.*$/
  
    if(path.match(pattern)) return;
    history.replaceState('', '', `${ path }/new`)
  }
  
  function addToEditUrl() {
    let path = location.pathname;
    let pattern = /^.*\/edit.*$/
  
    if(path.match(pattern)) return;
    history.replaceState('', '', `${ path }/edit`)
  }
