noflo = require 'noflo'
Delaunay = require '../vendor/delaunay.js'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'toggle-up'
  c.description = 'Calculates Delaunay Triangulation for given points'
  c.inPorts.add 'points',
    datatype: 'array'
  c.outPorts.add 'paths',
    datatype: 'array'
  c.outPorts.add 'error',
    datatype: 'object'
  c.process (input, output) ->
    return unless input.hasData 'points'
    points = input.getData 'points'
    unless points.length > 2
      output.done new Error 'points must contain more than 2 elements'
      return

    vertices = ([point.x, point.y] for point in points)
    ids = Delaunay.triangulate vertices

    v = (vertices[i] for i in ids)

    paths = []
    for i in [0...v.length] by 3
      path =
        type: 'path',
        items: ({'type': 'point', 'x': v[i+j][0], 'y': v[i+j][1]} for j in [0...3])
      paths.push path

    output.sendDone
      paths: paths
