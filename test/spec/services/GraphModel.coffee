'use strict'

describe 'Service: GraphModel', () ->
  [backend, graph] = [null, null]
  # load the service's module
  beforeEach module 'neo4jApp.services'

  beforeEach inject ($httpBackend) ->
    backend = $httpBackend

  afterEach ->
    backend.verifyNoOutstandingRequest()

  # instantiate service
  GraphModel = {}
  Node = {}
  beforeEach inject (_GraphModel_, _Node_) ->
    GraphModel = _GraphModel_
    Node     = _Node_

  createNode = (id) ->
    data = {
      "id": id
      "labels": []
      "properties": {},
    }
    new Node(data)

  describe 'addNode:', ->
    beforeEach ->
      graph = new GraphModel
    it 'should add a node to collection', ->
      node = createNode(1)
      graph.addNode(node)
      expect(graph.nodes.all().length).toBe 1

    it 'should not add new node with existing id', ->
      node1 = createNode(1)
      node2 = createNode(1)
      graph.addNode(node1)
      graph.addNode(node2)
      expect(graph.nodes.all().length).toBe 1

    it 'should be able to add a node with id 0', ->
      node = createNode(0)
      graph.addNode(node)
      expect(graph.nodes.all().length).toBe 1

  describe 'expandAll', ->
    beforeEach ->
      graph = new GraphModel
    xit 'should return promise even if there are no nodes', inject ($rootScope) ->
      expect(graph.nodes.all().length).toBe 0

      promise = graph.expandAll()
      expect(typeof(promise.then)).toBe 'function'

      callback = jasmine.createSpy('callback')
      promise.then(callback)
      $rootScope.$apply();
      expect(callback).toHaveBeenCalled()

    xit 'should expand existing nodes', ->
      graph.addNode(createNode(0))
      backend.expectPOST(/db\/data\/cypher/).respond()

      node = null
      graph.expandAll().then((g)->
        node = g.nodes.get(0)
      )
      backend.flush()
      expect(node.expanded).toBeTruthy()

  describe 'merge', ->
    beforeEach ->
      graph = new GraphModel

    it 'should handle empty input', ->
      merge = ->
        graph.merge(null)

      expect(merge).not.toThrow()

