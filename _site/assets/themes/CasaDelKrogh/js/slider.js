(function(){
  //Controller for handling clicks and onfocus
  var sliderControl = function(){
    var i = 0;
    var elm = this;
    var inner = this.parentNode.querySelector(".inner");
    while((elm = elm.previousSibling) != null){
      //Only count input nodes
      if(elm.tagName === "INPUT"){ 
        i++;
      }
    }
    var inlineStyle = inner.style.cssText.replace(/margin-left: -\d+%/,"");
    if(i === 0){
      inner.style.cssText=inlineStyle;
    }else{
      inner.style.cssText=inlineStyle+"margin-left: -"+i+"00%;";
    }
  }
  
  /* Creates a slider control radio button. */
  var createRadio = function(name,id){
    var radio = document.createElement("input");
    radio.onfocus=sliderControl; 
    radio.onclick=sliderControl;
    radio.type="radio";
    radio.className="control";
    radio.name=name;
    return radio;
  }

  $(document).ready(function(){
    var sliders = document.querySelectorAll(".slider");
    /* Create sliders */
    for(var s=0; s < sliders.length; s++){
      var slider = sliders[s];
      var items = slider.querySelectorAll(".item");
      var inner = slider.querySelector(".inner");
      inner.style.cssText="width: "+items.length+"00%;";
      var itemWidth = 100/items.length;
      for(var i=0; i < items.length; i++){
        /*Set item width to be 100/items% */
        items[i].style.cssText="width: "+itemWidth+"%;";
        
        /* Create radio button */
        var radio = createRadio("slider"+s);
        if(i===0)radio.checked=true;
        /* Create label for styling */
        var label = document.createElement("label");
        radio.id = radio.name+"_"+i;
        label.htmlFor=radio.name+"_"+i;
        label.className="control";
        slider.appendChild(radio);
        slider.appendChild(label);
      }
    }
  }); 
})(); 
