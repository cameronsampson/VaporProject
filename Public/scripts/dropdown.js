/**
 * Javascript Dropdown Menu
 * https://www.selftaughtjs.com/building-javascript-dropdown-menus/
 */
var activeDropdown = {};
document.getElementById('sort-dropdown').addEventListener('click',showDropdown);
document.getElementById('status-dropdown').addEventListener('click', showDropdown);
document.getElementById('tags-dropdown').addEventListener('click', showDropdown);
function showDropdown(event){
    if (activeDropdown.id && activeDropdown.id !== event.target.id) {
        activeDropdown.element.classList.remove('active');
    }
    //checking if a list element was clicked, changing the inner button value
    if (event.target.tagName === 'LI') {
        activeDropdown.button.innerHTML = event.target.innerHTML;
        for (var i=0;i<event.target.parentNode.children.length;i++){
            if (event.target.parentNode.children[i].classList.contains('check')) {
                event.target.parentNode.children[i].classList.remove('check');
            }
        }
        //timeout here so the check is only visible after opening the dropdown again
        window.setTimeout(function(){
                          event.target.classList.add('check');
                          },500)
    }
    for (var i = 0;i<this.children.length;i++){
        if (this.children[i].classList.contains('dropdown-selection')){
            activeDropdown.id = this.id;
            activeDropdown.element = this.children[i];
            this.children[i].classList.add('active');
        }
        //adding the dropdown-button to our object
        else if (this.children[i].classList.contains('dropdown-select')){
            activeDropdown.button = this.children[i];
        }
    }
}

window.onclick = function(event) {
    if (!event.target.classList.contains('dropdown-select')) {
        activeDropdown.element.classList.remove('active');
    }
}
