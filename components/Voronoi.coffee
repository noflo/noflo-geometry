noflo = require 'noflo'
Voronoi = require '../vendor/rhill-voronoi-core.js'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'location-arrow'
  c.description = 'Calculates Voronoi Diagram for given points'
  c.inPorts.add 'points',
    datatype: 'array'
  c.inPorts.add 'bbox',
    datatype: 'object'
    description: 'bounding box as a rectangle (default: 200x200)'
    control: true
  c.outPorts.add 'paths',
    datatype: 'array'
  c.outPorts.add 'error',
    datatype: 'object'
  c.process (input, output) ->
    return unless input.hasData 'points'
    sites = input.getData 'points'
    unless sites.length > 2
      output.done new Error 'points must contain more than 2 elements'
      return
    if input.hasData 'bbox'
      bboxData = input.getData 'bbox'
      bbox =
        xl: bboxData.point.x
        xr: bboxData.width
        yt: bboxData.point.y
        yb: bboxData.height
    else
      bbox =
        xl: 0
        xr: 200
        yt: 0
        yb: 200

    voronoi = new Voronoi()
    diagram = voronoi.compute(sites, bbox)

    paths = []
    for cell in diagram.cells
      points = []
      for halfedge in cell.halfedges
        endpoint = halfedge.getEndpoint()
        points.push
          type: 'point'
          x: endpoint.x
          y: endpoint.y
      if points.length > 0
        paths.push
          type: 'path'
          items: points

    output.sendDone
      paths: paths
