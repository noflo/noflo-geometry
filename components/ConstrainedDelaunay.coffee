noflo = require 'noflo'
poly2tri = require '../vendor/poly2tri.min.js'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'toggle-up'
  c.description = 'Calculates de constrained Delaunay triangulation of given points'
  c.inPorts.add 'x',
    datatype: 'array'
  c.inPorts.add 'y',
    datatype: 'array'
  c.outPorts.add 'paths',
    datatype: 'array'
  c.outPorts.add 'error',
    datatype: 'object'

  c.process (input, output) ->
    return unless input.hasData 'x', 'y'
    [x, y] = input.getData 'x', 'y'
    unless x.length > 2
      output.done new Error 'x must contain more than 2 elements'
      return

    try
      contour = (new poly2tri.Point(x[i], y[i]) for i in [0...x.length])
      swctx = new poly2tri.SweepContext contour
      swctx.triangulate()
    catch error
      output.done error
      return

    # TODO Add holes and Steiner points: https://github.com/r3mi/poly2tri.js
    
    triangles = swctx.getTriangles()

    paths = []
    for t in triangles
      points = t.getPoints()
      path =
        type: 'path',
        items: ({'type': 'point', 'x': p.x, 'y': p.y} for p in points)
      paths.push path

    output.sendDone
      paths: paths
