'use strict'

angular.module('neo4jApp.controllers')
.controller 'StreamCtrl', [
  '$scope'
  '$timeout'
  'Collection'
  'Document'
  'Folder'
  'Frame'
  'motdService'
  ($scope, $timeout, Collection, Document, Folder, Frame, motdService) ->

    ###*
     * Local methods
    ###

    scopeApply = (fn)->
      return ->
        fn.apply($scope, arguments)
        $scope.$apply()

    ###*
     * Scope methods
    ###

    $scope.showingSidebar = (named) ->
      $scope.isSidebarShown and ($scope.whichSidebar == named)

    $scope.createFolder = (id)->
      Folder.create(id)

    # Creates and executes a new frame
    $scope.createFrame = (data = {}) ->
      return undefined unless data.input
      $scope.currentFrame = frame = Frame.create(data)
      frame.exec() if frame
      frame

    $scope.createDocument = (data = {}) ->
      Document.create(data)

    $scope.destroyFrame = (frame) ->
      $scope.frames.remove(frame)

    $scope.setEditorContent = (content) ->
      $scope.editor.content = content

    $scope.execScript = (input) ->
      frame = $scope.createFrame(input: input)
      #return unless frame
      if input?.length > 0 and $scope.editorHistory[0] isnt input
        $scope.editorHistory.unshift(input)
      $scope.historySet(-1)

    $scope.couldBeCommand = (input) ->
      return false unless input?
      return true if input.charAt(0) is ':'
      return false

    $scope.historyNext = ->
      idx = $scope.editor.cursor
      idx ?= $scope.editorHistory.length
      idx--
      $scope.historySet(idx)

    $scope.historyPrev = ->
      idx = $scope.editor.cursor
      idx ?= -1
      idx++
      $scope.historySet(idx)

    $scope.historySet = (idx)->
      idx = -1 if idx < 0
      idx = $scope.editorHistory.length - 1 if idx >= $scope.editorHistory.length
      $scope.editor.cursor = idx
      $scope.editor.prev = $scope.editorHistory[idx+1]
      $scope.editor.next = $scope.editorHistory[idx-1]
      item = $scope.editorHistory[idx] or ''
      $scope.setEditorContent(item)

    $scope.importDocument = (content) ->
      $scope.createDocument(content: content)
      $scope.toggleSidebar(yes)

    $scope.removeFolder = (folder) ->
      okToRemove = confirm("Are you sure you want to delete the folder?")
      return unless okToRemove
      Folder.remove(folder)

    $scope.toggleFolder = (folder) ->
      Folder.expand(folder)

    $scope.toggleStar = (doc) ->
      Document.remove(doc)


    ###*
     * Event listeners
    ###
    $scope.$on 'editor:content', (ev, content) ->
      $scope.editor.content = content

    $scope.$on 'editor:exec', ->
      $scope.execScript($scope.editor.content)

    $scope.$on 'editor:next', $scope.historyNext

    $scope.$on 'editor:prev', $scope.historyPrev

    $scope.$on 'frames:clear', ->
      $scope.frames.reset()

    $scope.$on 'frames:create', (evt, input) ->
      $scope.createFrame(input: input)

    ###*
     * Initialization
    ###

    # Handlers for drag n drop
    $scope.sortableOptions =
      stop: scopeApply (e, ui) ->
        doc = ui.item.scope().document

        folder = if ui.item.folder? then ui.item.folder else doc.folder
        offsetLeft = Math.abs(ui.position.left - ui.originalPosition.left)

        if ui.item.relocate
          doc.folder = folder
          doc.starred = !!folder
        # XXX: FIXME
        else if offsetLeft > 200
          $scope.documents.remove(doc)

        if ui.item.resort
          idxOffset = ui.item.index()
          # Get insertion index offset
          first = $scope.documents.where(folder: folder)[0]
          idx = $scope.documents.indexOf(first)
          idx = 0 if idx < 0
          $scope.documents.remove(doc)
          $scope.documents.add(doc, {at: idx + idxOffset})

        $scope.documents.save()

      update: (e, ui) ->
        ui.item.resort = yes

      receive: (e, ui) ->
        ui.item.relocate = yes
        folder = angular.element(e.target).scope().folder
        ui.item.folder = if folder? then folder.id else false

      cursor: "move"
      dropOnEmpty: yes
      connectWith: '.droppable'
      items: 'li'

    # Expose documents and folders to views
    $scope.folders = Folder
    $scope.documents   = Document

    $scope.frames = Frame

    # TODO: fix timeout problem
    $timeout(->
     $scope.createFrame(input: ':help welcome')
    , 800)
    $scope.editorHistory = []
    $scope.editor =
      content: ''
      cursor: null
      next: null
      prev: null

    $scope.motd = motdService

  ]
