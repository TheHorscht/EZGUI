let links = document.querySelectorAll('a');

const hasParentWithClass = (el, classname) => {
  let parent = el;
  while(parent != null && !parent.classList.contains(classname)) {
    parent = parent.parentElement;
  }
  return parent != null;
};

const setAllLinksInactive = () => links.forEach(link => {
  const target = link.getAttribute("href").substring(1);
  link.classList.remove('activeTarget');
  document.getElementById(target)?.classList.remove("activeTarget");
  // window.location.hash = '';
});

const setLinkActive = link => {
  const target = link.getAttribute("href").substring(1);
  document.getElementById(target)?.classList.add("activeTarget");
  document.querySelector(`.navigation a[href="#${target}"]`)?.classList.add('activeTarget');
  document.getElementById(target)?.scrollIntoView({ behavior: 'smooth', block: 'center'});
};

links.forEach(el => {
  el.addEventListener('click', evt => {
    setAllLinksInactive();
    setLinkActive(el);
    evt.stopImmediatePropagation();
    evt.preventDefault();
  });
});

window.addEventListener('click', evt => {
  // console.log(evt.target);
  if(!hasParentWithClass(evt.target, "activeTarget")) {
  // if(!evt.target.classList.contains("dontClearActiveTarget")) {
    setAllLinksInactive();
  }
});
