
// r2d3: https://rstudio.github.io/r2d3
//

d3.csv("data/small_website.csv"), (function(data){
   console.log(data);
});



var w = 400;
var h = 350;
var barPadding = 1;
var padding = 45;

var svg = d3.select("#chart-area-updates2").append("svg")
   .attr("width", w)
   .attr("height", h);
var jitterWidth = 100;

var allGroup = d3.map(data, function(d){
  return(d.artist_name)}).keys();
  
var yScale = d3.scaleLinear()
  .domain([0, 1])
  .range([300,1]);
  
var yAxis = d3.axisLeft()
  .scale(yScale)
  .ticks(10);
  

d3.select("#selectButton")
  .selectAll('myOptions')
  .data(allGroup)
  .enter()
  .append('option')
  .text(function(d) { return d; })
  .attr("value", function(d) {return d;});
    


svg.selectAll("circle")
  .data(data)
  .enter()
  .append("circle")
  .style("opacity", '0.7')
  .attr("cx", function(d){
    return(150 - Math.random() *jitterWidth)})
  .attr("cy", function(d) {
    return yScale(d.mean_liveness);
  })
  .attr("r", function(d) {
    return d.mean_liveness*10;
})
  .attr("fill", function(d){
    if(d.live_marker2 == "live"){
      return "#CCE5FF";
    } else{
      return "#000099";
    }
  });
 

    


d3.select("#selectButton")
.on("change", function(){
  
   var selectedOption = d3.select(this).property("value");
   
  svg.selectAll("circle")
  .data(data)
  .transition()
  .duration(800)
  .filter(function(d){
    return d.artist_name == selectedOption;
  })
  .attr("cx", 250)
  .attr("cy", function(d) {
    return d.mean_liveness * 450;
  })
  .attr("r", function(d) {
    return d.mean_liveness*20;
})
  .attr("fill", function(d){
    if(d.live_marker2 == "live"){
      return "#CCE5FF";
    } else{
      return "#000099";
    }
  });
  });  

d3.select("#clickingtag")
  .on("click", function(){

svg.selectAll("circle")
  .data(data)
  .filter(function(d){
    return d.artist_name == "Nirvana";
  })
  .attr("cx", 150)
  .attr("cy", function(d) {
    return d.mean_liveness * 450;
  })
  .attr("r", function(d) {
    return d.mean_liveness*7;
})
  .attr("fill", function(d){
    if(d.live_marker2 == "live"){
      return "blue";
    } else{
      return "black";
    }
  });
  });  
  
  
svg.append("g")
  .attr("class", "axis")
  .attr("transform", "translate(" + padding + ",0)")
  .call(yAxis);