// r2d3: https://rstudio.github.io/r2d3
//
  
  d3.csv("data/small_gathered.csv"), (function(data){
    console.log(data);
  });


var w = 800;
var h = 800;
var barPadding = 1;
var padding = 30;

var svg = d3.select("#chart-area-updates3").append("svg")
.attr("width", w)
.attr("height", h);

var yScale = d3.scaleLinear()
.domain([0, 1])
.range([800,1]);

var xScale = d3.scaleLinear()
.domain([0, 1])
.range([800,1]);

var yAxis = d3.axisLeft()
.scale(yScale)
.ticks(5);


var myGroups = ["Danceability", "Energy", "instrumentalness", "Speechiness",
                "Valence"];

var myVars = ["Nirvana", "Johnny Cash"];

// Build X scales and axis:
  var x = d3.scaleBand()
.range([ 0, width ])
.domain(myGroups)
.padding(0.01);
svg.append("g")
.attr("transform", "translate(0," + height + ")")
.call(d3.axisBottom(x));

// Build X scales and axis:
  var y = d3.scaleBand()
.range([ height, 0 ])
.domain(myVars)
.padding(0.01);
svg.append("g")
.call(d3.axisLeft(y));


// Build color scale
var myColor = d3.scaleLinear()
.range(["white", "#69b3a2"])
.domain([1,100]);



//Read the data
d3.csv("data/small_gathered.csv", function(data) {
  
  svg.selectAll()
  .data(data, function(d) {return d.artist_name+':'+d.Variables;})
  .enter()
  .append("rect")
  .attr("x", function(d) { return xScale(d.artist_name) })
  .attr("y", function(d) { return yScale(d.Variables) })
  .attr("width", x.bandwidth() )
  .attr("height", y.bandwidth() )
  .style("fill", function(d) { return myColor(d.Gain)} );
  
});
