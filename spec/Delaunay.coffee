noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-geometry'

describe 'Delaunay component', ->
  c = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'geometry/Delaunay', (err, instance) ->
      return done err if err
      c = instance
      ins = noflo.internalSocket.createSocket()
      c.inPorts.points.attach ins
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.paths.attach out
  afterEach ->
    c.outPorts.paths.detach out

  describe 'when instantiated', ->
    it 'should have an points port', ->
      chai.expect(c.inPorts.points).to.be.an 'object'
    it 'should have an paths port', ->
      chai.expect(c.outPorts.paths).to.be.an 'object'
